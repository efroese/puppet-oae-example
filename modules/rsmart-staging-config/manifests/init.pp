#
# Use this class to configure a specific OAE cluster.
# In your nodes file refer to these variables as $localconfig::variable_name.
#
class localconfig {
    
    Class['localconfig::hosts'] -> Class['localconfig']

    ###########################################################################
    # OS
    $user    = 'rsmart'
    $group   = 'rsmart'
    $uid     = 8080
    $gid     = 8080
    $basedir = '/home/rsmart'

    ###########################################################################
    # Database setup
    $db          = 'nak'
    $db_url      = "jdbc:postgresql://10.50.10.40/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Git (Preview processor)
    $nakamura_git = "http://github.com/rsmart/nakamura.git"
    $nakamura_tag = "1.1"

    ###########################################################################
    # Apache load balancer
    $http_name       = 'staging.academic.rsmart.com'

    ###########################################################################
    # App servers
    $version_oae   = '1.1'
    $jarsource     = '/home/rsmart/com.rsmart.academic.app-1.1.0-M1-QA1.jar'
    $jarfile       = 'com.rsmart.academic.app-1.1.0-M1-QA1.jar'
    $javamemorymax = '4096'
    $javapermsize  = '256'

    # oae server protection service
    $serverprotectsec = 'shhh-its@secret'

    $app_server0 = '10.53.10.16'
    $app_server1 = '10.53.10.20'

    # ehcache
    $mcast_address = '230.0.0.2'
    $mcast_port = '8450'

    # solr
    $solr_master = '10.50.10.42'
    $solr_slave0 = '10.50.10.47' # TODO fix!
    $solr_remoteurl = "http://${solr_master}:8983/solr"
    $solr_queryurls = "http://${solr_master}:8983/solr|http://${solr_slave0}:8983/solr"
}
