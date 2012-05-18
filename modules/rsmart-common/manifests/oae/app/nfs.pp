#
# OAE clustered app node NFS storage configurations
#
class rsmart-common::oae::app::nfs {

    class { 'nfs::client': }

    file  { $localconfig::oae_nfs_mountpoint: ensure => directory }

    mount { $localconfig::oae_nfs_mountpoint:
        ensure => 'mounted',
        fstype => 'nfs4',
        device => "${localconfig::nfs_server}:${localconfig::oae_nfs_share}",
        options => $localconfig::oae_nfs_options,
        atboot => true,
        require => File[$localconfig::oae_nfs_mountpoint],
    }
}
