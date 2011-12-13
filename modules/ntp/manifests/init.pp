class ntp($time_zone) {
    
    package { 'ntp': ensure => installed }
    
    file { '/etc/localtime':
        ensure => link,
        target => $time_zone,
    }

    service { 'ntpd':
        ensure => running,
    }
}
