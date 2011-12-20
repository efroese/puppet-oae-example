class oae::preview_processor($oae_user="sakaioae", $basedir="/usr/local/sakaioae") {

    realize(Group[$oae_user])
    realize(User[$oae_user])

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

    ###########################################################################
    # Drop the script for the cron job
    file { "${basedir}/bin/run_preview_processor.sh":
        source => 'puppet:///modules/oae/run_preview_processor.sh',
        owner  => root,
        group  => root,
        mode   => 755,
    }
}
