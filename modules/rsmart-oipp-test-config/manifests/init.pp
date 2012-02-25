#
# OIPP production cluster
# https://oipp-test.academic.rsmart.com
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
    $homedir = '/home/rsmart'
    $basedir = "${homedir}/sakaioae"

    ###########################################################################
    # Nodes
    $app_server  = '127.0.0.1'
    $db_server   = '127.0.0.1'
    $cle_server  = 'localhost'

    ###########################################################################
    # Database setup
    $db          = 'nak'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    # TODO - Get the real values for the CLE database
    $cle_db          = 'cle'
    $cle_db_user     = 'sakai_cle'
    $cle_db_password = 'ironchef'

    ###########################################################################
    # Content body storage
    $storedir    = "/files-academic"

    ###########################################################################
    # Git (Preview processor)
    $nakamura_git = "http://github.com/rSmart/nakamura.git"
    # TODO - Set the tag once we have an oipp 1.1.1
    $nakamura_tag = undef

    ###########################################################################
    # Apache load balancer
    $http_name                   = 'oipp-test.academic.rsmart.com'
    $http_name_untrusted         = 'content-oipp-test.academic.rsmart.com'
    $apache_lb_members           = [ "${app_server}:8080", ]
    $apache_lb_members_untrusted = [ "${app_server}:8082", ]
    $apache_lb_params            = ["retry=20", "min=3", "flushpackets=auto", "max=250", "loadfactor=100", "timeout=60"]

    $mock_cle_content            = false
    $apache_cle_lb_members       = [ "${cle_server}:8009 route=OIPP-CLE1", "${cle_server}:8010 route=OIPP-CLE2" ]
    $apache_cle_location_match   = "^/(xsl-portal.*|access.*|courier.*|dav.*|direct.*|imsblti.*|library.*|messageforums-tool.*|osp-common-tool.*|polls-tool.*|portal.*|profile-tool.*|profile2-tool.*|sakai.*|samigo-app.*|scheduler-tool.*|rsmart-customizer-tool.*|oauth-tool.*|emailtemplateservice-tool.*|sitestats-tool.*|rsmart-support-tool.*|mailsender-tool.*|tool.css|portool_base.css)"

    ###########################################################################
    # App servers
    $jarsource     = '/home/rsmart/com.rsmart.academic.app.oipp-1.1.1-SNAPSHOT.jar'
    $jarfile       = 'com.rsmart.academic.app.oipp-1.1.1-SNAPSHOT.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $javamemorymax = '1024m'
    $javamemorymin = '1024m'
    $javapermsize  = '512m'

    $admin_password = 'e4D7kYbQgswCHp'

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
    $redirect_url = "https://oipp-test.academic.rsmart.com/"
    $redirect_enabled = true

    $mapping_enabled = true
    $authn_header    = "sak3-user"
    $trusted_ip      = "127.0.0.1"
    $user_property   = "eppn"
    $authn_path      = "/system/trustedauth"
    
    $auth_trusted_destination_default = "/me"
}
