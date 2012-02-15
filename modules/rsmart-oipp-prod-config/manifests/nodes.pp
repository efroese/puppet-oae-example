###########################################################################
#
# Nodes
#
# make sure that modules/localconfig -> modules/rsmart-config
# see modules/rsmart-config/manifests.init.pp for the config.

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
        sslonly   => true,
        #cert     => "puppet:///modules/localconfig/cole.uconline.edu.crt",
        #certkey  => "puppet:///modules/localconfig/cole.uconline.edu.key",
        #certchain => "puppet:///modules/localconfig/cole.uconline.edu-intermediate.crt",
        cert      => "puppet:///modules/localconfig/academic.rsmart.com.crt",
        certkey   => "puppet:///modules/localconfig/academic.rsmart.com.key",
        certchain => "puppet:///modules/localconfig/academic.rsmart.com-intermediate.crt",
        template  => 'localconfig/vhost-443.conf.erb',
    }

    # Balancer pool for trusted content
    apache::balancer { "apache-balancer-oae-app":
        vhost      => "${localconfig::http_name}:443",
        location   => "/",
        locations_noproxy => ['/server-status', '/balancer-manager', '/Shibboleth.sso'],
        proto      => "http",
        members    => $localconfig::apache_lb_members,
        params     => $localconfig::apache_lb_params,
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'localconfig/balancer-trusted.erb',
    }

    # Mock out CLE content
    if $localconfig::mock_cle_content {
        $htdocs = "${apache::params::root}/${localconfig::http_name}:443/htdocs"
        exec { "mkdir-mock-cle-content":
            command => "mkdir -p ${htdocs}/access/content/group/OAEGateway",
            creates => "${htdocs}/access/content/group/OAEGateway"
        }

        file { "${htdocs}/access/content/group/OAEGateway/splash.html":
            mode => 0644,
            content => "<html><body>This is mock content. Set \$localconfig::mock_cle_content = false to disable this message.</body></html>",
            require => Exec["mkdir-mock-cle-content"],
        }
    }
    else {
        # Balancer pool for CLE traffic
        apache::balancer { "apache-balancer-cle":
            vhost      => "${localconfig::http_name}:443",
            proto      => "ajp",
            members    => $localconfig::apache_cle_lb_members,
            params     => [ "timeout=300", "loadfactor=100" ],
            standbyurl => $localconfig::apache_lb_standbyurl,
            template   => 'localconfig/balancer-cle.erb',
        }
    }

    ###########################################################################
    # Serve untrusted content from another hostname
    apache::vhost-ssl { "${localconfig::http_name_untrusted}:443":
        sslonly   => true,
        #cert     => "puppet:///modules/localconfig/content-cole.uconline.edu.crt",
        #certkey  => "puppet:///modules/localconfig/content-cole.uconline.edu.key",
        #certchain => "puppet:///modules/localconfig/content-cole.uconline.edu-intermediate.crt",
        cert      => "puppet:///modules/localconfig/academic.rsmart.com.crt",
        certkey   => "puppet:///modules/localconfig/academic.rsmart.com.key",
        certchain => "puppet:///modules/localconfig/academic.rsmart.com-intermediate.crt",
        template  => 'localconfig/vhost-8443.conf.erb',
    }

    # Balancer pool for untrusted content
    apache::balancer { "apache-balancer-oae-app-untrusted":
        vhost      => "${localconfig::http_name_untrusted}:443",
        location   => "/",
        proto      => "http",
        members    => $localconfig::apache_lb_members_untrusted,
        params     => $localconfig::apache_lb_params,
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

    ###########################################################################
    # Shibboleth

    $selinux = false

    class { 'shibboleth::sp':
        shibboleth2_xml_template   => 'localconfig/shibboleth2.xml.erb',
        attribute_map_xml_template => 'localconfig/attribute-map.xml.erb',
        sp_cert => 'puppet:///modules/localconfig/sp-cert.pem',
        sp_key  => 'puppet:///modules/localconfig/sp-key.pem',
    }
    class { 'shibboleth::shibd': }
    apache::module { 'shib': }

    file { "/var/www/vhosts/${localconfig::http_name}:443/conf/shib.conf":
        owner => root,
        group => root,
        mode  => 0644,
        content => template('localconfig/shib.conf'),
	    notify => Service['httpd'],
	    require => Package['shibboleth'],
    }

    file { "/etc/shibboleth/incommon.pem":
        owner => root,
        group => root,
        mode  => 0644,
        source => 'puppet:///modules/localconfig/incommon.pem',
	    notify => Service['httpd'],
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

    class { 'postgres::repos': stage => init }
    class { 'postgres::client': }

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
            'disable.protection.for.dev.mode' => $localconfig::sps_disabled,
            'trusted.hosts'  => [
                "localhost:8080\\ \\=\\ http://localhost:8081",
                "${localconfig::http_name}\\ \\=\\ https://${localconfig::http_name_untrusted}:443",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    # QoS filter rate-limits the app server so it won't fall over
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.qos.QoSFilter":
        config => { 'qos.default.limit' => 10, }
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

    # Keep an eye on caching in staging
    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config-caching':
        locked => false,
        config => {
            'org.apache.sling.commons.log.names' => ["org.sakaiproject.nakamura.memory","net.sf.ehcache"],
            'org.apache.sling.commons.log.level' => "info",
            'org.apache.sling.commons.log.file'  => "logs/cache.log",
            'service.factoryPid'                 => "org.apache.sling.commons.log.LogManager.factory.config",
        }
    }

    ###########################################################################
    # CLE integration
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
        config => {
            'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
            'sakai.cle.server.url'      => "https://${localconfig::http_name}",
            'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
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
}

node /app[1-2].academic.rsmart.local/ inherits oaeappnode { }

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
        tomcat_home  => "${localconfig::basedir}/tomcat",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
        setenv_template => 'localconfig/solr-setenv.sh.erb',
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
        upload_url     => "https://${localconfig::http_name}/",
        admin_password => $localconfig::admin_password,
        nakamura_git => $localconfig::nakamura_git,
        nakamura_tag => $localconfig::nakamura_tag,
    }
}

###########################################################################
#
# NFS Server
#
node 'nfs.academic.rsmart.local' inherits oaenode {

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
node 'dbserv1.academic.rsmart.local' inherits oaenode {

    class { 'postgres::repos': stage => init }

    class { 'postgres':
        postgresql_conf_template => 'localconfig/postgresql.conf.erb',
    }

    postgres::database { $localconfig::db:
        ensure => present,
        owner  => $localconfig::db_user,
        create_options => "ENCODING = 'UTF8' TABLESPACE = pg_default LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' CONNECTION LIMIT = -1",
        require  => Postgres::Role[$localconfig::user],
    }

    postgres::role { $localconfig::db_user:
        ensure   => present,
        password => $localconfig::db_password,
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
