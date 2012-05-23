class puppet($puppet_conf){

    package { 'rails':
        ensure => '2.2.2',
        provider => 'gem',
    }

    package { [ 'mysql-devel', 'ruby-mysql' ]: ensure => installed }

    if !defined(Package['ruby-devel']) {
        package { 'ruby-devel': ensure => installed }
    }

    file { '/etc/puppet/puppet.conf':
        owner => root,
        group => root,
        mode => 644,
        content => template($puppet_conf),
    }
}
