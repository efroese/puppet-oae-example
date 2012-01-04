class oae::preview_processor::init ($nakamura_git, $nakamura_tag) {

    Class['oae::params'] -> Class['oae::preview_processor::init']

    file { "${oae::params::basedir}/bin":
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 750,
    }

    case $operatingsystem {
        /RedHat|CentOS/:   { include oae::preview_processor::redhat }
        /Debian|Ubuntu/:   { include oae::preview_processor::debian }
    }

    include oae::preview_processor::openoffice
    include oae::preview_processor::gems

    exec { "clone nakamura":
        command => "git clone ${nakamura_git} ${oae::params::basedir}/nakamura",
        creates => "${oae::params::basedir}/nakamura",
        require => Package['git'],
        notify  => Exec['checkout nakamura tag'],
    }

    exec { "checkout nakamura tag":
        command => "cd ${oae::params::basedir}/nakamura && git checkout ${nakamura_tag}",
        require => [ Package['git'], Exec['clone nakamura'], ],
        refreshonly => true,
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
