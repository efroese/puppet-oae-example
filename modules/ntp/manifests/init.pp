#
# = Class ntp
# Configure ntpd and make sure its running.
#
# == Paramters
# $time_zone:: The path to the timezone file
#
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
