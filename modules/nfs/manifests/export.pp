define nfs::export ($ensure=present,
                    $share,
                    $options="",
                    $guests) {

  common::concatfilepart { "nfs-export-concat-${name}":
    ensure      => $ensure,
    content     => template('nfs/export-line.erb'),
    file        => "/etc/exports",
    notify      => Exec['reload_nfs_srv'],
  }
}
