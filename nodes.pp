###########################################################################
#
# Nodes
#
# This is an example of how to set up a Sakai OAE Cluster with puppet.
#
# A pair of highly available Apache HTTPd load balancers
# oae     - 192.168.1.40 (floating ip address)
# oae-lb1 - 192.168.1.41
# oae-lb2 - 192.168.1.42
#
# A pair of OAE app nodes.
# oae-app0 - 192.168.1.50
# oae-app1 - 192.168.1.51
#
# A pair of solr nodes, one master and one slave.
# oae-solr0 - 192.168.1.70 (master)
# oae-solr1 - 192.168.1.71 (slave)
#
# One MySQL database node.
# oae-db0 - 192.168.1.250
#
# One OAE Content Preview Processor
# oae-preview0 - 192.168.1.80
#

###########################################################################
#
# Node Type Definitions
#
node basenode {
    include hosts 
    include users
    include git
    include java

    if $operatingsystem == 'CentOS' {
        include centos

        if $virtual == "virtualbox" {
            include centos_minimal
        }
    }

    class { 'ntp':
        time_zone =>  '/usr/share/zoneinfo/America/Phoenix',
    }
}

node oaenode inherits basenode {
    # OAE cluster-specific configuration
    class { 'localconfig': }
}

###########################################################################
#
# Apache Load Balancer
#
node /oae-lb[1-2].localdomain/ inherits oaenode {

    class { 'oae::params': }
    
    class { 'apache': }
    class { 'pacemaker::apache': }

    # The HA master will respond to the VIP
    $http_name           = $localconfig::apache_lb_http_name
    $virtual_ip          = $localconfig::apache_lb_virtual_ip
    $virtual_netmask     = $localconfig::apache_lb_virtual_netmask
    $apache_lb_hostnames = $localconfig::apache_lb_hostnames

    apache::vhost { $http_name: }
    apache::balancer { "apache-balancer-oae-app":
        location   => "/",
        proto      => "http",
        members    => [
          "192.168.1.50:8080",
          "192.168.1.51:8080",
        ],
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => $localconfig::apache_lb_standbyurl,
        vhost      => $http_name,
    }

    # Pacemaker manages which machine is the active LB
    # TODO: parameterize the pacemaker module.
    $pacemaker_authkey   = $localconfig::apache_pacemaker_authkey
    $pacemaker_interface = $localconfig::apache_pacemaker_interface
    $pacemaker_nodes     = $localconfig::apache_pacemaker_nodes
    $pacemaker_hacf      = 'localconfig/ha.cf.erb'
    $pacemaker_crmcli    = 'localconfig/crm-config.cli.erb'
    include pacemaker
}

###########################################################################
#
# OAE app nodes
#
node /oae-app[0-1].localdomain/ inherits oaenode {

    $http_name = $localconfig::apache_lb_http_name

    class { 'oae::params': }
    class { 'oae': }

    class { 'oae::app::server':
        version_oae    => '1.1',
        downloaddir    => 'http://192.168.1.124/jars/',
        jarfile        => 'org.sakaiproject.nakamura.app-1.1-mysql.jar',
        javamemorymax  => '512',
        javapermsize   => '256',
    }

    class { 'oae::core':
         url    => $localconfig::db_url,
         driver => $localconfig::db_driver,
         user   => $localconfig::db_user,
         pass   => $localconfig::db_password,
    }

    class { 'oae::app::ehcache':
        mcast_address => $localconfig::mcast_address,
        mcast_port    => $localconfig::mcast_port,
    }

    oae::sling_config { "org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/http/usercontent",
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => " ${http_name}:8080 = https://${http_name}:443 ", 
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    oae::sling_config { "org/sakaiproject/nakamura/solr/MultiMasterRemoteSolrClient.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "remoteurl"  => $localconfig::solr_remoteurl,
            "query-urls" => $localconfig::solr_queryurls,
        }
    }

    oae::sling_config { "org/sakaiproject/nakamura/solr/SolrServerServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "solr-impl" => "multiremote",
        }
    }
}

###########################################################################
#
# OAE Solr Nodes
#

node 'oae-solr0.localdomain' inherits oaenode {

    include oae::params
    include oae

    class { 'oae::solr': 
        solrconfig => 'localconfig/master-solrconfig.xml.erb',
    }
}

node 'oae-solr1.localdomain' inherits oaenode {

    include oae::params
    include oae

    class { 'oae::solr': 
        solrconfig => 'localconfig/slave-solrconfig.xml.erb',
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'oae-preview0.localdomain' inherits oaenode {
    class { 'oae::preview_processor': }
}

###########################################################################
#
# MySQL Database Server
#
node 'oae-db0.localdomain' inherits oaenode {

    include augeas
    include mysql::server

    mysql::database { "${localconfig::db}":
        ensure   => present
    }

    mysql::rights { "Set rights for puppet database":
        ensure   => present,
        database => $localconfig::db,
        user     => $localconfig::db_user,
        password => $localconfig::db_password,
    }

    # R/W from the app nodes
    mysql::rights { "oae-app0-nakamura":
        ensure   => present,
        database => $localconfig::db_user,
        user     => "${localconfig::db_user}@${localconfig::app_server0}",
        password => $localconfig::db_password
    }

    mysql::rights { "oae-app1-nakamura":
        ensure   => present,
        database => $localconfig::db_user,
        user     => "${localconfig::db_user}@${localconfig::app_server0}",
        password => $localconfig::db_password,
    }
}
