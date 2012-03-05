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
    $cle_db          = 'cle'
    $cle_db_user     = 'sakai_cle'
    $cle_db_password = 'ironchef'
    $cle_db_url      = "jdbc:mysql://localhost:3306/${cle_db}?useUnicode=true&characterEncoding=UTF-8&useServerPrepStmts=false&cachePrepStmts=true&prepStmtCacheSize=4096&prepStmtCacheLimit=4096"

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
    $http_name                   = 'nightly.academic.rsmart.com'
    $http_name_untrusted         = 'content-nightly.academic.rsmart.com'
    $apache_lb_members           = [ "${app_server}:8080", ]
    $apache_lb_members_untrusted = [ "${app_server}:8082", ]
    $apache_lb_params            = ["retry=20", "min=3", "flushpackets=auto", "max=250", "loadfactor=100", "timeout=60"]

    $mock_cle_content            = false
    $apache_cle_lb_members       = [ "${cle_server}:8009 route=cle1", ]
    $apache_cle_location_match   = "^/(xsl-portal.*|access.*|courier.*|dav.*|direct.*|imsblti.*|library.*|messageforums-tool.*|osp-common-tool.*|polls-tool.*|portal.*|profile-tool.*|profile2-tool.*|sakai.*|samigo-app.*|scheduler-tool.*|rsmart-customizer-tool.*|oauth-tool.*|emailtemplateservice-tool.*|sitestats-tool.*|rsmart-support-tool.*|mailsender-tool.*|tool.css|portool_base.css)"
    $disable_cle_axis            = true

    ###########################################################################
    # OAE App servers
    $jarsource     = '/home/rsmart/com.rsmart.academic.app-1.1.2-rsmart-SNAPSHOT.jar'
    $jarfile       = 'com.rsmart.academic.app-1.1.2-rsmart-SNAPSHOT.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $javamemorymax = '1024m'
    $javamemorymin = '1024m'
    $javapermsize  = '512m'

    $admin_password = 'admin'

    # These hosts can access /system/console
    $oae_admin_hosts = ['72.44.192.164', ]

    # oae server protection service
    $serverprotectsec = 'Toth395hwtgwrghw9fs893ytqehfn'

    # CLE
    $basiclti_secret = "TODO-basic-lti-secret"
    $basiclti_key    = "TODO-basic-lti-key"

    # outgoing email
    $reply_as_address = 'noreply@rsmart.com'
    $reply_as_name    = 'rSmart Academic'

    ###########################################################################
    # CLE App servers
    $cle_tarball_url  = 'https://rsmart-releases.s3.amazonaws.com/releases/CLE/2.8.0.29/upgrader_CLEv2.8.0.29.tar.bz2'
    $cle_tarball_digest = '1a728b857db072aa28182cebba0f36ae'
    $cle_server_id    = 'sakai-nightly1'
    $tomcat_shutdown_password = 'downa56f3111'

    $linktool_privkey = 'N?m:???8??.???a'
    $linktool_salt    = '}*?|xD?U?0??+*2?????6?O%F?as8???(??.??6??#??????0??'

    $cle_email_test_mode = true
    $cle_smtp_server     = 'localhost'
    $cle_dns             = [ 'TODO_DNS_1', 'TODO_DNS_2']
    $cle_mail_support    = 'bogus@mailinator.com'
    $cle_mail_request    = 'bogus@mailinator.com'
}
