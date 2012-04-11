###########################################################################
#
# OIPP Standalone App Server
#
# 
node 'dashboard-qa.rsmart.local' inherits dashboardnode {

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
    # https://dashboard.qa.rsmart.com:443

    # Serve the OAE app (trusted content) on 443
    apache::vhost-ssl { "${localconfig::http_name}:443":
        sslonly  => true,
        cert     => "puppet:///modules/rsmart-common/academic.rsmart.com.crt",
        certkey  => "puppet:///modules/rsmart-common/academic.rsmart.com.key",
        certchain => "puppet:///modules/rsmart-common/academic.rsmart.com-intermediate.crt",
        template  => 'localconfig/vhost-trusted.conf.erb',
    }

    # Balancer pool for trusted content
    apache::balancer { "apache-balancer-dashboard-app":
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


    ###########################################################################
    # Apache global config

    file { "/etc/httpd/conf.d/traceenable.conf":
        owner => root,
        group => root,
        mode  => 644,
        content => 'TraceEnable Off',
    }


    ###########################################################################
    #
    # MySQL Database Server
    #

    $mysql_password = 'khjRE7AftLfB'

    class { 'augeas': }
    class { 'mysql::server': }

    mysql::database{ $localconfig::db:
        ensure   => present
    }

    mysql::rights{ "mysql-grant-${localconfig::db}-${localconfig::db_user}":
        ensure   => present,
        database => $localconfig::db,
        user     => $localconfig::db_user,
        password => $localconfig::db_password,
    }

    augeas { "my.cnf/mysqld-rsmart-dashboard":
        context => "${mysql::params::mycnfctx}/mysqld/",
        load_path => "/usr/share/augeas/lenses/contrib/",
        require => File["/etc/mysql/my.cnf"],
        notify => Service["mysql"],
        changes => [
            $rsmart-common::mysql::cle_changes,
        ],
    }
	
	
    ###########################################################################
    #
    # Dashboard Server
    #
	
    file { ["/app", $localconfig::basedir]:
        ensure => directory,
        owner  => $localconfig::user,
        group  => $localconfig::group,
   		mode   => 750,
	}

    # Install tomcat 5.5.35 from a mirror and configure it
    class { 'tomcat6':
        parentdir            => $localconfig::basedir,
        tomcat_version       => '5.5.35',
        tomcat_major_version => '5',
        digest_string        => '1791951e1f2e03be9911e28c6145e177',
        tomcat_user          => $localconfig::user,
        tomcat_group         => $localconfig::group,
        jvm_route            => $localconfig::server_id, #??
        shutdown_password    => $localconfig::tomcat_shutdown_password,
        tomcat_conf_template => 'rsmart-common/dashboard-server.xml.erb',
        setenv_template      => 'rsmart-common/dashboard-setenv.sh.erb',
        jmxremote_access_template   => 'localconfig/jmxremote.access.erb',
        jmxremote_password_template => 'localconfig/jmxremote.password.erb',
        require => File[$localconfig::basedir],
    }
	
    class { 'dashboard::app::server':
        bin_source      => $localconfig::bin_source,
		bin_target_dir  => "${localconfig::basedir}/tomcat/webapps",
		deploy          => "true",
		config_file     => $localconfig::dashboard_config,
        java            => $localconfig::java,
        javamemorymin   => $localconfig::javamemorymin,
        javamemorymax   => $localconfig::javamemorymax,
        javapermsize    => $localconfig::javapermsize,
		basedir			=> $localconfig::basedir,
		user 			=> $localconfig::user,
		group 			=> $localconfig::group,
    }
	
	
}
