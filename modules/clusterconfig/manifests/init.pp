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
    $basedir = '/home/rsmart'

    ###########################################################################
    # Database setup
    $db          = 'nakamura'
    $db_server   = '192.168.1.250'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Git (Preview processor)
    $nakamura_git = "http://github.com/sakaiproject/nakamura.git"
    $nakamura_tag = "1.1"

    ###########################################################################
    # HA apache load balancer
    $apache_lb_http_name       = 'oae.localdomain'
    $apache_lb_virtual_ip      = '192.168.1.40'
    $apache_lb_virtual_netmask = '255.255.255.0'
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
    $downloadurl   = 'http://192.168.1.200/jars/org.sakaiproject.nakamura.app-1.1-postgres.jar'
    $jarfile       = 'org.sakaiproject.nakamura.app-1.1-mysql.jar'
    $javamemorymax = '512'
    $javamemorymin = '256'
    $javapermsize  = '256'

    # oae server protection service
    $serverprotectsec = 'shhh-its@secret'

    $app_server0 = '10.53.10.16'
    $app_server1 = '10.53.10.20'

    # ehcache
    $mcast_address = '230.0.0.2'
    $mcast_port = '8450'

    # solr
    $solr_master = '10.53.10.21'
    $solr_slave0 = '10.53.10.21'
    $solr_remoteurl = "http://${solr_master}:8080/solr"
    $solr_queryurls = "http://${solr_slave0}:8080/solr"
}
