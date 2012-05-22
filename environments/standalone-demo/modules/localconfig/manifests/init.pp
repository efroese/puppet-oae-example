#
# THe configuration for a stanadlone OAE server running:
# Apache, OAE, Postgres, and the preview processor
#
# Use this class to configure a specific OAE cluster.
# In your nodes file refer to these variables as $localconfig::variable_name.
#
class localconfig {
    
    Class['localconfig::hosts'] -> Class['localconfig']

    ###########################################################################
    # OS
    $user    = 'sakaioae'
    $group   = 'sakaioae'
    $uid     = 8080
    $gid     = 8080
    $basedir = '/usr/local/sakaioae'

    ###########################################################################
    # Nodes
    $app_server  = '127.0.0.1'
    $db_server   = '127.0.0.1'

    ###########################################################################
    # Database setup
    $db          = 'nak'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Content body storage
    $storedir    = "${basedir}/store"

    ###########################################################################
    # Apache load balancer
    $http_name                   = 'oae-standalone.localdomain'
    $http_name_untrusted         = "content-${http_name}"
    $apache_lb_members           = [ "${app_server}:8080", ]
    $apache_lb_members_untrusted = [ "${app_server}:8082", ]
    $apache_lb_params            = ["retry=20", "min=3", "flushpackets=auto", "max=250", "loadfactor=100", "timeout=60"]

    ###########################################################################
    # App servers
    $jarsource     = '/root/org.sakaiproject.nakamura.app-1.3-SNAPSHOT.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $javamemorymax = '1024m'
    $javamemorymin = '1024m'
    $javapermsize  = '512m'

    $admin_password = 'admin'

    # These hosts can access /system/console
    $oae_admin_hosts = ['127.0.0.1', ]

    # oae server protection service
    $serverprotectsec = 'TODO-change-this'
}
