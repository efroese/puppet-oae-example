# = Class: oae::app::ehcache
#
# Configure ehcache replicated to OAE app servers in a cluster
#
# == Parameters:
#
# $config_xml::     A template path to rander the ehcacheConfig.xml file
#
# $mcast_address::  The multicast address to use for cluster communication
#
# $mcast_port::     The multicast port to use for cluster communication
#
# $peers::          A list of peers. Required only for tcp communication
#
# $tcp_address::    TCP address for cluster communication
#
# $tcp_port::       TCP port for cluster communication
#
# $remote_object_port:: Secondary TCP port for cluster communication
#
# == Actions:
#   Configure ehCache on an OAE server
#
# == Sample Usage:
# 
#   class { 'oae::app::ehcache':
#     config_xml    => 'localconfig/ehcacheConfig.xml.erb'
#     mcast_address => '224.0.0.1',
#     mcast_port    => '5509',
#   }
#
#   # Some environments don't allow multicat. Use tcp instead.
#   class { 'oae::app::ehcache':
#     config_xml    => 'localconfig/ehcacheConfig.xml.erb'
#     tcp_address => '192.168.1.50',
#     tcp_port    => '40001',
#     remote_object_port    => '40002',
#   }
class oae::app::ehcache ($config_xml = 'oae/ehcacheConfig.xml.erb',
                         $peers=[],
                         $tcp_address = '',
                         $tcp_port = '40001',
                         $remote_object_port = '',
                         $mcast_address = '230.0.0.2',
                         $mcast_port = '8450') {

    Class['oae::params'] -> Class['oae::app::ehcache']

    # OAE 1.1
    $replicated_caches = [
        'org.sakaiproject.nakamura.auth.trusted.TokenStore',
        'presence.location',
        'presence.status',
        'deletedPathQueue',
        'accessControlCache',
        'authorizableCache',
        'contentCache',
        'lockmanager.lockmap',
        'server-tracking-cache', ]

    if $tcp_address != '' {
        $rmiurls = template('oae/rmiurls.erb')
    }

    file { "${oae::params::basedir}/sling/ehcacheConfig.xml":
        owner => $oae::params::user,
        group => $oae::params::group,
        mode  => 0440,
        content => template($config_xml),
    }
} 
