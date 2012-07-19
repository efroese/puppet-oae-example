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
    $basedir = '/usr/local/sakaioae'

    ###########################################################################
    # Database setup
    $db          = 'nakamura'
    $db_server   = 'OAE-Postgres-566174176.us-west-1.elb.amazonaws.com'
    $db_url      = "jdbc:postgresql://${db_server}/${db}?charSet\\=UTF-8&tcpKeepAlive=true"
    $db_driver   = 'org.postgresql.Driver'
    $db_user     = 'nakamura'
    $db_password = 'ironchef'

    ###########################################################################
    # App servers
    #$app_server0 = 'ec2-50-18-147-148.us-west-1.compute.amazonaws.com'
    #$app_server1 = 'ec2-204-236-168-81.us-west-1.compute.amazonaws.com'
    $app_server0 = 'ip-10-176-227-221.us-west-1.compute.internal'
    $app_server1 = 'ip-10-168-249-50.us-west-1.compute.internal'

    # These will eventually change.
    $app_server0_ip = dnsLookup($app_server0)
    $app_server1_ip = dnsLookup($app_server1)

    # ELBs for trusted and untrusted content
    $http_name              = 'oae-performance.sakaiproject.org'
    $http_name_untrusted    = 'oae-appservers-untrusted-414965918.us-west-1.elb.amazonaws.com'

    $apache_lb_members = 'oae-appservers-365563856.us-west-1.elb.amazonaws.com'
    $apache_lb_members_untrusted = 'oae-appservers-untrusted-414965918.us-west-1.elb.amazonaws.com'
    $apache_lb_standbyurl = "https://${http_name}/maintenance.html"

    $javamemorymax = '6144'
    $javamemorymin = '256'
    $javapermsize  = '256'

    # oae server protection service
    $serverprotectsec = 'pi34ht5p395hc24nw4tbc42twh'

    # Solr
    $solr_master = 'OAE-SOLR-426995740.us-west-1.elb.amazonaws.com'
    $solr_remoteurl = "http://${solr_master}:8080/solr"

    # EHcache
    $ehcache_remote_object_port = '40002'
}
