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
    
    # staging-app1
    $app_server1 = '10.53.11.100'
    # staging-app2
    $app_server2 = '10.53.11.101'
    # staging-nfs
    $nfs_server  = '10.53.11.90'
    # staging-cle
    $cle_server  = '10.53.11.17'
    # staging-dbserv1
    $db_server   = '10.53.11.70'
    # solr master server
    $solr_master = '10.53.11.30'

    ###########################################################################
    # Database setup
    $db          = 'nak'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # Content body storage
    $nfs_share   = '/export/files-academic'
    $nfs_mountpoint = '/files-academic'
    $nfs_options = '_netdev,rw,rsize=8192,wsize=8192'

    $storedir    = "/files-academic/store"

    ###########################################################################
    # Git (Preview processor)
    $nakamura_zip = 'https://nodeload.github.com/rSmart/nakamura/zipball/develop'
    $solr_tarball = 'https://nodeload.github.com/rSmart/solr/tarball/develop'

    ###########################################################################
    # Apache load balancer
    $http_name                   = 'staging.academic.rsmart.com'
    $http_name_untrusted         = 'content-staging.academic.rsmart.com'
    $apache_lb_members           = [ "${app_server1}:8080", "${app_server2}:8080" ]
    $apache_lb_members_untrusted = [ "${app_server1}:8082", "${app_server2}:8082" ]
    $apache_lb_params            = ["retry=20", "min=3", "flushpackets=auto", "max=250", "loadfactor=100", "timeout=60"]
    
    $apache_cle_lb_members = [ "${cle_server}:8009 route=cle1", "${cle_server}:8010 route=cle2" ]
    $apache_cle_location_match = "^/(xsl-portal.*|access.*|courier.*|dav.*|direct.*|imsblti.*|library.*|messageforums-tool.*|osp-common-tool.*|polls-tool.*|portal.*|profile-tool.*|profile2-tool.*|sakai.*|samigo-app.*|scheduler-tool.*|rsmart-customizer-tool.*|oauth-tool.*|emailtemplateservice-tool.*|sitestats-tool.*|rsmart-support-tool.*|mailsender-tool.*|tool.css|portool_base.css)"
    $cle_dav_server0 = '10.53.10.19'

    ###########################################################################
    # App servers
    $jarsource     = '/home/rsmart/com.rsmart.academic.app-1.1.0-M1-20120130.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $javamemorymax = '5g'
    $javamemorymin = '5g'
    $javapermsize  = '256m'

    $admin_password = 'DDZn24tzeWtUEn'

    # These hosts can access /system/console
    $oae_admin_hosts = ['72.44.192.164', ]

    # oae server protection service
    $serverprotectsec = 'shhh-its@secret'
    $sps_disabled = true
    $qos_limit = '10'

    # ehcache
    $ehcache_tcp_port = '40001'
    $ehcache_remote_object_port = '40002'

    # solr
    $solr_remoteurl = "http://${solr_master}:8080/solr"

    # outgoing email
    $reply_as_address = 'noreply@rsmart.com'
    $reply_as_name = 'rSmart'

    $tomcat_user    = 'admin'
    $tomcat_password = 't0msm@rt!'

    class extra_users {
        realize(Group['karagon'])
        realize(User['karagon'])
        realize(Ssh_authorized_key['karagon-laptop-pub'])
        realize(Ssh_authorized_key['karagon-mbp-pub'])

        realize(Group['ppilli'])
        realize(User['ppilli'])
        realize(Ssh_authorized_key['ppilli-home-pub'])

        realize(Group['mflitsch'])
        realize(User['mflitsch'])
        realize(Ssh_authorized_key['mflitsch-home-pub'])
    }
}
