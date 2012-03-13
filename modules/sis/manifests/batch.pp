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
# $sis_properties:: A path to a template used to render sis.properties
#
# $csv_dir:: The directory that holds the csv files to process
#
# $csv_user_filenames:: CSV files to be processed by the SIS user processor.

class sis::batch (
    $user,
    $executable_url,
    $artifact,
    $sis_properties = 'sis/sis.properties.erb',
    $csv_dir        = false,
    $csv_user_filenames = [],
    $server_url,
    $oae_user = 'admin',
    $oae_password,
    $email_report
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

    file { "${sis::batch::home}/sis.properties":
        mode => 0644,
        content => template($sis_properties),
        require => File[$sis::batch::home],
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