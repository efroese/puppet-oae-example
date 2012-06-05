#
# Dashboard - QA
# http://...
#
# In your nodes file refer to these variables as $localconfig::variable_name.
#
class localconfig {
    
    Class['localconfig::hosts'] -> Class['localconfig']

    ###########################################################################
    # OS
    $user     = 'rsmart'
    $user_ssh = 'rsmart-pub'
    $group    = 'rsmart'
    $uid      = 500
    $gid      = 500
    $homedir  = '/home/rsmart'
    $basedir  = "/app/dashboard"
	
    ###########################################################################
    # Nodes
    $app_server  = '127.0.0.1'
    $db_server   = '127.0.0.1'

    ###########################################################################
    # Database setup
    $db          = 'dashboard'
    $db_user     = 'dashboard'
    $db_password = 'dashboard'

    ###########################################################################
    # Apache load balancer
    $http_name                   = 'dashboard.qa.rsmart.com'
    $apache_lb_members           = [ "${app_server}:8080", ]
    $apache_lb_params            = ["retry=20", "min=3", "flushpackets=auto", "max=250", "loadfactor=100", "timeout=60"]

    $mock_cle_content            = false
    $disable_cle_axis            = true

    ###########################################################################
    # App servers
    $bin_source    = '/home/rsmart/deploy/current'
    $java          = '/usr/java/jdk1.6.0_31/bin/java'
    $javamemorymax = '1024m'
    $javamemorymin = '1024m'
    $javapermsize  = '512m'
	
	$dashboard_config = "${basedir}/config/dashboard.cfg.properties"
	
	$tomcat_shutdown_password = 'downa56f3111'
	$server_id	   = 'jvm1'

    $admin_password = 'admin'

    # outgoing email
    $reply_as_address = 'noreply@rsmart.com'
    $reply_as_name    = 'rSmart Academic'

}
