###########################################################################
#
# Nodes
#
# This is an example of how to set up a Sakai OAE Cluster with puppet.
#
# The example cluster consists of the following:
#
# Web tier - A highly available Apache HTTPd load balancer
# oae.localdomain     - 192.168.1.40 (floating ip address)
# oae-lb1.localdomain - 192.168.1.41
# oae-lb2.localdomain - 192.168.1.42
#
# App tier - 2 OAE application nodes. 1 preview processor.
# oae-app0.localdomain - 192.168.1.50
# oae-app1.localdomain - 192.168.1.51
# oae-preview0.localdomain - 192.168.1.80
#
# Search tier - 1 solr master and 3 slaves.
# oae-solr0.localdomain - 192.168.1.70 (master)
# oae-solr1.localdomain - 192.168.1.71 (slave)
# oae-solr2.localdomain - 192.168.1.72 (slave)
# oae-solr3.localdomain - 192.168.1.73 (slave)
#
# Storage tier - One Postgres database node.
# oae-db0.localdomain - 192.168.1.250
# oae-nfs.localdomain - 192.168.1.240
#

###########################################################################
#
# Apache Load Balancer
#
# The only active shared state between the load balancers is the virtual IP.
# Both of the servers have full copies of the apache configurations managed
# by puppet. As long as github is up and they each pull before they run
# puppet they'll both have the same configs. 
#
# Heartbeat and Pacemaker collaborate to manage the virtual ip.
#
node /oae-lb[1-2].localdomain/ inherits oaenode {

    $http_name            = $localconfig::apache_lb_http_name
    $sslcert_country      = "US"
    $sslcert_state        = "NY"
    $sslcert_locality     = "New York"
    $sslcert_organisation = "Compu-Global-Hyper-Mega-Net."

    class { 'apache::ssl': }
    class { 'pacemaker::apache': }

    # Server trusted content on 443
    apache::vhost-ssl { "${http_name}:443":
        sslonly  => true,
    }

    # Serve untrusted content from 8443
    # The puppet module takes care of 80 and 443 automatically.
    apache::listen { "8443": }
    apache::namevhost { "*:8443": }
    apache::vhost-ssl { "${http_name}:8443": 
        sslonly  => true,
        sslports => ['*:8443'],
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
        template   => 'localconfig/balancer.erb',
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

    # Pacemaker manages which machine is the active LB
    # TODO: parameterize the pacemaker module.
    $pacemaker_authkey   = $localconfig::apache_lb_pacemaker_authkey
    $pacemaker_interface = $localconfig::apache_lb_pacemaker_interface
    $pacemaker_nodes     = $localconfig::apache_lb_pacemaker_nodes
    # Configure heartbeat to monitor the health of the lb servers
    $pacemaker_hacf      = 'localconfig/ha.cf.erb'
    # Configure Pacemaker to manage the VIP and Apache
    $pacemaker_crmcli    = 'localconfig/crm-config.cli.erb'

    # The HA master will respond to the VIP
    $virtual_ip          = $localconfig::apache_lb_virtual_ip
    $virtual_netmask     = $localconfig::apache_lb_virtual_netmask
    $apache_lb_hostnames = $localconfig::apache_lb_hostnames

    class { 'pacemaker': }
}

###########################################################################
#
# OAE app nodes
#
node /oae-app[0-1].localdomain/ inherits oaenode {

    $http_name = $localconfig::apache_lb_http_name

    class { 'oae::app::server':
        downloadurl    => $localconfig::downloadurl,
        jarfile        => $localconfig::jarfile,
        javamemorymax  => $localconfig::javamemorymax,
        javamemorymin  => $localconfig::javamemorymin,
        javapermsize   => $localconfig::javapermsize,
    }

    class { 'oae::app::ehcache':
        mcast_address => $localconfig::mcast_address,
        mcast_port    => $localconfig::mcast_port,
    }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-url'    => $localconfig::db_url,
            'jdbc-driver' => $localconfig::db_driver,
            'username'    => $localconfig::db_user,
            'password'    => $localconfig::db_password,
        }
    }

    # Separates trusted vs untusted content.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
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
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.MultiMasterRemoteSolrClient":
        config => {
            "remoteurl"  => $localconfig::solr_remoteurl,
            "query-urls" => $localconfig::solr_queryurls,
        }
    }

    # Specify the client type
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.SolrServerServiceImpl":
        config => {
            "solr-impl" => "multiremote",
        }
    }

    # Clustering
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.cluster.ClusterTrackingServiceImpl":
        config => {
            'secure-host-url' => "http://${ipaddress}:8081",
        }
    }

    # Clustered Cache
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.memory.CacheManagerServiceImpl":
        config => {
            'bind-address' => $ipaddress,
        }
    }
}

###########################################################################
#
# OAE Solr Nodes
#

node solrnode inherits oaenode {
    class { 'oae::solr': }

    class { 'tomcat6':
        parentdir => "${localconfig::basedir}",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }
}

node 'oae-solr0.localdomain' inherits solrnode {

    class { 'oae::solr::tomcat':
        master_url => "$localconfig::solr_remoteurl/replication",
        solrconfig => 'localconfig/master-solrconfig.xml.erb',
        tomcat_home  => "${localconfig::basedir}/tomcat",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
    }

    oae::solr::backup { "backup-${localconfig::solr_remoteurl}":
        solr_url   => $localconfig::solr_remoteurl,
        backup_dir => "${oae::params::basedir}/solr/backups",
        user       => $oae::params::user,
        group      => $oae::params::group,
    }
}

node /oae-solr[1-3].localdomain/ inherits solrnode {

    class { 'oae::solr::tomcat':
        master_url => "$localconfig::solr_remoteurl/replication",
        solrconfig => 'localconfig/slave-solrconfig.xml.erb',
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group, 
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'oae-preview0.localdomain' inherits oaenode {
    class { 'oae::preview_processor::init': 
        nakamura_git => $localconfig::nakamura_git,
        nakamura_tag => $localconfig::nakamura_tag,
    }
}

###########################################################################
#
# Postgres Database Server
#
node 'oae-db0.localdomain' inherits oaenode {

    class { 'postgres': }

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
       address => "$ipaddress/24",
       method  => 'md5',
    }

    postgres::backup::simple { $localconfig::db:
        ensure => present,
    }
}

###########################################################################
#
# NFS Server
#
node 'oae-nfs.localdomain' inherits oaenode {

    class { 'nfs::server': }

    nfs::export { 'export-sakai-files-app0-app1-rw':
        ensure  => present,
        share   => '/export/sakaioae/files',
        options => 'rw',
        guests   => [
            [ $localconfig::app_server0, 'rw' ],
            [ $localconfig::app_server1, 'rw' ],
        ],
    }
}
