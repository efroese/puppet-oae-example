###########################################################################
#
# OIPP Standalone App Server
#
# 
node /oipp-test[2]?.academic.rsmart.local/ inherits oaenode {
    
    class { 'apache::ssl': }

    # Headers is not in the default set of enabled modules
    apache::module { 'headers': }
    apache::module { 'deflate': }

    # http://cole.uconline.edu to redirects to 443
    apache::vhost { "${localconfig::http_name}:80":
        template => 'localconfig/vhost-80.conf.erb',
    }

    ###########################################################################
    # https://cole.uconline.edu:443

    # Serve the OAE app (trusted content) on 443
    apache::vhost-ssl { "${localconfig::http_name}:443":
        sslonly  => true,
        cert     => "puppet:///modules/localconfig/academic.rsmart.com.crt",
        certkey  => "puppet:///modules/localconfig/academic.rsmart.com.key",
        certchain => "puppet:///modules/localconfig/academic.rsmart.com-intermediate.crt",
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
    # https://oipp-test-content.academic.rsmart.com:443
    apache::vhost-ssl { "${localconfig::http_name_untrusted}:443":
        sslonly  => true,
        cert     => "puppet:///modules/localconfig/academic.rsmart.com.crt",
        certkey  => "puppet:///modules/localconfig/academic.rsmart.com.key",
        certchain => "puppet:///modules/localconfig/academic.rsmart.com-intermediate.crt",
        template  => 'localconfig/vhost-8443.conf.erb',
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
    }

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

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts' => " localhost:8080 = http://localhost:8082, ${localconfig::http_name}:8088 = https://${localconfig::http_name}:8083 ",
            'trusted.secet' => $localconfig::serverprotectsec,
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
             'sakai.cle.server.url'      => "https://${localconfig::cle_server}/",
             'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
             'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
        }
    }

    ###########################################################################
    # Preview processor
    class { 'oae::preview_processor::init':
        upload_url   => "https://${localconfig::http_name}/",
        nakamura_git => $localconfig::nakamura_git,
        nakamura_tag => $localconfig::nakamura_tag,
    }

    ###########################################################################
    #
    # Postgres Database Server
    #
    class { 'postgres::repos': stage => init }
    class { 'postgres':
        hba_conf_template => 'localconfig/pg_hba.conf.erb',
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
}
