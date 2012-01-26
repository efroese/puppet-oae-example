###########################################################################
#
# Nodes
#
# make sure that modules/localconfig -> modules/rsmart-config
# see modules/rsmart-config/manifests.init.pp for the config.

# Install image
node 'base.academic.rsmart.local' inherits oaenode { }

###########################################################################
#
# Apache load balancer
#
node 'apache1.academic.rsmart.local' inherits oaenode {

    class { 'apache::ssl': }

    # Headers is not in the default set of enabled modules
    apache::module { 'headers': }
    apache::module { 'deflate': }

    # http://staging.academic.rsmart.com to redirects to 443
    apache::vhost { "${localconfig::http_name}:80":
        template => 'localconfig/vhost-80.conf.erb',
    }

    ###########################################################################
    # https://staging.academic.rsmart.com:443

    # Serve the OAE app (trusted content) on 443
    apache::vhost-ssl { "${localconfig::http_name}:443":
        sslonly  => true,
        cert     => "/etc/pki/tls/certs/rsmart.com.crt",
        certkey  => "/etc/pki/tls/private/rsmart.com.key",
        certchain => "/etc/pki/tls/certs/rsmart.com-intermediate.crt",
        template  => 'localconfig/vhost-443.conf.erb',
    }

    # Balancer pool for trusted content
    apache::balancer { "apache-balancer-oae-app":
        vhost      => "${localconfig::http_name}:443",
        location   => "/",
        locations_noproxy => ['/server-status', '/balancer-manager'],
        proto      => "http",
        members    => $localconfig::apache_lb_members,
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'localconfig/balancer-trusted.erb',
    }

    # Balancer pool for CLE traffic
    apache::balancer { "apache-balancer-cle":
        vhost      => "${localconfig::http_name}:443",
        proto      => "ajp",
        members    => $localconfig::apache_cle_lb_members,
        params     => [ "timeout=300", "loadfactor=100" ],
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'localconfig/balancer-cle.erb',
    }

    ###########################################################################
    # https://staging.academic.rsmart.com:8443

    # Serve untrusted content from 8443
    apache::listen { "8443": }
    apache::namevhost { "*:8443": }
    apache::vhost-ssl { "${localconfig::http_name}:8443":
        sslonly  => true,
        sslports => ['*:8443'],
        cert     => "/etc/pki/tls/certs/rsmart.com.crt",
        certkey  => "/etc/pki/tls/private/rsmart.com.key",
        certchain => "/etc/pki/tls/certs/rsmart.com-intermediate.crt",
        template  => 'localconfig/vhost-8443.conf.erb',
    }

    # Balancer pool for untrusted content
    apache::balancer { "apache-balancer-oae-app-untrusted":
        vhost      => "${localconfig::http_name}:8443",
        location   => "/",
        proto      => "http",
        members    => $localconfig::apache_lb_members_untrusted,
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => $localconfig::apache_lb_standbyurl,
    }

    ###########################################################################
    # Apache global config

    file { "/etc/httpd/conf.d/traceenable.conf":
        owner => root,
        group => root,
        mode  => 644,
        content => 'TraceEnable Off',
    }
}

###########################################################################
#
# OAE app nodes
#
node oaeappnode inherits oaenode {

    class { 'oae::app::server':
        jarsource      => $localconfig::jarsource,
        jarfile        => $localconfig::jarfile,
        java           => $localconfig::java,
        javamemorymin  => $localconfig::javamemorymin,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
        setenv_template => 'localconfig/setenv.sh.erb',
    }
    
    ###########################################################################
    # Storage

    # NFS mounted shared storage for content bodies
    file { $localconfig::storedir:
        ensure => directory,
        owner => root,
        group => root,
    }

    mount { $localconfig::storedir:
        ensure => 'mounted',
        fstype => 'nfs',
        device => "${localconfig::nfs_server}:${localconfig::nfs_share}",
        options => $localconfig::nfs_options,
        atboot => true,
    }

    # Connect OAE to the DB
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-driver'      => $localconfig::db_driver,
            'jdbc-url'         => $localconfig::db_url,
            'username'         => $localconfig::db_user,
            'password'         => $localconfig::db_password,
            'long-string-size' => 16384,
            'store-base-dir'   => $localconfig::storedir,
        }
    }

    ###########################################################################
    # Security

    # Separates trusted vs untrusted content.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => [
                "localhost:8080\\ \\=\\ http://localhost:8081",
                "${hostname}:8080\\ \\=\\ http://${hostname}:8081",
                "${localconfig::http_name}\\ \\=\\ https://${localconfig::http_name}:8443",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    # QoS filter rate-limits the app server so it won't fall over
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.qos.QoSFilter":
        config => { 'qos.default.limit' => 50, }
    }

    ###########################################################################
    # Search

    # Specify the client type
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.SolrServerServiceImpl":
        config => { "solr-impl" => "multiremote", }
    }
    # Configure the client with the master/slave(s) info
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.MultiMasterRemoteSolrClient":
        config => {
            "remoteurl"  => $localconfig::solr_remoteurl,
            "query-urls" => $localconfig::solr_queryurls,
        }
    }

    ###########################################################################
    # Clustering

    # Note that IP address will be evaluated by puppet on the node.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.cluster.ClusterTrackingServiceImpl":
        config => { 'secure-host-url' => "http://${ipaddress}:8081", }
    }

    # Clustered cache
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.memory.CacheManagerServiceImpl":
        config => { 'bind-address' => $ipaddress, }
    }

    # Keep an eye on caching in staging
    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config-caching':
        locked => false,
        config => {
            'org.apache.sling.commons.log.names' => ["org.sakaiproject.nakamura.memory","net.sf.ehcache"],
            'org.apache.sling.commons.log.level' => "trace",
            'org.apache.sling.commons.log.file'  => "logs/cache.log",
            'service.factoryPid'                 => "org.apache.sling.commons.log.LogManager.factory.config",
        }
    }

    ###########################################################################
    # CLE integration
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
        config => {
            'sakai.cle.basiclti.secret' => "secret",
            'sakai.cle.server.url'      => "https://${localconfig::http_name}",
            'sakai.cle.basiclti.key'    => "12345",
        }
    }
}

node 'app1.academic.rsmart.local' inherits oaeappnode {
    class { 'oae::app::ehcache':
        # 2 nodes, each others peer.
        peers       => [ $localconfig::app_server2, ],
        tcp_address => $ipaddress,
        remote_object_port => $localconfig::ehcache_remote_object_port,
    }
}

node 'app2.academic.rsmart.local' inherits oaeappnode {
    class { 'oae::app::ehcache':
        peers       => [ $localconfig::app_server1, ],
        tcp_address => $ipaddress,
        remote_object_port => $localconfig::ehcache_remote_object_port,
    }
}

###########################################################################
#
# OAE Solr Nodes
#
node solrnode inherits oaenode {
    # All of the solr servers get tomcat
    class { 'tomcat6':
        parentdir      => $localconfig::basedir,
        tomcat_user    => $localconfig::user,
        tomcat_group   => $localconfig::group,
        admin_user     => $localconfig::tomcat_user,
        admin_password => $localconfig::tomcat_password,
    }
}

node 'solr1.academic.rsmart.local' inherits solrnode {
    class { 'oae::solr::tomcat':
        master_url   => "${localconfig::solr_remoteurl}/replication",
        solrconfig   => 'localconfig/master-solrconfig.xml.erb',
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }

    oae::solr::backup { "solr-backup-${localconfig::solr_remoteurl}-${oae::params::basedir}/solr/backups":
       solr_url   => $localconfig::solr_remoteurl,
       backup_dir => "${oae::params::basedir}/solr/backups",
       user       => $oae::params::user,
       group      => $oae::params::group,
    }
}

node /solr[2-3].academic.rsmart.local/ inherits solrnode {
    class { 'oae::solr::tomcat':
        master_url   => "${localconfig::solr_remoteurl}/replication",
        solrconfig   => 'localconfig/slave-solrconfig.xml.erb',
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'preview.academic.rsmart.local' inherits oaenode {
    class { 'oae::preview_processor::init': 
        nakamura_git => $localconfig::nakamura_git,
        nakamura_tag => $localconfig::nakamura_tag,
    }
}

###########################################################################
#
# Postgres Database Server
#
node 'dbserv1.academic.rsmart.local' inherits oaenode {

    class { 'postgres':
        postgresql_conf_template => 'localconfig/postgresql.conf.erb',
    }

    postgres::database { $localconfig::db:
        ensure => present,
    }

    postgres::role { $localconfig::db_user:
        ensure   => present,
        password => $localconfig::db_password,
        require  => Postgres::Database[$localconfig::db],
    }

    postgres::clientauth { "host-${localconfig::db}-${localconfig::db_user}-all-md5":
       type => 'host',
       db   => $localconfig::db,
       user => $localconfig::db_user,
       address => "$ipaddress/24",
       method  => 'md5',
    }
    
    # Allowing a maximum 24GB of shared memory:
    exec { 'set-shmmax':
        command => '/sbin/sysctl -w kernel.shmmax=25769803776',
        unless  => '/sbin/sysctl kernel.shmmax | grep 25769803776',
    }
    exec { 'set-shmall':
        command => '/sbin/sysctl -w kernel.shmall=4194304',
        unless  => '/sbin/sysctl kernel.shmall | grep 4194304',
    }

    # Make sure the kernel config changes persist across a reboot:
    exec { 'persist-shmmax':
        command => 'echo kernel.shmmax=25769803776 | tee -a /etc/sysctl.conf',
        unless  => 'grep 25769803776 /etc/sysctl.conf',
    }
    exec { 'persist-shmall':
        command => 'echo kernel.shmall=4194304 | tee -a /etc/sysctl.conf',
        unless  => 'grep 4194304 /etc/sysctl.conf',
    }
}
