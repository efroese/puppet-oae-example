#
# Use this class to configure a specific OAE cluster.
# In your nodes file refer to these variables as $localconfig::variable_name.
#
class localconfig {
    
    ###########################################################################
    # OS
    user    = 'sakaioae'
    group   = 'sakaioae'
    basedir = '/usr/local/sakaioae'

    ###########################################################################
    # Database setup
    $db          = 'nakamura'
    $db_url      = "jdbc:mysql://192.168.1.250:3306/${db}?autoReconnectForPools\\=true"
    $db_driver   = 'com.mysql.jdbc.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Git
    $nakamura_git = "http://github.com/sakaiproject/nakamura"
    $nakamura_tag = "1.1"

    ###########################################################################
    # HA apache load balancer
    $apache_lb_http_name       = 'oae.localdomain'
    $apache_lb_virtual_ip      = '192.168.1.40'
    $apache_lb_virtual_netmask = '255.255.255.0'
    $apache_lb_hostnames       = ['oae-lb1.localdomain', 'oae-lb2.localdomain']
    $apache_lb_members         = ['oae-lb1.localdomain:8080', 'oae-lb2.localdomain:8080']
    $apache_lb_standbyurl      = 'http://sorry.localdomain'

    # heartbeat/pacemaker for HA apache load balancers
    $apache_lb_pacemaker_authkey = 'apachehbauthkey'
    $apache_lb_pacemaker_interface = 'eth0'
    $apache_lb_pacemaker_nodes = [ '192.168.1.41', '192.168.1.42']

    ###########################################################################
    # App servers
    $version_oae   = '1.1'
    $downloaddir   = 'http://192.168.1.124/jars/'
    $jarfile       = 'org.sakaiproject.nakamura.app-1.1-mysql.jar'
    $javamemorymax = '512'
    $javapermsize  = '256'

    # oae server protection service
    $serverprotectsec = 'shhh-its@secret'

    $app_server0 = '192.168.1.50'
    $app_server1 = '192.168.1.51'

    # ehcache
    $mcast_address = '230.0.0.2'
    $mcast_port = '8450'

    # solr
    $solr_master = '192.168.1.70'
    $solr_slave0 = '192.168.1.71'
    $solr_slave1 = '192.168.1.72'
    $solr_slave2 = '192.168.1.73'
    $solr_remoteurl = "http://${solr_master}:8983/solr"
    $solr_queryurls = "http://${solr_slave0}:8983/solr|http://${solr_slave1}:8983/solr|http://${solr_slave2}:8983/solr"
}