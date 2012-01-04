# = Class: oae::core
#
# This class configures the OAE sparse map content storage system
#
# == Parameters:
#
# $driver::   The JDBC driver to use.
#
# $url::      The JDBC url to use.
#
# $user::     The database user.
#
# $pass::     The database password
#
# == Actions:
#   Configures the sparse map content storage system on an OAE app server.
#
# == Sample Usage:
#
#   class {'oae::core':
#     $driver = "jdbc:mysql://192.168.1.250:3306/nakamura?autoReconnectForPools\\=true",
#     $url    = 'com.mysql.jdbc.Driver',
#     $user   = 'nakamura',
#     $pass   = 'ironchef',
#   }
#
class oae::core($driver, $url, $user, $pass) {

    Class['oae::params'] -> Class['oae::core'] 

    oae::app::server::sling_config { "org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config":
        dirname => "org/sakaiproject/nakamura/lite/storage/jdbc",
        config => {
            'jdbc-driver' => $driver,
            'jdbc-url'    => $url,
            'username'    => $user,
            'password'    => $pass,
        }
    }
    
}
