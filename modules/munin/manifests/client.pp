class munin::client($allowed_ip_regex = "127.0.0.1") {
  include munin::repos
  
  package { 'munin-node': ensure => installed }
  
  user { 'munin':
    ensure  => 'present',
    comment => 'Munin user',
    gid     => '498',
    home    => '/var/lib/munin',
    shell   => '/sbin/nologin',
    uid     => '220',
    require => Package['munin-node'],
  }
  
  file { '/etc/munin/munin-node.conf':
    ensure  => file,
    mode    => '0644',
    content => template('munin/munin-node.conf.erb'),
    require => User['munin'],
  }

  service { 'munin-node':
    ensure  => running,
    require => [ User['munin'], File['/etc/munin/munin-node.conf'] ]
  }
  
}