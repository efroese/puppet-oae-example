# = Class: oae::app::ehcache
#
# This class installs a solr master or slave for Sakai OAE
#
# == Parameters:
#
# $config_xml::     A template path to rander the ehcacheConfig.xml file
#
# $mcast_address::  The multicast address to use for cluster communication
#
# $mcast_port::     The multicast port to use for cluster communication
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
class oae::app::ehcache ($config_xml = 'oae/ehcacheConfig.xml.erb',
                         $mcast_address,
                         $mcast_port) {

    Class['oae::params'] -> Class['oae::app::ehcache']

    file { "${oae::params::basedir}/sling/ehcacheConfig.xml",
        owner => $oae::params::user,
        group => $oae::params::group,
        mode  => 0440,
        content => template($config_xml),
    }
} 
