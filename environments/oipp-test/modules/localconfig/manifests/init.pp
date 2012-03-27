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
    $nakamura_zip = 'https://nodeload.github.com/rSmart/nakamura/zipball/base-1.1.2-rsmart'

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
    $jarsource     = '/home/rsmart/com.rsmart.academic.app.oipp-1.1.3-rsmart.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $java_home     = '/usr/java/jdk1.6.0_30'
    $javamemorymax = '4096m'
    $javamemorymin = '4096m'
    $javapermsize  = '512m'

    $admin_password = 'e4D7kYbQgswCHp'

    # These hosts can access /system/console
    $oae_admin_hosts = ['72.44.192.164', ]

    # oae server protection service
    $serverprotectsec = 'ljgfh259w4tyfknjslkdg0134tjna'

    # CLE
    $basiclti_secret = "rLKQsw6YBq4TUa"
    $basiclti_key    = "ColeUconlineEdu"
    $basiclti_tool_list = ["sakai.gradebook.gwt.rpc","sakai.assignment.grades","sakai.samigo","sakai.schedule","sakai.announcements","sakai.postem","sakai.profile2","sakai.profile","sakai.chat","sakai.resources","sakai.dropbox","sakai.rwiki","sakai.forums","sakai.gradebook.tool","sakai.mailbox","sakai.singleuser","sakai.messages","sakai.site.roster","sakai.news","sakai.summary.calendar","sakai.poll","sakai.syllabus","sakai.blogwow","sakai.sitestats","sakai.sections"]
    
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
    $cle_dns             = [ '10.51.0.2', '10.51.0.2']
    $cle_mail_support    = 'bogus@mailinator.com'
    $cle_mail_request    = 'bogus@mailinator.com'
    $samigo_stmp_server  = $cle_smtp_server

    ###########################################################################
    # SIS Integration
    $basic_sis_batch_executable_artifact = 'com.rsmart.nakamura.basic-sis-batch-1.0.1-executable.jar'
    $basic_sis_batch_executable_url = 'http://rsmart-dev.s3.amazonaws.com/artifacts/maven/release/com/rsmart/com.rsmart.nakamura.basic-sis-batch/1.0.1/com.rsmart.nakamura.basic-sis-batch-1.0.1-executable.jar'
    $basic_sis_batch_email_report = "jutter@rsmart.com,mike@rsmart.com,mpd@rsmart.com"

    $oae_csv_dir = '/files-academic/sis/'
    $cle_csv_dir = '/files-cle/files/sis/'

    $sis_archive_dir = "${homedir}/sis-failed-transfers"

    $cle_csv_files = ['Course', 'Membership', 'Section', 'SectionMembership']
    $oae_csv_files = ['Course', 'Membership', 'Section', 'SectionMembership', 'User']

    $sis_batch_transfers = {
        'rsmart@oipp-cle1:/files-cle/files/sis/'        => $cle_csv_files,
        'rsmart@oipp-prod-app1:/files-academic/sis/'    => $oae_csv_files,
        'rsmart@oipp-cle1:/files-cle/files/sis/test'    => $cle_csv_files,
        'rsmart@oipp-test:~/sistest'                    => $oae_csv_files,
    }

    $sis_test_batch_transfers = {
        'rsmart@oipp-cle1:/files-cle/files/sis/test'    => $cle_csv_files,
        'rsmart@oipp-test:~/sistest'                    => $oae_csv_files,
    }

    # TODO Get the full list of properties.
    # These are intended as a starting point and example.
    $basic_sis_batch_school_properties = {
        'UCB' => {
            'upload_dir'          => '/home/ucb_sis',
            'test_upload_dir'     => '/home/ucb_sis/test',
        },
        'UCD' => {
            'upload_dir'          => '/home/ucd_sis',
            'test_upload_dir'     => '/home/ucd_sis/test',
        },
        'UCMerced' => {
            'upload_dir'          => '/home/ucm_sis',
            'test_upload_dir'     => '/home/ucm_sis/test',
        },
        'UCLA' => {
            'upload_dir'          => '/home/ucla_sis',
            'test_upload_dir'     => '/home/ucla_sis/test',
        },
    }

    # TODO is this actually the secret?
    $trusted_shared_secret = "yourSecret"
}