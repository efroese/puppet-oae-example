# = Class: munin::server
#
# == Parameters:
#
# $nodes::    A list of objects that represent the name / IP pair of nodes this server
#             monitors.
#
# == Actions:
#   Install the munin "master" scripts and configuration required to poll data from munin
#   nodes.
#
# == Example Usage:
#
#   class { 'munin::server':
#     nodes => [
#       { name => 'app0.oae-performance.sakaiproject.org', address => '127.0.0.1' },
#       { name => 'app1.oae-performance.sakaiproject.org', address => '127.0.0.2' }
#     ]
#   }
#
class munin::server($nodes) {

  include munin::repos

  class { 'munin::client': allowed_ip_regex => '127.0.0.1' }  
  package { 'munin': ensure => installed }

  file { '/etc/munin/munin.conf':
    ensure  => file,
    mode    => '0644',
    content => template('munin/munin.conf.erb'),
    require => Package['munin'],
  }

}