define nfs::export ($ensure=present,
                    $share,
                    $options="",
                    $guest) {

  $concatshare = substitute($share, '/', '-')
  $concatguest = substitute($guest, '/','-')

  common::concatfilepart {"${concatshare}-on-${concatguest}":
    ensure      => $ensure,
    content     => template('nfs/export-line.erb'),
    file        => "/etc/exports",
    notify      => Exec['reload_nfs_srv'],
  }
}
