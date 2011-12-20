###########################################################################
#
# Nodes
#
# This is an example of how to set up a Sakai OAE Cluster with puppet.
#
# This is still a work in progress.
#
# One Apache HTTPD load balancer in front of two OAE app nodes.
# centos5-oae-lb - 192.168.1.40
# centos5-oae-app0 - 192.168.1.50
# centos5-oae-app1 - 192.168.1.51
#
# A pair of solr nodes, one master and one slave.
# centos5-solr0    - 192.168.1.70 (master)
# centos5-solr1    - 192.168.1.71 (slave)
#
# One MySQL database node.
# (MySQL replication is not one of my priorities right now)
# centos5-db0    - 192.168.1.250
#
# One OAE Content Preview Processor
# centos5-oae-preview0 - 192.168.1.80
#

###########################################################################
#
# Node Type Definitions
#
node basenode {
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

#
# Sakai OAE Content Preview Processor
#
node preview_processor_node inherits basenode {
    class {'oae::preview_processor':}
    class {'oae::preview_processor::gems':}
    class {'oae::preview_processor::openoffice':}
}

###########################################################################
#
# OAE app nodes
#
node /centos5-oae-app[0-1].localdomain/ inherits basenode {

    include oae::params
    include oae::core
    include oae

    class { 'oae::app':
        version_oae    => '1.1',
        downloaddir    => 'http://192.168.1.124/jars/',
        jarfile        => 'org.sakaiproject.nakamura.app-1.1-mysql.jar',
        javamemorymax  => '512',
        javapermsize   => '256',
    }

    oae::sling_config { "org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/http/usercontent",
        pid     => '"org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl"',
        config => {
            'trusted.secret'          => "\"${oae::params::serverprotectsec}\"",
            'untrusted.contenturl'    => "\"http://${oae::params::httpd_name_content}\"",
            'untrusted.redirect.host' => "\"${oae::params::http_content}://${oae::params::httpd_name_content}\"",
            'trusted.postwhitelist'   => "[\"/system/console\"]",
            'disable.protection.for.dev.mode' => 'B"false"',
            'trusted.hosts'           => " $ipaddress:8080 = https://192.168.1.40:443 ", 

            'trusted.referer'         => $oae::params::install_http_admin ? {
                true     => "[\"http://${oae::params::httpd_name}\",\"https://${oae::params::httpd_name}\",\"http://${ipaddress_eth0}\",\"https://${ipaddress_eth0}\",\"http://${ipaddress_eth0}:8080\",\"http://${oae::params::httpd_name_admin}\",\"https://${oae::params::httpd_name_admin}:${oae::params::admin_port}\",\"http://localhost:8080\",\"/\"]",
                default  => "[\"http://${oae::params::httpd_name}\",\"https://${oae::params::httpd_name}\",\"http://${ipaddress_eth0}\",\"https://${ipaddress_eth0}\",\"http://${ipaddress_eth0}:8080\",\"http://localhost:8080\",\"/\"]",
            },
        }
    }

    oae::sling_config { "org/sakaiproject/nakamura/solr/MultiMasterRemoteSolrClient.config":
        dirname => "org/sakaiproject/nakamura/solr",
        pid     => '"org.sakaiproject.nakamura.solr.MultiMasterRemoteSolrClient"',
        config => {
            "query-urls" => '"http://192.168.1.70:8983/solr|http://192.168.1.71:8983/solr"',
        }
    }

    oae::sling_config { "org/sakaiproject/nakamura/solr/SolrServerServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/solr",
        pid     => '"org.sakaiproject.nakamura.solr.SolrServerServiceImpl"',
        config => {
            "solr-impl" => '"multiremote"',
        }
    }
}

###########################################################################
#
# OAE Solr Nodes
#
node 'centos5-solr0.localdomain' inherits basenode {

    include oae::params
    include oae

    class { 'oae::solr': 
        oae_version => '1.1-SNAPSHOT',
        role => 'master',
    }
}

node 'centos5-solr1.localdomain' inherits basenode {

    include oae::params
    include oae

    class { 'oae::solr': 
        oae_version => '1.1-SNAPSHOT',
        role => 'slave',
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'centos5-oae-preview0.localdomain' inherits preview_processor_node { }

###########################################################################
#
# MySQL Database Server
#
node 'centos5-oae-db0.localdomain' inherits basenode {

    $mysql_password = 'seequelle'

    include augeas
    include mysql::server

    mysql::database{ 'nakamura':
        ensure   => present
    }

    mysql::rights {"Set rights for puppet database":
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura',
        password => 'ironchef'
    }

    # R/W from the app nodes
    mysql::rights { "centos5-oae-app0": 
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura@192.68.1.50',
        password => 'ironchef'
    }

    mysql::rights { "centos5-oae-app1": 
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura@192.68.1.51',
        password => 'ironchef'
    }
}
