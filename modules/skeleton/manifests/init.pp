class skeleton($param1 = 'value1') {

    package { 'skeleton': ensure => installed }

    file { '/etc/skeleton/config':
        owner => root,
        group => root,
        mode  => 0640,
        notify => Service['skeleton'],
    }

    service { 'skeleton':
        ensure => running,
    }

}
