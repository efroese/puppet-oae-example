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
    $uid     = 500
    $gid     = 500
    $basedir = '/home/rsmart'

    ###########################################################################
    # Database setup
    $db          = 'nakamura'
    $db_url      = "jdbc:mysql://oae-qa-db0:3306/${db}"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Git (Preview processor)
    $nakamura_git = "http://github.com/rsmart/nakamura.git"
    $nakamura_tag = "1.1"

    ###########################################################################
    # Apache load balancer
    $http_name       = 'dev.academic.rsmart.com'

    ###########################################################################
    # App servers
    $version_oae   = '1.1'
    $downloaddir   = 'http://192.168.1.124/jars/'
    # TODO: Fix app jar and url
    $jarfile       = 'org.sakaiproject.nakamura.app-1.1-mysql.jar'
    $javamemorymax = '4096'
    $javapermsize  = '256'

    # oae server protection service
    $serverprotectsec = 'shhh-its@secret'

    $app_server0 = '10.50.9.40'

    # ehcache
    $mcast_address = '230.0.0.2'
    $mcast_port = '8450'

    # solr
    $solr_master = '10.50.10.42'
    $solr_slave0 = '10.50.10.47' # TODO fix!
    $solr_remoteurl = "http://${solr_master}:8983/solr"
    $solr_queryurls = "http://${solr_master}:8983/solr|http://${solr_slave0}:8983/solr|"
}
