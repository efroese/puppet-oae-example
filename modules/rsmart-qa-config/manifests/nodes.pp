###########################################################################
#
# OIPP Standalone App Server
#
# 
node /qa.academic.rsmart.local/ inherits oaenode {

    ###########################################################################
    # System

    limits::conf {
        "${localconfig::user}-soft": domain => $localconfig::user, type => soft, item => nofile, value => 20000;
        "${localconfig::user}-hard": domain => $localconfig::user, type => hard, item => nofile, value => 20000;
    }

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
    # Apache global config

    file { "/etc/httpd/conf.d/traceenable.conf":
        owner => root,
        group => root,
        mode  => 644,
        content => 'TraceEnable Off',
    }

    class { 'oae::app::server':
        jarsource      => $localconfig::jarsource,
        jarfile        => $localconfig::jarfile,
        java           => $localconfig::java,
        javamemorymin  => $localconfig::javamemorymin,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
        setenv_template => 'rsmart-common/setenv.sh.erb',
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
        "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
        config => {
             'sakai.cle.server.url'      => "https://${localconfig::http_name}",
             'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
             'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
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
    # MySQL Database Server
    #

    $mysql_password = 'khjRE7AftLfB'

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
