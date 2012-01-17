###########################################################################
#
# Nodes
#
# make sure that modules/localconfig -> modules/rsmart-config-m1
# see modules/rsmart-config-m1/manifests.init.pp for the config.


###########################################################################
#
# Apache load balancer
#

node /staging-apache[1-2].academic..rsmart.local/ inherits oaenode {

    $http_name = $localconfig::http_name

    class { 'apache::ssl': }

    # Headers is not in the default set of enabled modules
    apache::module { 'headers': }

    # Simple vhost to redirect to 443
    apache::vhost {
        template => 'localconfig/vhost-80.conf.erb',
    }

    # Server trusted content on 443
    apache::vhost-ssl { "${http_name}:443":
        sslonly  => true,
        cert     => "/etc/pki/tls/certs/rsmart.com.crt",
        certkey  => "/etc/pki/tls/private/rsmart.com.key",
        certchain => "/etc/pki/tls/certs/rsmart.com-intermediate.crt",
    }

    # Server pool for trusted content
    apache::balancer { "apache-balancer-oae-app":
        vhost      => "${http_name}:443",
        location   => "/",
        locations_noproxy => ['/server-status', '/balancer-manager'],
        proto      => "http",
        members    => $localconfig::apache_lb_members,
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'localconfig/balancer-trusted.erb',
    }

    # Server pool for CLE
    apache::balancer { "apache-balancer-cle":
        vhost      => "${http_name}:443",
        proto      => "ajp",
        members    => $localconfig::apache_cle_lb_members,
        params     => [ "timeout=300", "loadfactor=100" ],
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'localconfig/balancer-cle.erb',
    }

    # Serve untrusted content from 8443
    # The puppet module takes care of 80 and 443 automatically.
    apache::listen { "8443": }
    apache::namevhost { "*:8443": }
    apache::vhost-ssl { "${http_name}:8443": 
        sslonly  => true,
        sslports => ['*:8443'],
        cert     => "/etc/pki/tls/certs/rsmart.com.crt",
        certkey  => "/etc/pki/tls/private/rsmart.com.key",
        certchain => "/etc/pki/tls/certs/rsmart.com-intermediate.crt",
    }

    # Server pool for untrusted content
    apache::balancer { "apache-balancer-oae-app-untrusted":
        vhost      => "${http_name}:8443",
        location   => "/",
        proto      => "http",
        members    => $localconfig::apache_lb_members_untrusted,
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => $localconfig::apache_lb_standbyurl,
    }

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

    $http_name = $localconfig::http_name

    class { 'oae::app::server':
        jarsource      => $localconfig::jarsource,
        jarfile        => $localconfig::jarfile,
        javamemorymin  => $localconfig::javamemorymin,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
    }
    
    # NFS mounted shated storage for content bodies
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
    oae::app::server::sling_config { "org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config":
        dirname => "org/sakaiproject/nakamura/lite/storage/jdbc",
        config => {
            'jdbc-driver' => $localconfig::db_driver,
            'jdbc-url'    => $localconfig::db_url,
            'username'    => $localconfig::db_user,
            'password'    => $localconfig::db_password,
            'long-string-size' => 16384,
            'store-base-dir'   => $localconfig::storedir,
        }
    }

    # Separates trusted vs untrusted content.
    oae::app::server::sling_config { "org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/http/usercontent",
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => [
                "localhost\\ \\=\\ https://localhost:8443", 
                "${http_name}\\ \\=\\ https://${http_name}:8443",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    # Solr Client
    oae::app::server::sling_config { "org/sakaiproject/nakamura/solr/MultiMasterRemoteSolrClient.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "remoteurl"  => $localconfig::solr_remoteurl,
            "query-urls" => $localconfig::solr_queryurls,
        }
    }

    # Specify the client type
    oae::app::server::sling_config { "org/sakaiproject/nakamura/solr/SolrServerServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "solr-impl" => "multiremote",
        }
    }

    # Clustering
    # Note that IP address will be evaluated ON the node. Not in this nodetype
    oae::app::server::sling_config { "org/sakaiproject/nakamura/cluster/ClusterTrackingServiceImpl.config":
        dirname => 'org/sakaiproject/nakamura/cluster',
        config => {
            'secure-host-url' => "http://${ipaddress}:8081",
        }
    }

    # Clustered Cache
    oae::app::server::sling_config { "org/sakaiproject/nakamura/memory/CacheManagerServiceImpl.config":
        dirname => 'org/sakaiproject/nakamura/memory',
        config => {
            'bind-address' => $ipaddress,
        }
    }

    # CLE integration
    oae::app::server::sling_config { "org/sakaiproject/nakamura/basiclti/CLEVirtualToolDataProvider.config":
        dirname => "org/sakaiproject/nakamura/basiclti",
        config => {
            'sakai.cle.basiclti.secret' => "secret",
            'sakai.cle.server.url'      => "https://${http_name}",
            'sakai.cle.basiclti.key'    => "12345",
        }
    }

    # QoS filter
    oae::app::server::sling_config { "org/sakaiproject/nakamura/http/qos/QoSFilter.config":
        dirname => "org/sakaiproject/nakamura/http/qos",
        config => {
            'qos.default.limit' => 50,
        }
    }
}

node 'staging-app1.academic.rsmart.local' inherits oaeappnode {
    class { 'oae::app::ehcache':
        # 2 nodes, each others peer.
        peers       => [ $localconfig::app_server2, ],
        tcp_address => $localconfig::ehcache_tcp_port,
    }
}

node 'staging-app2.academic.rsmart.local' inherits oaeappnode {
    class { 'oae::app::ehcache':
        peers       => [ $localconfig::app_server1, ],
        tcp_address => $localconfig::ehcache_tcp_port,
    }
}

###########################################################################
#
# OAE Solr Nodes
#

node solrnode inherits oaenode {
    class { 'tomcat6':
            parentdir => "${localconfig::basedir}",
            tomcat_user           => $localconfig::user,
            tomcat_group          => $localconfig::group,
            admin_user            => 'tomcat',
            admin_password        => 'wolverine',
    }
}

node 'staging-solr1.academic.rsmart.local' inherits solrnode {
    class { 'oae::solr::tomcat': 
        master_url => "${localconfig::solr_remoteurl}/replication",
        solrconfig => 'localconfig/master-solrconfig.xml.erb',
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'staging-preview.academic.rsmart.local' inherits oaenode {
    class { 'oae::preview_processor::init': 
        nakamura_git => $localconfig::nakamura_git,
        nakamura_tag => $localconfig::nakamura_tag,
    }
}
