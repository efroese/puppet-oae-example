class oae::preview_processor::init ($nakamura_git, $nakamura_tag="") {

    Class['oae::params'] -> Class['oae::preview_processor::init']

    case $operatingsystem {
        /RedHat|CentOS/:   { include oae::preview_processor::redhat }
        /Debian|Ubuntu/:   { include oae::preview_processor::debian }
    }

    class { 'oae::preview_processor::openoffice': }
    class { 'oae::preview_processor::gems': }

    file { "${oae::params::basedir}/bin":
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 750,
    }

    # clone a copy of nakamura to /usr/local/sakaioae/nakamura.
    # technically we only need the preview_processor
    exec { "clone nakamura":
        command => "git clone ${nakamura_git} ${oae::params::basedir}/nakamura",
        creates => "${oae::params::basedir}/nakamura",
        require => Package['git'],
        notify  => $nakamura_tag ? {
                /.+/ => Exec['checkout nakamura tag'],
            } 
    }

    # Checkout a specific tag if specified
    if $nakamura_tag != "" {
        exec { "checkout nakamura tag":
            command => "git checkout ${nakamura_tag}",
            cwd     => "${oae::params::basedir}/nakamura",
            require => [ Package['git'], Exec['clone nakamura'], ],
            refreshonly => true, # only do this when notified, not on every run
        }
    }

    ###########################################################################
    # Drop the script for the cron job
    file { "${basedir}/bin/run_preview_processor.sh":
        content => template('oae/run_preview_processor.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }
}
