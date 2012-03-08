###########################################################################
#
# Nodes
#
# make sure that modules/localconfig -> modules/rsmart-staging-config
# see modules/rsmart-staging-config/manifests.init.pp for the config.

###########################################################################
# Apache load balancer
node 'staging-apache1.academic.rsmart.local' inherits oaenode {

    class { 'localconfig::extra_users': }

    class { 'apache':
        httpd_conf_template => 'localconfig/httpd.conf.erb'
    }

    class { 'apache::ssl': }

    # Headers is not in the default set of enabled modules
    apache::module { 'headers': }
    apache::module { 'deflate': }

    # http://staging.academic.rsmart.com to redirects to 443
    apache::vhost { "${localconfig::http_name}:80":
        template => 'rsmart-common/vhost-80.conf.erb',
    }

    ###########################################################################
    # https://staging.academic.rsmart.com:443

    # Serve the OAE app (trusted content) on 443
    apache::vhost-ssl { "${localconfig::http_name}:443":
        sslonly  => true,
        cert     => "puppet:///modules/rsmart-common/academic.rsmart.com.crt",
        certkey  => "puppet:///modules/rsmart-common/academic.rsmart.com.key",
        certchain => "puppet:///modules/rsmart-common/academic.rsmart.com-intermediate.crt",
        template  => 'rsmart-common/vhost-trusted.conf.erb',
    }

    # Balancer pool for trusted content
    apache::balancer { "apache-balancer-oae-app":
        vhost      => "${localconfig::http_name}:443",
        location   => "/",
        locations_noproxy => ['/server-status', '/balancer-manager'],
        proto      => "http",
        members    => $localconfig::apache_lb_members,
        params     => $localconfig::apache_lb_params,
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'rsmart-common/balancer-trusted.erb',
    }

    # Balancer pool for CLE traffic
    apache::balancer { "apache-balancer-cle":
        vhost      => "${localconfig::http_name}:443",
        proto      => "ajp",
        members    => $localconfig::apache_cle_lb_members,
        params     => [ "timeout=300", "loadfactor=100" ],
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'rsmart-common/balancer-cle.conf.erb',
    }

    ###########################################################################
    # https://staging-content.academic.rsmart.com:443

    # Serve untrusted content from another hostname on port 443
    apache::vhost-ssl { "${localconfig::http_name_untrusted}:443":
        sslonly  => true,
        cert     => "puppet:///modules/rsmart-common/academic.rsmart.com.crt",
        certkey  => "puppet:///modules/rsmart-common/academic.rsmart.com.key",
        certchain => "puppet:///modules/rsmart-common/academic.rsmart.com-intermediate.crt",
        template  => 'rsmart-common/vhost-untrusted.conf.erb',
    }

    # Balancer pool for untrusted content
    apache::balancer { "apache-balancer-oae-app-untrusted":
        vhost      => "${localconfig::http_name_untrusted}:443",
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
# OAE app nodes
node oaeappnode inherits oaenode {

    class { 'localconfig::extra_users': }

    ###########################################################################
    # OAE, Sling
    class { 'oae::app::server':
        jarsource      => $localconfig::jarsource,
        jarfile        => $localconfig::jarfile,
        java           => $localconfig::java,
        javamemorymin  => $localconfig::javamemorymin,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
        setenv_template => 'rsmart-common/setenv.sh.erb',
        store_dir       => $localconfig::storedir,
    }

    ###########################################################################
    # Storage
    class { 'nfs::client': }

    file  { $localconfig::nfs_mountpoint: ensure => directory }
    mount { $localconfig::nfs_mountpoint:
        ensure => 'mounted',
        fstype => 'nfs4',
        device => "${localconfig::nfs_server}:${localconfig::nfs_share}",
        options => $localconfig::nfs_options,
        atboot => true,
        require => File[$localconfig::nfs_mountpoint],
    }

    # Connect OAE to the DB
    class { 'postgres::repos': stage => init }
    class { 'postgres::client': }
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
            'disable.protection.for.dev.mode' => $localconfig::sps_disabled,
            'trusted.hosts'  => [
                "localhost:8080\\ \\=\\ http://localhost:8081",
                "${hostname}:8080\\ \\=\\ http://${hostname}:8081",
                "${localconfig::http_name}\\ \\=\\ https://${localconfig::http_name_untrusted}",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    if $localconfig::qos_limit {
        # QoS filter rate-limits the app server so it won't fall over
        oae::app::server::sling_config {
            "org.sakaiproject.nakamura.http.qos.QoSFilter":
            config => { 'qos.default.limit' => $localconfig::qos_limit, }
        }
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
            "query-so-timeout" => 10000,
            "query-connection-timeout" => 1000,
            "query-connection-manager-timeout" => 1000,
            "connection.timeout" => 1000,
        }
    }

    ###########################################################################
    # Clustering

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.cluster.ClusterTrackingServiceImpl":
        config => { 'secure-host-url' => "http://${ipaddress}:8081", }
    }

    # Clustered cache
    # Note that IP address will be evaluated by puppet on the node.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.memory.CacheManagerServiceImpl":
        config => { 'bind-address' => $ipaddress, }
    }

    class { 'oae::app::ehcache':
        peers       => [ $localconfig::app_server1, $localconfig::app_server2, ],
        tcp_address => $ipaddress,
        remote_object_port => $localconfig::ehcache_remote_object_port,
    }

    ###########################################################################
    # CLE integration
    if ($localconfig::basiclti_secret) and ($localconfig::basiclti_key) {
        oae::app::server::sling_config {
            "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
            config => {
                'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
                'sakai.cle.server.url'      => "https://${localconfig::http_name}",
                'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
            }
        }
    }

    ###########################################################################
    # Email integration
    oae::app::server::sling_config {
        'org.sakaiproject.nakamura.email.outgoing.LiteOutgoingEmailMessageListener':
        config => {
            'sakai.email.replyAsAddress' => $localconfig::reply_as_address,
            'sakai.email.replyAsName'    => $localconfig::reply_as_name,
        }
    }

    ###########################################################################
    # Logs
    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config.search-logger-uuid':
        config => {
            'service.factoryPid'                 => 'org.apache.sling.commons.log.LogManager.factory.config',
            'org.apache.sling.commons.log.names' => ['org.sakaiproject.nakamura.search','org.sakaiproject.nakamura.solr'],
            'org.apache.sling.commons.log.level' => 'info',
            'org.apache.sling.commons.log.file'  => 'logs/search.log',
        }
    }

    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config.cache-logger-uuid':
        config => {
            'service.factoryPid'                 => 'org.apache.sling.commons.log.LogManager.factory.config',
            'org.apache.sling.commons.log.names' => ['org.sakaiproject.nakamura.memory','net.sf.ehcache'],
            'org.apache.sling.commons.log.level' => 'info',
            'org.apache.sling.commons.log.file'  => 'logs/cache.log',
        }
    }
}

node /staging-app[1-2].academic.rsmart.local/ inherits stagingnode { }

###########################################################################
#
# OAE Solr Nodes
#
node solrnode inherits oaenode {

    class { 'localconfig::extra_users': }

    # All of the solr servers get tomcat
    class { 'tomcat6':
        parentdir      => $localconfig::basedir,
        tomcat_user    => $localconfig::user,
        tomcat_group   => $localconfig::group,
        admin_user     => $localconfig::tomcat_user,
        admin_password => $localconfig::tomcat_password,
        setenv_template => 'rsmart-common/solr-setenv.sh.erb',
    }
}

node 'staging-solr1.academic.rsmart.local' inherits solrnode {
    class { 'oae::solr::tomcat':
        master_url   => "${localconfig::solr_remoteurl}/replication",
        solrconfig   => 'rsmart-common/master-solrconfig.xml.erb',
        tomcat_home  => "${localconfig::basedir}/tomcat",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }
}

node /staging-solr[2-3].academic.rsmart.local/ inherits solrnode {
    class { 'oae::solr::tomcat':
        master_url   => "${localconfig::solr_remoteurl}/replication",
        solrconfig   => 'rsmart-common/slave-solrconfig.xml.erb',
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'staging-preview.academic.rsmart.local' inherits oaenode {

    class { 'localconfig::extra_users': }

    class { 'oae::preview_processor::init':
        upload_url     => "https://${localconfig::http_name}/",
        admin_password => $localconfig::admin_password,
        nakamura_zip   => $localconfig::nakamura_zip,
    }
}

###########################################################################
#
# NFS Server
#
node 'staging-nfs.academic.rsmart.local' inherits oaenode {

    class { 'localconfig::extra_users': }

    class { 'nfs::server': }

    file { '/export':
        ensure => directory
    }

    file { '/export/files-academic':
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 0744,
    }

    nfs::export { 'export-sakai-files-app0-app1-rw':
        ensure  => present,
        share   => '/export/files-academic',
        options => 'rw',
        guests   => [
            [ $localconfig::app_server1, 'rw' ],
            [ $localconfig::app_server2, 'rw' ],
        ],
    }
}

###########################################################################
#
# Postgres Database Server
#
node 'staging-dbserv1.academic.rsmart.local' inherits oaenode {

    class { 'localconfig::extra_users': }

    class { 'postgres::repos': stage => init }

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
       address => "all",
       method  => 'md5',
    }

    postgres::backup::simple { $localconfig::db:
        # Overwrite the last backup
        date_format => '',
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
