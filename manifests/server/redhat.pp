class nfs::server::redhat inherits nfs::client::redhat {

    $portmap = "${operatingsystem}-${operatingsystemrelease}" ? {
        /Amazon-2011.09/ => 'rpcbind',
        default          => 'portmap',
    }

    package { $portmap: ensure => installed }
    service { $portmap:
        ensure => running,
        enabled => true,
        require => Package[$portmap]
    }

    exec { 'reload_nfs_srv':
        command     => "/etc/init.d/nfs reload",
        refreshonly => true,
        require     => Package["nfs-utils"]
    }

    service {'nfs':
        enable  => "true",
        ensure  => "running",
        require => [ Package["nfs-utils"], Service[$portmap], ]
    }
}
