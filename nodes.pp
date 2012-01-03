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

###########################################################################
#
# Apache Load Balancer
#
node /oae-lb[1-2].localdomain/ inherits basenode {

    class { 'oae::params': }
    class { 'apache': }
    class { 'pacemaker::apache': }

    # The HA master will respond to the VIP
    $http_name = 'oae.localdomain'
    $virtual_ip = '192.168.1.40'
    $virtual_netmask = '255.255.255.0'
    $apache_lb_hostnames = ['oae-lb1.localdomain', 'oae-lb2.localdomain']

    apache::vhost { $http_name: }
    apache::balancer { "apache-balancer-oae-app":
        location   => "/",
        proto      => "http",
        members    => [
          "192.168.1.50:8080",
          "192.168.1.51:8080",
        ],
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => "http://sorryserver.cluster/",
        vhost      => $http_name,
    }

    # Pacemaker manages which machine is the active LB
    # TODO: parameterize the pacemaker module.
    $pacemaker_authkey   = 'oaehbkey'
    $pacemaker_interface = 'eth0'
    $pacemaker_hacf      = 'localconfig/ha.cf.erb'
    $pacemaker_crmcli    = 'localconfig/crm-config.cli.erb'
    $pacemaker_nodes     = [ '192.168.1.41', '192.168.1.42']
    include pacemaker
}

###########################################################################
#
# OAE app nodes
#
node /oae-app[0-1].localdomain/ inherits basenode {

    $http_name = 'oae.localdomain'

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
         driver => "jdbc:mysql://192.168.1.250:3306/nakamura?autoReconnectForPools\\=true",
         url    => 'com.mysql.jdbc.Driver',
         user   => 'nakamura',
         pass   => 'ironchef',
    }

    class { 'oae::app::ehcache':
        mcast_address => '230.0.0.2',
        mcast_port    => '8450',
    }

    $serverprotectsec = 'shh-its@secret'
    oae::sling_config { "org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/http/usercontent",
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => " ${http_name}:8080 = https://${http_name}:443 ", 
            'trusted.secret' => $serverprotectsec,
        }
    }

    oae::sling_config { "org/sakaiproject/nakamura/solr/MultiMasterRemoteSolrClient.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "remoteurl"  => "http://192.168.1.70:8983/solr",
            "query-urls" => "http://192.168.1.71:8983/solr",
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
node 'oae-solr0.localdomain' inherits basenode {

    include oae::params
    include oae

    class { 'oae::solr': 
        solrconfig => 'localconfig/master-solrconfig.xml.erb',
    }
}

node 'oae-solr1.localdomain' inherits basenode {

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
node 'oae-preview0.localdomain' inherits basenode {
    class { 'oae::preview_processor': }
}

###########################################################################
#
# MySQL Database Server
#
node 'oae-db0.localdomain' inherits basenode {

    $mysql_password = 'seequelle'

    include augeas
    include mysql::server

    mysql::database { 'nakamura':
        ensure   => present
    }

    mysql::rights {"Set rights for puppet database":
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura',
        password => 'ironchef'
    }

    # R/W from the app nodes
    mysql::rights { "oae-app0-nakamura":
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura@192.68.1.50',
        password => 'ironchef'
    }

    mysql::rights { "oae-app1-nakamura":
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura@192.68.1.51',
        password => 'ironchef'
    }
}
