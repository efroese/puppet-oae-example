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
    
    # prod-app1
    $app_server1 = '10.52.11.100'
    # prod-app2
    $app_server2 = '10.52.11.101'
    # prod-nfs
    $nfs_server  = '10.52.11.90'
    # prod-cle
    $cle_server  = '10.52.10.17'
    # prod-dbserv1
    $db_server   = '10.52.11.70'
    # solr master server
    $solr_master = '10.52.11.30'

    ###########################################################################
    # Database setup
    $oae_db          = 'nak'
    $oae_db_url      = "jdbc:postgresql://${db_server}/${oae_db}?charSet\\=UTF-8"
    $oae_db_driver   = 'org.postgresql.Driver'
    $oae_db_user     = 'nakamura'
    $oae_db_password = 'ironchef'

    ###########################################################################
    # Content body storage
    $oae_nfs_share   = '/export/files-academic'
    $oae_nfs_mountpoint = '/files-academic'
    $oae_nfs_options = '_netdev,rw,rsize=8192,wsize=8192'

    $storedir    = "/files-academic/store"

    ###########################################################################
    # Git (Preview processor)
    $nakamura_zip = 'https://nodeload.github.com/rSmart/nakamura/zipball/com.rsmart.academic.app-1.1.4-rsmart'
    $solr_tarball = 'https://nodeload.github.com/rSmart/solr/tarball/1.3.2-rsmart'

    ###########################################################################
    # Apache load balancer
    $http_name                   = 'academic.rsmart.com'
    $http_name_untrusted         = "content.academic.rsmart.com"
    $apache_lb_members           = [ "${app_server1}:8080", "${app_server2}:8080" ]
    $apache_lb_members_untrusted = [ "${app_server1}:8082", "${app_server2}:8082" ]
    $apache_lb_params            = ["retry=20", "min=3", "flushpackets=auto", "max=250", "loadfactor=100", "timeout=60"]
    
    $apache_cle_lb_members = [ "${cle_server}:8009 route=cle1", "${cle_server}:8010 route=cle2" ]
    $apache_cle_location_match = "^/(xsl-portal.*|access.*|courier.*|dav.*|direct.*|imsblti.*|library.*|messageforums-tool.*|osp-common-tool.*|polls-tool.*|portal.*|profile-tool.*|profile2-tool.*|sakai.*|samigo-app.*|scheduler-tool.*|rsmart-customizer-tool.*|oauth-tool.*|emailtemplateservice-tool.*|sitestats-tool.*|rsmart-support-tool.*|mailsender-tool.*|tool.css|portool_base.css)"
    $cle_dav_server0 = '10.52.10.19'

    $disable_cle_axis = false
    
    $oae_cert = 'puppet:///modules/rsmart-common/rsmart.com.crt'
    $oae_certkey = 'puppet:///modules/rsmart-common/rsmart.com.key'
    $oae_certchain = 'puppet:///modules/rsmart-common/rsmart.com-intermediate.crt'

    ###########################################################################
    # App servers
    $jarsource     = '/home/rsmart/com.rsmart.academic.app-1.1.0-M1-20120130.jar'
    $java          = '/usr/java/jdk1.6.0_30/bin/java'
    $javamemorymax = '5g'
    $javamemorymin = '5g'
    $javapermsize  = '256m'

    $admin_password = 'Iibitj9XrKhR2yfXawsvXZbMNnwAtNjbwHNHctwBnoAFhKGEQj'

    # These hosts can access /system/console
    $oae_admin_hosts = ['72.44.192.164', ]

    # oae server protection service
    $serverprotectsec = 'ljgfh259w4tyfknjslkdg0134tjna'
    $sps_disabled = false
    $qos_limit = '10'

    # ehcache
    $ehcache_tcp_port = '40001'
    $ehcache_remote_object_port = '40002'

    # solr
    $solr_remoteurl = "http://${solr_master}:8080/solr"

    #CLE
    $basiclti_secret = "C7beFutror7iSd"
    $basiclti_key = "AcademicRsmartCom"

    $tomcat_user    = 'admin'
    $tomcat_password = 'pulp134@rain'

    # outgoing email
    $reply_as_address = 'noreply@rsmart.com'
    $reply_as_name = 'rSmart'

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

    ###########################################################################
    # HubSpot Configuration
    $hubspot_portalId = '85099'
    $hubspot_apiKey = '30510b72-5b73-4cdf-8cf9-99ae3c119252'
    $hubspot_url = 'http://rsmart.app8.hubspot.com/?app=leaddirector&FormName=acad-registration'

    ###########################################################################
    # Dynamic Configuration
    $dynamic_config_root = "${basedir}/dynamicconfig"
    $dynamic_config_masterfile = 'config.json'
    $dynamic_config_customdir = "${dynamic_config_root}/custom"
    $dynamic_config_jcroverrides = ["com.rsmart.nakamura.com.rsmart.nakamura.uxloader:${dynamic_config_root}/jcroverrides", ]
}
