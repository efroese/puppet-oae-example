class oae::app::setup {

    Class['oae::params'] -> Class['oae::app::setup']

    package { 'curl': ensure => installed }

    $log_dir  = "/var/log/sakaioae"
    $jar_dir  = "${oae::params::basedir}/jars"

    $sling_dir  = "${oae::params::basedir}/sling"
    $config_dir = "${sling_dir}/config"
    $solr_dir   = "${sling_dir}/solr"

    # TODO this needs to become a mount
    $sparse_store_dir = "${oae::params::basedir}/store"

    $app_dirs = [ $oae::params::basedir, $jar_dir, $sling_dir, $config_dir, $log_dir, $solr_dir, $sparse_store_dir ]

    file { [ $jar_dir, $sling_dir, $config_dir, $log_dir, $solr_dir, $sparse_store_dir ]:
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
