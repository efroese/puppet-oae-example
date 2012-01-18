###########################################################################
#
# Nodes
#
# This is an example of how to set up a standalone Sakai OAE server with
# a mysql database.
#
# oae-app0 - 192.168.1.50
# - one mysql database
# - one java process running OAE
#

node 'oae-app0' inherits basenode {

    $http_name = 'qa20-us.sakaiproject.org'
    $db          = 'nakamura'
    $db_user     = 'oae'
    $db_password = 'oae'

# OAE module configuration
    class { 'oae::params': }

    class { 'oae::app::server':
        downloaddir    => 'http://source.sakaiproject.org/maven2/org/sakaiproject/nakamura/org.sakaiproject.nakamura.app/1.1/',
        jarfile        => 'org.sakaiproject.nakamura.app-1.1.jar',
        javamemorymax  => '512',
        javapermsize   => '256',
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-url'    => "jdbc:mysql://localhost/${db}?autoReconnectForPools=true",
            'jdbc-driver' => 'com.mysql.jdbc.Driver',
            'username'    => $db_user,
            'password'    => $db_password,
        }
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => " localhost:8080 = http://localhost:8082, ${http_name}:8088 = https://${http_name}:8083 ", 
        }
    }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.proxy.ProxyClientServiceImpl":
        config => {
            'flickr_api_key' => 'c02231b7a686de2b99648f5862206bc1',
        },
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.proxy.SlideshareProxyPreProcessor":
        config => {
            'slideshare.apiKey' => '2YFELizz',
            'slideshare.sharedSecret' => 'TFOCwuxX',
        },
    }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.proxy.TrustedLoginTokenProxyPreProcessor":
        config => {
            'hostname' => 'qa1-nl.sakaiproject.org',
            'port'     => '80',
            'sharedSecret' => 'default-setting-change-before-use-e2KS54H35j6vS5Z38nK40',
        }
    }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.auth.trusted.TrustedTokenServiceImpl":
        config => {
            'sakai.auth.trusted.server.safe-hostsaddress' => "localhost;127.0.0.1;0:0:0:0:0:0:0:1%0;qa1-nl.sakaiproject.org;https://qa1-nl.sakaiproject.org",
            'sakai.auth.trusted.server.secret' => 'default-setting-change-before-use-17678901233445667',
        }
    }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
        config => {
             "sakai.cle.server.url" => "https://qa1-nl.sakaiproject.org",
        }
    }

    include augeas
    include mysql::server

    mysql::database { $db:
        ensure   => present
    }

    mysql::rights { "Set rights for ${db}":
        ensure   => present,
        database => $db,
        user     => $db_user,
        password => $db_password,
        host     => 'localhost',
    }
}
