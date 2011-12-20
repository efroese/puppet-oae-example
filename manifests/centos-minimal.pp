class centos_minimal {

    $disabled_services = [ "bluetooth", "audisp", "gpm", "hald", "hidd", "smartd", ]
    service { $disabled_services: ensure => stopped }

}
