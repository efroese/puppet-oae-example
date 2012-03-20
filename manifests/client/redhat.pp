class nfs::client::redhat inherits nfs::base {

  package { "nfs-utils":
    ensure => present,
  }

  $portmap = $::operatingsystem ? {
      Amazon => 'rpcbind',
      CentOS => $lsbmajdistrelease ? {
          5 => 'portmap',
          6 => 'rpcbind',
      },
  }

  package { $portmap: ensure => installed }
  service { $portmap:
      ensure => running,
      enable => true,
      require => [ Package[$portmap], Package["nfs-utils"]],
  }

  service {"nfslock":
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => [Package[$portmap], Package["nfs-utils"]],
  }
 
  service { "netfs":
    enable  => true,
    require => $lsbmajdistrelease ? {
      default => [Service[$portmap], Service["nfslock"]],
    },
  }

}
