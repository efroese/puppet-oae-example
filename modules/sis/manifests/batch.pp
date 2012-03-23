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
# $school_properties:: A hash that maps school name to its properties overrides
#
# == Sample Usage:
#
# class { 'sis::batch':
#     user           => 'rsmart',
#     executable_url => 'https://url.to/sis-executable.jar',
#     artifact       => 'sis-executable.jar',
#     csv_dir        => '/files-cle/sis',
#     csv_object_types => [ 'Course', 'Membership', 'Section', 'SectionMembership'],
#     school_properties => {
#         'school0' => {
#             'oae.server.url' => 'https://school0.url/',
#             'oae.admin.user' => 'admin',
#             'oae.admin.password' => 'admin',
#             'dateFormat@com.rsmart.customer.integration.processor.cle.CleCourseProcessor' => 'yyyy-mm-dd',
#          },
#         'school1' => {
#             'oae.server.url' => 'https://school0=1.url/',
#             'oae.admin.user' => 'admin',
#             'oae.admin.password' => 'admin',
#             'dateFormat@com.rsmart.customer.integration.processor.cle.CleCourseProcessor' => 'yyyy-mm-dd',
#          },
#     },
#     email_report => 'reports@example.com',
# }
#

class sis::batch (
    $user,
    $executable_url,
    $artifact,
    $csv_object_types,
    $csv_dir        = false,
    $school_properties = { 'not configured' => { 'not' => 'configured'}, },
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

    file { "${sis::batch::home}/bin":
        ensure => directory,
        require => File[$sis::batch::home],
    }

    file { "${sis::batch::home}/log":
        owner => $user,
        ensure => directory,
        require => File[$sis::batch::home],
    }

    $sis_log = "${sis::batch::home}/log/sis.log"

    file { "${sis::batch::home}/sis.properties":
        mode => 0644,
        source => 'puppet://modules/sis/sis.properties',
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