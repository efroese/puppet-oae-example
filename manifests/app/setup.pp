class oae::app::setup {

    Class['oae::params'] -> Class['oae::app::setup']

    package { 'curl': ensure => installed }

    $log_dir  = "/var/log/sakaioae"
    $jar_dir  = "${oae::params::basedir}/jars"

    $sling_dir  = "${oae::params::basedir}/sling"
    $jackrabbit_dir  = "${oae::params::basedir}/sling/jackrabbit"
    $config_dir = "${sling_dir}/config"

    # TODO this needs to become a mount
    $sparse_store_dir = "${oae::params::basedir}/store"

    file { [ $jar_dir, $sling_dir, $config_dir, $log_dir, $sparse_store_dir, $jackrabbit_dir ]:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 0775,
    }

    file { "${sling_dir}/logs":
        ensure  => link,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        target  => $log_dir,
    }
}
