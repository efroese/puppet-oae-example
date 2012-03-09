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

    $mysql_root_password = 'khjRE7AftLfB'
    $cle_db              = 'cle'
    $cle_db_user         = 'sakai_cle'
    $cle_db_password     = 'ironchef'
    $cle_db_url          = "jdbc:mysql://localhost:3306/${cle_db}?useUnicode=true&characterEncoding=UTF-8&useServerPrepStmts=false&cachePrepStmts=true&prepStmtCacheSize=4096&prepStmtCacheLimit=4096"

    ###########################################################################
    # Content body storage
    $storedir    = "/files-academic/store"

    ###########################################################################
    # Git (Preview processor)
    $nakamura_zip = 'https://nodeload.github.com/rSmart/nakamura/zipball/develop'

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
    $disable_cle_axis            = true

    ###########################################################################
    # OAE App servers
    $jarsource     = '/home/rsmart/com.rsmart.academic.app.oipp-1.1.2-rsmart-SNAPSHOT.jar'
    $jarfile       = 'com.rsmart.academic.app.oipp-1.1.2-rsmart-SNAPSHOT.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $java_home     = '/usr/java/jdk1.6.0_30'
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

    # Shibboleth
    $mapping_enabled = true
    $authn_header    = "sak3-user"
    $trusted_ip      = "127.0.0.1"
    $user_property   = "eppn"
    $authn_path      = "/system/trustedauth"
    
    $auth_trusted_destination_default = "/me"

    ###########################################################################
    # CLE App servers
    $cle_tarball_url  = 'https://rsmart-releases.s3.amazonaws.com/CLE/2.8.0.26/upgrader_CLEvoipp-2.8.0.26-M1_r34359.tar.bz2'
    $cle_server_id    = 'OIPP-CLE1'
    $tomcat_shutdown_password = 'downa56f3111'

    $linktool_privkey = 'N?m:???8??.???a'
    $linktool_salt    = '}*?|xD?U?0??+*2?????6?O%F?as8???(??.??6??#??????0??'

    $cle_email_test_mode = true
    $cle_smtp_server     = 'localhost'
    $cle_dns             = [ 'TODO_DNS_1', 'TODO_DNS_2']
    $cle_mail_support    = 'bogus@mailinator.com'
    $cle_mail_request    = 'bogus@mailinator.com'
    $samigo_stmp_server  = $cle_smtp_server

    ###########################################################################
    # SIS Integration
    $basic_sis_batch_executable_artifact = 'com.rsmart.nakamura.basic-sis-batch-1.0-20120307.222244-1-executable.jar'
    $basic_sis_batch_executable_url = 'https://rsmart-dev.s3.amazonaws.com/artifacts/maven/snapshot/com/rsmart/com.rsmart.nakamura.basic-sis-batch-1.0-20120307.222244-1-executable.jar'
}
