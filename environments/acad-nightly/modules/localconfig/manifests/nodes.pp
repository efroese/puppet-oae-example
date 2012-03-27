###########################################################################
#
# rSmart nightly build server
# 
node 'nightly.academic.rsmart.local' inherits oaenode {
    
    ###########################################################################
    # System
    class { 'people::devops': }
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

    # https://nightly.academic.rsmart.com:443
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
            true  => ['/server-status', '/balancer-manager', '/access', '/imsblti'],
            false => ['/server-status', '/balancer-manager'],
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

    # https://nightly-content.academic.rsmart.com:443
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

    # Apache global config

    file { "/etc/httpd/conf.d/traceenable.conf":
        owner => root,
        group => root,
        mode  => 644,
        content => 'TraceEnable Off',
    }
    
    ###########################################################################
    # OAE App Servers

    class { 'oae::app::server':
        jarsource      => $localconfig::jarsource,
        java           => $localconfig::java,
        javamemorymin  => $localconfig::javamemorymin,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
        setenv_template => 'rsmart-common/setenv.sh.erb',
    }

    class { 'rsmart-common::logging':
        locked => false,
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-url'    => $localconfig::db_url,
            'jdbc-driver' => $localconfig::db_driver,
            'username'    => $localconfig::db_user,
            'password'    => $localconfig::db_password,
            'long-string-size' => 16384,
        },
	locked => false
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
        },
	locked => false
    }

    # Email integration
    oae::app::server::sling_config {
        'org.sakaiproject.nakamura.email.outgoing.LiteOutgoingEmailMessageListener':
        config => {
            'sakai.email.replyAsAddress' => $localconfig::reply_as_address,
            'sakai.email.replyAsName'    => $localconfig::reply_as_name,
        },
	locked => false
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
        config => {
             'sakai.cle.server.url'      => "https://${localconfig::http_name}",
             'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
             'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
        },
	locked => false
    }

    ###########################################################################
    # Preview processor
    class { 'oae::preview_processor::init':
        admin_password => $localconfig::admin_password,
        upload_url   => "https://${localconfig::http_name}/",
        nakamura_zip => $localconfig::nakamura_zip,
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
    file { "${localconfig::homedir}/sakaicle": ensure => directory }

    # Install tomcat 5.5.35 from a mirror and configure it
    class { 'tomcat6':
        parentdir            => "${localconfig::homedir}/sakaicle",
        tomcat_version       => '5.5.35',
        tomcat_major_version => '5',
        digest_string        => '1791951e1f2e03be9911e28c6145e177',
        tomcat_user          => $oae::params::user,
        tomcat_group         => $oae::params::group,
        java_home            => $localconfig::java_home,
        jvm_route            => $localconfig::cle_server_id,
        shutdown_password    => $localconfig::tomcat_shutdown_password,
        tomcat_conf_template => 'rsmart-common/cle-server.xml.erb',
        setenv_template      => 'rsmart-common/cle-setenv.sh.erb',
        jmxremote_access_template   => 'localconfig/jmxremote.access.erb',
        jmxremote_password_template => 'localconfig/jmxremote.password.erb',
        require => File["${localconfig::homedir}/sakaicle"],
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

    archive { 'upgrader_CLEv2.8.0.29':
        ensure         => present,
        url            => $localconfig::cle_tarball_url,
        digest_string  => $localconfig::cle_tarball_digest,
        src_target     => "${localconfig::homedir}/sakaicle/",
        target         => "${localconfig::homedir}/sakaicle/tomcat",
        creates        => "${localconfig::homedir}/sakaicle/tomcat/common/lib/sakai-kernel-common-1.2.1.jar",
        timeout        => '0',
        extension      => 'tar.bz2',
        allow_insecure => true,
        require        => File[$tomcat6::basedir],
        notify         => Exec["chown-apache-tomcat-5.5.35"],
    }

    file { "${localconfig::homedir}/sakaicle/sakai/files":
        ensure => link,
        target => "${localconfig::homedir}/sakaicle/tomcat/files",
        require => File[$tomcat6::basedir],
    }

    # CLE tomcat overlay and configuration
    class { 'cle':
        user             => $oae::params::user,
        basedir          => "${localconfig::homedir}/sakaicle",
        tomcat_home      => "${localconfig::homedir}/sakaicle/tomcat",
        server_id        => $localconfig::cle_server_id,
        db_url           => $localconfig::cle_db_url,
        db_user          => $localconfig::cle_db_user,
        db_password      => $localconfig::cle_db_password,
        linktool_salt    => $localconfig::linktool_salt,
        linktool_privkey => $localconfig::linktool_privkey,
        configuration_xml_template   => 'rsmart-common/cle-sakai-configuration.xml.erb',
        sakai_properties_template    => 'rsmart-common/sakai.properties.erb',
        local_properties_template    => 'rsmart-common/local.properties.erb',
        instance_properties_template => 'localconfig/instance.properties.erb',
        require                      => Mysql::Database[$localconfig::cle_db],
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

    augeas { "my.cnf/mysqld-rsmart":
        context => "${mysql::params::mycnfctx}/mysqld/",
        load_path => "/usr/share/augeas/lenses/contrib/",
        require => File["/etc/mysql/my.cnf"],
        notify => Service["mysql"],
        changes => [
            $rsmart-common::mysql::cle_changes,
        ],
    }

}
