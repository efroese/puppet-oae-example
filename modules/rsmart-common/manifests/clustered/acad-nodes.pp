###########################################################################
#
# Nodes
#

###########################################################################
#
# Apache load balancer
#
node /.*apache1.academic.rsmart.local/ inherits oaenode {

    class { 'localconfig::extra_users': }
    
    class { 'rsmart-common::oae::apache': }
    class { 'rsmart-common::oae::apache::http': }
    class { 'rsmart-common::oae::apache::trusted': }
    class { 'rsmart-common::oae::apache::untrusted': }

    # Balancer pool for CLE traffic
    apache::balancer { "apache-balancer-cle":
        vhost      => "${localconfig::http_name}:443",
        proto      => "ajp",
        members    => $localconfig::apache_cle_lb_members,
        params     => [ "timeout=300", "loadfactor=100" ],
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'rsmart-common/balancer-cle.conf.erb',
    }

    include people::kaleidoscope::internal
    include people::kaleidoscope::external
}

###########################################################################
#
# OAE app nodes
#
node oaeappnode inherits oaenode {

    class { 'localconfig::extra_users': }

    ###########################################################################
    # OAE, Sling
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
    class { 'rsmart-common::oae::cle': }
    class { 'rsmart-common::oae::email': }
    class { 'rsmart-common::oae::nfs': }
    class { 'rsmart-common::oae::postgres': }
    class { 'rsmart-common::oae::security': }
    class { 'rsmart-common::oae::solr::remote': }

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

    include people::kaleidoscope::internal

    ###########################################################################
    # Logs
    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config.cache-logger-uuid':
        config => {
            'service.factoryPid'                 => 'org.apache.sling.commons.log.LogManager.factory.config',
            'org.apache.sling.commons.log.names' => ['org.sakaiproject.nakamura.memory','net.sf.ehcache'],
            'org.apache.sling.commons.log.level' => 'info',
            'org.apache.sling.commons.log.file'  => 'logs/cache.log',
        }
    }

    ###########################################################################
    # HubSpot integration
    oae::app::server::sling_config {
        "com.rsmart.oae.registration.bundle.MarketingDataPostProcessor":
        config => {
            'postprocessor.enabled' => true,
        }
    }

    oae::app::server::sling_config {
        "com.rsmart.oae.registration.bundle.UserRegistrationEventHandler":
        config => {
            'handler.enabled' => true,
        }
    }

    oae::app::server::sling_config {
        "com.rsmart.oae.registration.bundle.UserRegistrationPreferencesUpdater":
        config => {
            'schedule.wait' => '180',
            'updater.enabled' => true,
        }
    }

    oae::app::server::sling_config {
        "com.rsmart.oae.user.hubspot.RestHubSpotService":
        config => {
            'hubspot.portalId' => $localconfig::hubspot_portalId,
            'hubspot.apiKey' => $localconfig::hubspot_apiKey,
            'hubspot.url' => $localconfig::hubspot_url,
            'campaignmap.refresh.interval' => '86400000',
        }
    }

    ###########################################################################
    # Configuration Override
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.dynamicconfig.file.FileBackedDynamicConfigurationServiceImpl":
        config => {
            'config.master.dir' => $localconfig::dynamic_config_root,
            'config.master.filename' => $localconfig::dynamic_config_masterfile,
            'config.custom.dir' => $localconfig::dynamic_config_customdir,
}
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.dynamicconfig.override.ConfigurationOverrideServiceImpl":
        config => {
            'override.dirs' => $localconfig::dynamic_config_jcroverrides,
        }
    }

    file { "${localconfig::dynamic_config_root}":
        ensure => directory
    }

    file { "${localconfig::dynamic_config_customdir}":
        ensure => directory,
        require => File[$localconfig::dynamic_config_root],
    }

    file { "${localconfig::dynamic_config_customdir}/config_custom.json":
        mode => 0644,
        content => template("rsmart-common/config_custom.json.erb"),
        require => File[$localconfig::dynamic_config_customdir],
    }

}

node /.*app[1-2].academic.rsmart.local/ inherits oaeappnode { }

###########################################################################
#
# OAE Solr Nodes
#

node /.*solr1.academic.rsmart.local/ inherits oaenode {

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

    class { 'solr::tomcat':
        basedir      => "${localconfig::basedir}/solr",
        user         => $localconfig::user,
        group        => $localconfig::group,
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

node /.*solr[2-3].academic.rsmart.local/ inherits solrnode {
    class { 'solr::tomcat':
        basedir      => "${localconfig::basedir}/solr",
        user         => $localconfig::user,
        group        => $localconfig::group,
        solr_tarball => $localconfig::solr_tarball,
        master_url   => "${localconfig::solr_remoteurl}/replication",
        solrconfig   => 'rsmart-common/slave-solrconfig.xml.erb',
        tomcat_home  => "${localconfig::basedir}/tomcat",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node /.*preview.academic.rsmart.local/ inherits oaenode {

    class { 'localconfig::extra_users': }

    class { 'oae::preview_processor::init':
        upload_url     => "https://${localconfig::http_name}/",
        admin_password => $localconfig::admin_password,
        nakamura_zip   => $localconfig::nakamura_zip,
    }

    class { 'kaleidoscope::analytics':
        user => $oae::params::user,
        basedir => $oae::params::basedir,
    }
}

###########################################################################
#
# NFS Server
#
node /.*nfs.academic.rsmart.local/ inherits oaenode {

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
node /.*dbserv1.academic.rsmart.local/ inherits oaenode {

    class { 'localconfig::extra_users': }

    class { 'postgres::repos': stage => init }

    class { 'postgres':
        postgresql_conf_template => 'rsmart-common/postgresql.conf.erb',
    }

    postgres::database { $localconfig::db:
        ensure => present,
        require  => Postgres::Role[$localconfig::user],
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

node /.*cle.academic.rsmart.local/ inherits oaenode {

    ###########################################################################
    #
    # CLE Server
    #

    class { 'tomcat6':
        parentdir            => "${localconfig::homedir}/sakaicle",
        tomcat_version       => '5.5.35',
        tomcat_major_version => '5',
        digest_string        => '1791951e1f2e03be9911e28c6145e177',
        tomcat_user          => $oae::params::user,
        tomcat_group         => $oae::params::group,
        java_home            => $localconfig::java_home,
        jmxremote_access_template   => 'rsmart-common/jmxremote.access.erb',
        jmxremote_password_template => 'rsmart-common/jmxremote.password.erb',
        jvm_route            => $localconfig::cle_server_id,
        shutdown_password    => $localconfig::tomcat_shutdown_password,
        tomcat_conf_template => 'rsmart-common/cle-server.xml.erb',
        setenv_template      => 'rsmart-common/cle-setenv.sh.erb',
    }

    # Base rSmart Tomcat customizations
    archive::download { 'rsmart-cle-base-overlay.tbz':
        ensure        => present,
        url           => 'http://dl.dropbox.com/u/24606888/rsmart-cle-base-overlay.tbz',
        src_target    => "${localconfig::homedir}/sakaicle/",
        checksum      => false,
        timeout       => 0,
        require       => Class['Tomcat6'],
    }

    tomcat6::overlay { 'rsmart-cle-base-overlay':
        tomcat_home  => "${localconfig::homedir}/sakaicle/tomcat",
        tarball_path => "${localconfig::homedir}/sakaicle/rsmart-cle-base-overlay.tbz",
        creates      => "${localconfig::homedir}/sakaicle/tomcat/webapps/ROOT/rsmart.jsp",
        user         => $oae::params::user,
        require      => [ Class['Tomcat6'], Archive::Download['rsmart-cle-base-overlay.tbz'], ],
    }

    # CLE install
    archive::download { 'rsmart-cle-prod-overlay.tbz':
        ensure        => present,
        url           => $localconfig::cle_tarball_url,
        src_target    => "${localconfig::homedir}/sakaicle/",
        checksum      => false,
        timeout       => 0,
        require       => Class['Tomcat6'],
    }

    tomcat6::overlay { 'rsmart-cle-prod-overlay':
        tomcat_home  => "${localconfig::homedir}/sakaicle/tomcat",
        tarball_path => "${localconfig::homedir}/sakaicle/rsmart-cle-prod-overlay.tbz",
        creates      => "${localconfig::homedir}/sakaicle/tomcat/webapps/xsl-portal.war",
        user         => $oae::params::user,
        require      => [ Class['Tomcat6'], Archive::Download['rsmart-cle-prod-overlay.tbz'], ],
    }

    # CLE tomcat overlay and configuration
    class { 'cle':
        user            => $oae::params::user,
        basedir         => "${localconfig::homedir}/sakaicle",
        tomcat_home     => "${localconfig::homedir}/sakaicle/tomcat",
        server_id       => $localconfig::cle_server_id,
        db_url          => $localconfig::cle_db_url,
        db_user         => $localconfig::cle_db_user,
        db_password     => $localconfig::cle_db_password,
        configuration_xml_template   => 'rsmart-common/cle-sakai-configuration.xml.erb',
        sakai_properties_template    => 'rsmart-common/sakai.properties.erb',
        local_properties_template    => 'localconfig/local.properties.erb',
        instance_properties_template => 'localconfig/instance.properties.erb',
        linktool_salt    => $localconfig::linktool_salt,
        linktool_privkey => $localconfig::linktool_privkey,
    }

    ###########################################################################
    #
    # MySQL Database Server
    #

    $mysql_password = $localconfig::mysql_root_password

    class { 'augeas': }
    class { 'mysql::server': }

    mysql::database{ $localconfig::cle_db:
        ensure   => present
    }

    mysql::rights{ "mysql-grant-${localconfig::cle_db}-${localconfig::cle_db_user}":
        ensure   => present,
        database => $localconfig::cle_db,
        user     => $localconfig::cle_db_user,
        password => $localconfig::cle_db_password,
    }
    augeas { "my.cnf/mysqld-lower_case_table_names-1":
        context => "${mysql::params::mycnfctx}/mysqld/",
        load_path => "/usr/share/augeas/lenses/contrib/",
        changes => [
          "set lower_case_table_names 1",
        ],
        require => File["/etc/mysql/my.cnf"],
        notify => Service["mysql"],
    }

}
