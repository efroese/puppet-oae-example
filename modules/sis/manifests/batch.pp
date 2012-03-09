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
    $artifact,
    $sis_properties = false
    ) inherits sis {

    file { "${sis::basedir}/batch":
        ensure => directory,
    }

    $home = "${sis::basedir}/batch"

    # download the jar to $HOME/sis/artifact.jar
    archive::download { $artifact:
        ensure        => present,
        url           => $executable_url,
        src_target    => $home,
        checksum      => false,
        timeout       => 0,
        require => File[$sis::batch::home],
    }

    file { "${sis::batch::home}/bin":
        ensure => directory,
        require => File[$sis::batch::home],
    }

    if $sis_properties {
        file { "${sis::batch::home}/sis.properties":
            mode => 0644,
            content => template($sis_properties),
            require => File[$sis::batch::home],
        }
    }

    file { "${sis::batch::home}/bin/run_sis_batch.sh":
        mode => 0755,
        content => template('sis/run_sis_batch.sh.erb'),
        require => File["${sis::batch::home}/bin"],
    }

    cron { 'rsmart-basic-sis-batch':
        command => "${sis::batch::home}/bin/run_sis_batch.sh",
        user    => $user,
        minute  => 0,
    }
}