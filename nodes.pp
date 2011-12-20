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

    mysql::rights{"Set rights for puppet database":
        ensure   => present,
        database => 'nakamura',
        user     => 'nakamura',
        password => 'ironchef'
    }
}

node 'centos5-oae-preview0.localdomain' inherits preview_processor_node { }

node 'centos6-oae-preview0.localdomain' inherits preview_processor_node { }

node 'centos5-oae-app0.localdomain' inherits basenode {

    include oae::params

    class { 'oae-app':
        version_oae    => '1.1-SNAPSHOT',
        downloaddir    => 'http://source.sakaiproject.org/maven2-snapshots/org/sakaiproject/nakamura/org.sakaiproject.nakamura.app/1.1-SNAPSHOT/',
        jarfile        => 'org.sakaiproject.nakamura.app-1.1-SNAPSHOT.jar',
        javamemorymax  => '1000',
        javapermsize   => '512',
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

            'trusted.referer'         => $oae::params::install_http_admin ? {
                true     => "[\"http://${oae::params::httpd_name}\",\"https://${oae::params::httpd_name}\",\"http://${oae::params::ipaddress}\",\"https://${oae::params::ipaddress}\",\"http://${oae::params::ipaddress}:8080\",\"http://${oae::params::httpd_name_admin}\",\"https://${oae::params::httpd_name_admin}:${oae::params::admin_port}\",\"http://localhost:8080\",\"/\"]",
                default  => "[\"http://${oae::params::httpd_name}\",\"https://${oae::params::httpd_name}\",\"http://${oae::params::ipaddress}\",\"https://${oae::params::ipaddress}\",\"http://${oae::params::ipaddress}:8080\",\"http://localhost:8080\",\"/\"]",
            },
            
            'trusted.hosts'           =>  $oae::params::install_http_admin ? { 
                true    => "[\"http://${oae::params::httpd_name}:80\",\"https://${oae::params::httpd_name}:443\",\"http://${oae::params::ipaddress}:80\",\"https://${oae::params::ipaddress}:443\",\"http://${oae::params::ipaddress}:8080\",\"http://${oae::params::httpd_name_admin}:80\",\"http://${oae::params::httpd_name_admin}:${oae::params::admin_port}\",\"http://localhost:8080\"]",
                default => "[\"http://${oae::params::httpd_name}:80\",\"https://${oae::params::httpd_name}:443\",\"http://${oae::params::ipaddress}:80\",\"https://${oae::params::ipaddress}:443\",\"http://${oae::params::ipaddress}:8080\",\"http://localhost:8080\"]",
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

    oae::sling_config { "org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config":
        dirname => "org/sakaiproject/nakamura/lite/storage/jdbc",
        pid     => '"org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool"',
        config => {
            'jdbc-driver' => "\"${oae::params::sparsedriver}\"",
            'jdbc-url'    => "\"${oae::params::sparseurl}\"",
            'username'    => "\"${oae::params::sparseuser}\"",
            'password'    => "\"${oae::params::sparsepass}\"",
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
