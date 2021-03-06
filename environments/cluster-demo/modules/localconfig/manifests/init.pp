#
# Use this class to configure a specific OAE cluster.
# In your nodes file refer to these variables as $localconfig::variable_name.
#
class localconfig {
    
    ###########################################################################
    # OS
    $user    = 'sakaioae'
    $group   = 'sakaioae'
    $uid     = 8080
    $gid     = 8080
    $basedir = '/usr/local/sakaioae'

    ###########################################################################
    # Database setup
    $db          = 'nakamura'
    $db_server   = '192.168.1.250'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # HA apache load balancer
    $http_name                = 'oae.localdomain'
    $virtual_ip      = '192.168.1.40'
    $virtual_netmask = '255.255.255.0'
    $apache_lb_hostnames       = ['oae-lb1.localdomain', 'oae-lb2.localdomain']
    $apache_lb_members         = ['192.168.1.50:8080', '192.168.1.51:8080']
    $apache_lb_members_untrusted = ['192.168.1.50:8082', '192.168.1.51:8082']
    $apache_lb_standbyurl      = 'http://sorry.localdomain'

    # heartbeat/pacemaker for HA apache load balancers
    $apache_lb_pacemaker_authkey = 'apachehbauthkey'
    $apache_lb_pacemaker_interface = 'eth0'
    $apache_lb_pacemaker_nodes = [ '192.168.1.41', '192.168.1.42']

    ###########################################################################
    # App servers
    $javamemorymax = '512'
    $javamemorymin = '256'
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
    $solr_remoteurl = "http://${solr_master}:8080/solr"
    $solr_queryurls = "http://${solr_slave0}:8080/solr|http://${solr_slave1}:8983/solr|http://${solr_slave2}:8983/solr"

    # ActiveMQ
    $activemq_brokers = [ app_server0, app_server1 ]
    $activemq_reconnect_delay = '5000'
}
