# = Class: dashboard::app::server
#
# This class installs a Dashboard app server and runs it.
#
# == Parameters:
#
# $downloadurl::   The URL to the the app war
#
# $bin_source::     The path to the war on the local machine.
#
# $jav::           The path to java
#
# $javamemorymin:: The min java heap size
#
# $javamemorymax:: The max java heap size
#
# $javapermsize::  The max java perm gen space
#
# $sparseconfig_properties_template:: The template to use to render sparseconfig.properties (optional)
#
# $setenv_template::  The template to use to render the setenv.sh file. (optional)
#
# == Actions:
#   Install a Sakai OAE app jar and start it up
#
# == Sample Usage:
#
#   class { 'dashboard::app::server':
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
#   class { 'dashboard::app::server':
#     bin_source     => '/home/sakaidashboard/jars/org.sakaiproject.nakamura.app-1.1-custom.jar',
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
class dashboard::app::server($downloadurl = '',
                        $bin_source      = '',
						$bin_target_dir  = '',
                        $deploy          = 'false',
                        $java            = '/usr/bin/java',
                        $javamemorymax,
                        $javamemorymin,
                        $javapermsize,
                        $config_template = 'dashboard/dashboard.cfg.properties.erb',
                        $basedir         = '/app/dashboard',
						$config_dir      = '/app/dashboard/config',
						$config_file     = '/app/dashboard/config/dashboard.cfg.properties',
                        $db_user         = 'dashboard',
                        $db_pass         = 'dashboard',
                        $db_name         = 'dashboard',
                        $user            = 'rsmart',
                        $group           = 'rsmart',
                        $basedir         = '/app/dashboard',
                        $bin_filename    = 'dashboard.war',
                        $lti_key         = 'SUPER_SECRET') {

    Class['dashboard::app::setup'] -> Class['dashboard::app::server']

    $bin_dir     = "${basedir}/bin"
    
    class { 'dashboard::app::setup': 
        user         => $user,
        group        => $group,
        basedir      => $basedir,
        config_dir   => $config_dir,
        bin_dir      => $bin_dir,
    }

    # Config file
    file { $config_file :
            ensure  => present,
            owner   => $user,
            group   => $group,
            mode    => '0755',
            content => template($config_template),
            notify  => Service['tomcat']
    }

    if ($downloadurl == '') and ($bin_source == '') {
        fail("You must pass either the downloadurl or bin_source parameter.")
    }

    $bin_file = $downloadurl ? {
        ''      => inline_template("<%= File.basename('${bin_source}') %>"),
        default => inline_template("<%= File.basename('${downloadurl}') %>"),
    }

    $war_dest = $bin_target_dir ? {
        '' 		=> $bin_source,
        default => "${bin_target_dir}/${bin_filename}",
    }
    
    $app = "${basedir}/${bin_filename}"

    if( $deploy == 'true') {
        exec { 'fetch-package':
            command => $downloadurl ? {
                ''      => "cp ${bin_source} ${war_dest}",
                default => "curl --silent ${downloadurl} --output ${war_dest}",
                },
            creates => $war_dest,
        }
    }

    #
    # Create a directory and its parent path if necessary
    #
    # == Parameters
    #
    # $path  = The path to the directory
    # $user  = The owner for the directory
    # $group = The group for the directory
    # $mode  = The mode for the directory
    #
    define mkdir_p($owner, $group, $mode) {
        # Create the folders for the config file
        if !defined(Exec["mkdir_p_${name}"]) {
            exec { "mkdir_p_${name}":
                command => "mkdir -p ${name}",
                creates => "${name}",
            }
        }

        # Ensure correct perms and ownership.
        if !defined(File[$name]) {
            file { $name:
                ensure => directory,
                owner  => $owner,
                group  => $group,
                mode   => $mode,
                require => Exec["mkdir_p_${name}"],
            }
        }
    }
}
