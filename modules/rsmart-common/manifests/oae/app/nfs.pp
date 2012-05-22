#
# OAE clustered app node NFS storage configurations
#
class rsmart-common::oae::app::nfs {

    Class['Oae::params'] -> Class['Rsmart-common::Oae::App::Nfs']

    class { 'nfs::client': }

    file  { $localconfig::oae_nfs_mountpoint:
        ensure => directory,
        owner => $oae::params::user,
        group => $oae::params::group,
    }

    mount { $localconfig::oae_nfs_mountpoint:
        ensure => 'mounted',
        fstype => 'nfs4',
        device => "${localconfig::nfs_server}:${localconfig::oae_nfs_share}",
        options => $localconfig::oae_nfs_options,
        atboot => true,
        require => File[$localconfig::oae_nfs_mountpoint],
    }
}
