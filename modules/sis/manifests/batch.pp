#
# = Class sis::batch
# Set up the rSmart simple batch sis integration
#
# == Parameters
#
# $user:: The user the cron job will run as
#
# $executable_url:: The url to download the jar
#
# $artifact:: The name of the jar.
#
class sis::batch (
    $user,
    $executable_url,
    $artifact
    ) inherits sis {

    # download the jar to $HOME/sis/artifact.jar
    archive::download { $artifact:
        ensure        => present,
        url           => $executable_url,
        src_target    => $sis::basedir,
        checksum      => false,
        timeout       => 0,
    }

    file { "${sis::basedir}/bin/run_sis_batch.sh":
        mode => 0755,
        content => template('sis/run_sis_batch.sh.erb'),
    }

    cron { 'rsmart-basic-sis-batch':
        command => "${sis::basedir}/bin/run_sis_batch.sh",
        user    => $user,
        minute  => 0,
    }
}