class oae::params {

    ###########################################################################
    # Basic system stuff
    $user = 'sakaioae'
    $group = 'sakaioae'

    $basedir = '/usr/local/sakaioae'

    file { $basedir:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 750,
    }

    ###########################################################################
    # For using a Highly available cluster of Apache servers with a virtual IP
    $virtual_ip         = '192.168.1.40'
    $virtual_ip_netmask = '255.255.255.0'
    $http_hosts         = ['centos5-oae-lb1.localdomain', 'centos5-oae-lb2.localdomain']

    ###########################################################################
    # ServerProctectionService
    $serverprotectsec = 'thisisasecret'
    $http_name = 'centos5-oae.localdomain'
}
