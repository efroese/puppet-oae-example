class nfs::client::redhat inherits nfs::base {

  package { "nfs-utils":
    ensure => present,
  }
  
  $portmap = "${operatingsystem}-${operatingsystemrelease}" ? {
      /Amazon-2011.09/ => 'rpcbind',
      default          => 'portmap',
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
