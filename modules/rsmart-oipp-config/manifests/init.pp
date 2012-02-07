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
    $basedir = '/home/rsmart/sakaioae'

    ###########################################################################
    # Nodes
    $app_server  = '127.0.0.1'
    $cle_server  = 'cole.uconline.edu'
    $db_server   = '10.51.10.11'

    ###########################################################################
    # Database setup
    $db          = 'nak'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Content body storage
    $storedir    = "/files-academic"

    ###########################################################################
    # Git (Preview processor)
    $nakamura_git = "http://github.com/rsmart/nakamura.git"
    $nakamura_tag = "acad-1.1.0-M1-20120130"

    ###########################################################################
    # Apache load balancer
    $http_name                   = 'cole.uconline.edu'
    $apache_lb_members           = [ "${app_server}:8080", ]
    $apache_lb_members_untrusted = [ "${app_server}:8082", ]
    $apache_cle_lb_members       = [ '10.51.10.16', '10.51.10.17' ]

    ###########################################################################
    # App servers
    $jarsource     = '/home/rsmart/com.rsmart.academic.app-1.1.0-M1-20120130.jar'
    $jarfile       = 'com.rsmart.academic.app-1.1.0-M1-20120130.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $javamemorymax = '4096'
    $javamemorymin = '4096'
    $javapermsize  = '256'

    $admin_password = 'admin'

    # These hosts can access /system/console
    $oae_admin_hosts = ['72.44.192.164', ]

    # oae server protection service
    $serverprotectsec = 'ljgfh259w4tyfknjslkdg0134tjna'

    # CLE
    $basiclti_secret = "rLKQsw6YBq4TUa"
    $basiclti_key    = "ColeUconlineEdu"
    
    # Slideshare
    $slideshare_api_key       = "71YQYo1Q"
    $slideshare_shared_secret = "5Yrynquv"
    
    # Flickr
    $flickr_api_key = 'f01de791ffcc08f3cc01be9a885467b8'

    # outgoing email
    $smtp_server      = '10.51.9.10'
    $reply_as_address = 'noreply@rsmart.com'
    $reply_as_name    = 'rSmart Academic'
    
    # Registration
    $redirect_url = "https://cole.uconline.edu"
    $redirect_enabled = true
    
    $mapping_enabled = true
    $authn_header    = "sak3-user"
    $trusted_ip      = "10.51.9.10"
    $user_property   = "eppn"
    $authn_path      = "/system/trustedauth"
    
    $auth_trusted_destination_default = "/me"
}
