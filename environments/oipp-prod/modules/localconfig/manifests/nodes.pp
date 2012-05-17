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
node 'oipp-prod-apache1.academic.rsmart.local' inherits oaenode {

    class { 'rsmart-common::oae::apache': }
    class { 'rsmart-common::oae::apache::http': vhost_80_template => 'localconfig/vhost-80.conf.erb' }

    # http://uconline.edu to redirects to https://cole.uconline.edu
    apache::vhost { "uconline.edu:80":
        template => 'localconfig/vhost-80.conf.erb',
    }
    # http://www.uconline.edu to redirects to https://cole.uconline.edu
    apache::vhost { "www.uconline.edu:80":
        template => 'localconfig/vhost-80.conf.erb',
    }

    ###########################################################################
    # https://cole.uconline.edu

    # Serve the OAE app (trusted content) on 443
    apache::vhost-ssl { "${localconfig::http_name}:443":
        sslonly   => true,
        cert     => "puppet:///modules/localconfig/uconline.edu.crt",
        certkey  => "puppet:///modules/localconfig/uconline.edu.key",
        certchain => "puppet:///modules/localconfig/uconline.edu-intermediate.crt",
        template  => 'localconfig/vhost-trusted.conf.erb',
    }

    # Balancer pool for trusted content
    apache::balancer { "apache-balancer-oae-app":
        vhost      => "${localconfig::http_name}:443",
        location   => "/",
        locations_noproxy => $localconfig::mock_cle_content ? {
            # Don't proxy to the access and lti tools.
            # This is just a workaround, not a comprehensive list of CLE urls
            true  => ['/server-status', '/balancer-manager', '/Shibboleth.sso', '/access', '/imsblti'],
            false => ['/server-status', '/balancer-manager', '/Shibboleth.sso'],
        },
        proto      => "http",
        members    => $localconfig::apache_lb_members,
        params     => $localconfig::apache_lb_params,
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'rsmart-common/balancer-trusted.erb',
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
            template   => 'rsmart-common/balancer-cle.conf.erb',
        }
    }

    ###########################################################################
    # Serve untrusted content from another hostname
    apache::vhost-ssl { "${localconfig::http_name_untrusted}:443":
        sslonly   => true,
        cert     => "puppet:///modules/localconfig/uconline.edu.crt",
        certkey  => "puppet:///modules/localconfig/uconline.edu.key",
        certchain => "puppet:///modules/localconfig/uconline.edu-intermediate.crt",
        template  => 'rsmart-common/vhost-untrusted.conf.erb',
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

    ###########################################################################
    # Sendmail

    class { 'sendmail':
        sendmail_mc_template      => 'localconfig/sendmail.mc.erb',
        access_template           => 'localconfig/access.erb',
        mailertable_template      => 'localconfig/mailertable.erb',
        virtusertable_template    => 'localconfig/virtusertable.erb',
        local_host_names_template => 'localconfig/local-host-names.erb'
    }

    ###########################################################################
    # SIS integration
    class { 'oipp::sis':
        batch_school_properties => $localconfig::basic_sis_batch_school_properties,
        transfer_definitions => $localconfig::sis_batch_transfers,
        transfer_test_definitions => $localconfig::sis_test_batch_transfers,
        sis_error_archive => $localconfig::sis_archive_dir,
        use_scp => true,
        production => true,
    }

}

###########################################################################
#
# OAE app nodes
#
node oaeappnode inherits oaenode {

    class { 'oae::app::server':
        jarsource      => $localconfig::jarsource,
        java           => $localconfig::java,
        javamemorymin  => $localconfig::javamemorymin,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
        setenv_template => 'rsmart-common/setenv.sh.erb',
        store_dir       => $localconfig::storedir,
    }

    class { 'rsmart-common::logging': }
    class { 'rsmart-common::oae::app::cle': }
    class { 'rsmart-common::oae::app::email': }
    class { 'rsmart-common::oae::nfs': }
    class { 'rsmart-common::oae::app::postgres': }
    class { 'rsmart-common::oae::app::security': }
    class { 'rsmart-common::oae::app::solr::remote': }

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

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.auth.trusted.TrustedTokenServiceImpl":
        config => {
            'sakai.auth.trusted.server.secret' => $localconfig::trusted_shared_secret,
            'sakai.auth.trusted.server.safe-hostsaddress' =>
              '10.51.9.20;localhost;127.0.0.1;0:0:0:0:0:0:0:1%0',
            'sakai.auth.trusted.server.enabled' => true,
        }
    }

    ###########################################################################
    # Authentication 
    oae::app::server::sling_config {
        "com.rsmart.academic.authn.filter.AuthnTokenRemappingFilter":
        config => {
             'user.property'             => "eppn",
             'trusted.ip'                => "10.51.9.20",
             'authn.path'                => "/system/trustedauth",
             'authn.header'              => "sak3-user",
             'mapping.enabled'           => true,
        }
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.auth.trusted.TrustedAuthenticationServlet":
        config => {
             'sakai.auth.trusted.destination.default' => "/me"
        }
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.proxy.TrustedLoginTokenProxyPreProcessor":
        config => {
             'sharedSecret' => $localconfig::trusted_shared_secret,
        }
    }
    
    ###########################################################################
    # AppDynamics
    class { 'appdynamics':
        basedir => $oae::params::basedir,
    }

    ###########################################################################
    # SIS
    class { "people::oipp-sis::destination": }

    file { "$localconfig::oae_csv_dir":
        owner => $localconfig::user,
        group => $localconfig::user,
        mode  => 0770,
        ensure => directory,
    }

    file { "$localconfig::oae_csv_dir/test":
        owner => $localconfig::user,
        group => $localconfig::user,
        mode  => 0770,
        ensure => directory,
    }

    class { 'sis::batch':
        user              => $localconfig::user,
        executable_url    => $localconfig::basic_sis_batch_executable_url,
        artifact          => $localconfig::basic_sis_batch_executable_artifact,
        csv_dir           => $localconfig::oae_csv_dir,
        csv_object_types  => $localconfig::oae_csv_files,
        email_report      => $localconfig::basic_sis_batch_email_report,
        require           => [File["$localconfig::oae_csv_dir"], Ssh_authorized_key["root-rsmart-pub"]],
    }

    # ACAD-890 disable UCMerced
    # sis::batch::school { ['UCB', 'UCD', 'UCMerced', 'UCLA', ]:
    sis::batch::school { [ 'UCD', 'UCLA', ]:
        local_properties => 'localconfig/sis-local.properties.erb',
    }

}

node /oipp-prod-app[1-2].academic.rsmart.local/ inherits oaeappnode { }

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
        setenv_template => 'rsmart-common/solr-setenv.sh.erb',
    }
}

node 'oipp-prod-solr1.academic.rsmart.local' inherits solrnode {
    class { 'solr::tomcat':
        solr_tarball => $localconfig::solr_tarball,
        master_url   => "${localconfig::solr_remoteurl}/replication",
        solrconfig   => 'rsmart-common/master-solrconfig.xml.erb',
        tomcat_home  => "${localconfig::basedir}/tomcat",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }

    solr::backup { "solr-backup-${localconfig::solr_remoteurl}-${oae::params::basedir}/solr/backups":
       solr_url   => $localconfig::solr_remoteurl,
       backup_dir => "${oae::params::basedir}/solr/backups",
       user       => $oae::params::user,
       group      => $oae::params::group,
    }
}

node /oipp-prod-solr[2-3].academic.rsmart.local/ inherits solrnode {
    class { 'solr::tomcat':
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
node 'oipp-prod-preview.academic.rsmart.local' inherits oaenode {
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
node 'oipp-prod-nfs.academic.rsmart.local' inherits oaenode {

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
node 'oipp-prod-dbserv1.academic.rsmart.local' inherits oaenode {

    class { 'postgres::repos': stage => init }

    class { 'postgres':
        postgresql_conf_template => 'localconfig/postgresql.conf.erb',
    }

    postgres::database { $localconfig::db:
        ensure => present,
        owner  => $localconfig::db_user,
        create_options => "ENCODING = 'UTF8' TABLESPACE = pg_default LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' CONNECTION LIMIT = -1",
        require  => Postgres::Role[$localconfig::db_user],
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
