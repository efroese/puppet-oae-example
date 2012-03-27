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
# $csv_dir:: The directory that holds the csv files to process
#
# $csv_object_types:: The object types to read from the CSV files. 
#
# == Sample Usage:
#
# class { 'sis::batch':
#     user           => 'rsmart',
#     executable_url => 'https://url.to/sis-executable.jar',
#     artifact       => 'sis-executable.jar',
#     csv_dir        => '/files-cle/sis',
#     csv_object_types => [ 'Course', 'Membership', 'Section', 'SectionMembership'],
#     email_report => 'reports@example.com',
# }
#

class sis::batch (
    $user,
    $executable_url,
    $artifact,
    $csv_object_types,
    $csv_dir        = false,
    $email_report
    ) inherits sis {

    file { "${sis::basedir}/batch":
        owner => $user,
        ensure => directory,
        require => File[$sis::basedir],
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

    file { ["${sis::batch::home}/bin", "${sis::batch::home}/etc"]:
        ensure => directory,
        require => File[$sis::batch::home],
    }

    file { "${sis::batch::home}/etc/schools":
        ensure => directory,
        require => File["${sis::batch::home}/etc"],
    }

    file { "${sis::batch::home}/log":
        owner => $user,
        ensure => directory,
        require => File[$sis::batch::home],
    }

    $sis_log = "${sis::batch::home}/log/sis.log"

    file { "${sis::batch::home}/sis.properties":
        mode => 0644,
        source => 'puppet:///modules/sis/sis.properties',
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

    define school($local_properties){

        file { "${sis::batch::home}/etc/schools/${name}":
            ensure => directory,
        }

        file { "${sis::batch::home}/etc/schools/${name}/local.properties":
            ensure  => present,
            content => template($local_properties),
            require => File["${sis::batch::home}/etc/schools/${name}"],
        }
    }
}