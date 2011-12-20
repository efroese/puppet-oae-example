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
    class {'preview_processor':}
    class {'preview_processor::gems':}
    class {'preview_processor::openoffice':}
}

###########################################################################
#
# Nodes
#

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

node 'centos5-oae-preview0.localdomain' inherits preview_processor_node { }

node 'centos6-oae-preview0.localdomain' inherits preview_processor_node { }

node /centos5-oae-app[0-9].localdomain/ inherits basenode {

    include oae::params
    include oae
    include oae::core

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

node 'centos5-solr0.localdomain' inherits basenode {

    include oae::params
    include oae

    class { 'oae-solr': 
        oae_version => '1.1-SNAPSHOT',
        role => 'master',
    }
}

node 'centos5-solr1.localdomain' inherits basenode {

    include oae::params
    include oae

    class { 'oae-solr': 
        oae_version => '1.1-SNAPSHOT',
        role => 'slave',
    }
}
