###########################################################################
#
# OIPP Standalone App Server
#
# 
node 'oipp-test.academic.rsmart.local' inherits oaenode {

    ###########################################################################
    # System
    class { 'rsmart-common::mysql': stage => init }

    ###########################################################################
    # Apache
    class { 'apache::ssl': }

    # Headers is not in the default set of enabled modules
    apache::module { 'headers': }
    apache::module { 'deflate': }

    # http://cole.uconline.edu to redirects to 443
    apache::vhost { "${localconfig::http_name}:80":
        template => 'rsmart-common/vhost-80.conf.erb',
    }

    ###########################################################################
    # https://cole.uconline.edu:443

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
    # https://oipp-test-content.academic.rsmart.com:443
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
    class { 'shibboleth::shibd':
        require => Class['Shibboleth::Sp'],
    }
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
	    notify => [ Service['httpd'], Service['shibd'], ],
    }

    ###########################################################################
    # SIS
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

    sis::batch::school { ['UCB', 'UCD', 'UCMerced', 'UCLA', ]:
        local_properties => 'localconfig/sis-local.properties.erb',
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
    # OAE App server
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

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-url'    => $localconfig::db_url,
            'jdbc-driver' => $localconfig::db_driver,
            'username'    => $localconfig::db_user,
            'password'    => $localconfig::db_password,
            'long-string-size' => 16384,
        }
    }

    # Separates trusted vs untrusted content.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
        config => {
            'disable.protection.for.dev.mode' => $localconfig::sps_disabled,
            'trusted.hosts'  => [
                "localhost:8080\\ \\=\\ http://localhost:8082",
                "${localconfig::http_name}\\ \\=\\ https://${localconfig::http_name_untrusted}",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    # Email integration
    oae::app::server::sling_config {
        'org.sakaiproject.nakamura.email.outgoing.LiteOutgoingEmailMessageListener':
        config => {
            'sakai.email.replyAsAddress' => $localconfig::reply_as_address,
            'sakai.email.replyAsName'    => $localconfig::reply_as_name,
        }
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.proxy.ProxyClientServiceImpl":
        config => {
            'flickr_api_key' => $localconfig::flickr_api_key,
        },
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.proxy.SlideshareProxyPreProcessor":
        config => {
            'slideshare.apiKey'       => $localconfig::slideshare_api_key,
            'slideshare.sharedSecret' => $localconfig::slideshare_shared_secret,
        },
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
        config => {
             'sakai.cle.server.url'      => "https://${localconfig::http_name}",
             'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
             'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
             'sakai.cle.basiclti.tool.list' => $localconfig::basiclti_tool_list,
        }
    }

    oae::app::server::sling_config {
        "com.rsmart.academic.authn.filter.AuthnTokenRemappingFilter":
        config => {
             'user.property'             => "eppn",
             'trusted.ip'                => "127.0.0.1",
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
    # Preview processor
    class { 'oae::preview_processor::init':
        admin_password => $localconfig::admin_password,
        upload_url     => "https://${localconfig::http_name}/",
        nakamura_zip   => $localconfig::nakamura_zip,
    }

    ###########################################################################
    #
    # Postgres Database Server
    #
    class { 'postgres::repos': stage => init }
    class { 'postgres':
        hba_conf_template => 'rsmart-common/standalone-pg_hba.conf.erb',
    }

    postgres::database { $localconfig::db:
        ensure => present,
        owner  => $localconfig::db_user,
        create_options => "ENCODING = 'UTF8' TABLESPACE = pg_default LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' CONNECTION LIMIT = -1",
        require => Postgres::Role[$localconfig::db_user]
    }

    postgres::role { $localconfig::db_user:
        ensure   => present,
        password => $localconfig::db_password,
    }

    postgres::backup::simple { $localconfig::db:
        date_format => ''
    }

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
        jmxremote_access_template   => 'localconfig/jmxremote.access.erb',
        jmxremote_password_template => 'localconfig/jmxremote.password.erb',
        jvm_route            => $localconfig::cle_server_id,
        shutdown_password    => $localconfig::tomcat_shutdown_password,
	    tomcat_conf_template => 'rsmart-common/cle-server.xml.erb',
	    setenv_template      => 'localconfig/cle-setenv.sh.erb',
    }

    archive { 'rsmart-tomcat-drivers-overlay':
        ensure         => present,
        url            => 'https://rsmart-releases.s3.amazonaws.com/Dev/CLE/rsmart-tomcat-drivers-overlay.tar.bz2',
        digest_string  => '3cb7b906cde983cb4b92e0268898c68b',
        src_target     => "${localconfig::homedir}/sakaicle/",
        target         => "${localconfig::homedir}/sakaicle/tomcat",
        creates        => "${localconfig::homedir}/sakaicle/tomcat/common/lib/mysql-connector-java-5.1.18-bin.jar",
        timeout        => '0',
        extension      => 'tar.bz2',
        allow_insecure => true,
        require        => File[$tomcat6::basedir],
        notify         => Exec["chown-apache-tomcat-5.5.35"],
    }

    archive { 'rsmart-tomcat-cle-base-overlay':
        ensure         => present,
        url            => 'http://dl.dropbox.com/u/24606888/rsmart-tomcat-cle-base-overlay.tar.bz2',
        digest_string  => '5d3ecd5500f50d7b9b4f7383e9220d30',
        src_target     => "${localconfig::homedir}/sakaicle/",
        target         => "${localconfig::homedir}/sakaicle/tomcat",
        creates        => "${localconfig::homedir}/sakaicle/tomcat/webapps/ROOT/rsmart.jsp",
        timeout        => '0',
        extension      => 'tar.bz2',
        allow_insecure => true,
        require        => File[$tomcat6::basedir],
        notify         => Exec["chown-apache-tomcat-5.5.35"],
    }

    # CLE install
    archive { 'rsmart-cle-prod-overlay':
        ensure         => present,
        url            => $localconfig::cle_tarball_url,
        checksum       => false,
        src_target     => "${localconfig::homedir}/sakaicle/",
        target         => "${localconfig::homedir}/sakaicle/tomcat",
        creates        => "${localconfig::homedir}/sakaicle/tomcat/webapps/xsl-portal.war",
        timeout        => 0,
        extension      => 'tar.bz2',
        allow_insecure => true,
        require        => File[$tomcat6::basedir],
        notify         => Exec["chown-apache-tomcat-5.5.35"],
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
        sakai_properties_template    => 'localconfig/sakai.properties.erb',
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

    augeas { "my.cnf/mysqld-rsmart-cle":
        context => "${mysql::params::mycnfctx}/mysqld/",
        load_path => "/usr/share/augeas/lenses/contrib/",
        changes => [
            $rsmart-common::mysql::cle_changes
        ],
        require => File["/etc/mysql/my.cnf"],
        notify => Service["mysql"],
    }

    class { 'oipp::sis':
        batch_school_properties => $localconfig::basic_sis_batch_school_properties,
        transfer_definitions => $localconfig::sis_batch_transfers,
        transfer_test_definitions => $localconfig::sis_test_batch_transfers,
        sis_error_archive => $localconfig::sis_archive_dir,
        use_scp => false,
        production => false,
    }
}