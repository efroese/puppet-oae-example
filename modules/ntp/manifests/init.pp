class ntp {
    
    $local_time_zone = '/usr/share/zoneinfo/America/Phoenix'
    
    package { 'ntp': ensure => installed }
    
    file { '/etc/localtime':
        target => $local_time_zone,
    }

    service { 'ntpd':
        ensure => running,
    }
}
