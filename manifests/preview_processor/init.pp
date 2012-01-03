class oae::preview_processor($oae_user="sakaioae", $basedir="/usr/local/sakaioae") {

    file { "${basedir}/bin":
        ensure => directory,
        owner  => $oae_user,
        group  => $oae_user,
        mode   => 750,
    }

    case $operatingsystem {
        /RedHat|CentOS/:   { include oae::preview_processor::redhat }
        /Debian|Ubuntu/:  { include oae::preview_processor::debian }
    }

    include oae::preview_processor::openoffice
    include oae::preview_processor::gems

    ###########################################################################
    # Drop the script for the cron job
    file { "${basedir}/bin/run_preview_processor.sh":
        content => template('oae/run_preview_processor.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }
}
