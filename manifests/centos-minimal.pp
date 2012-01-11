class centos_minimal {

    $disabled_services = [ "bluetooth", "gpm", "haldaemon", "hidd", "smartd", ]
    service { $disabled_services:
        ensure => stopped,
        enable => false,
    }

}
