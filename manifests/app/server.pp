# = Class: oae::app::server
#
# This class installs an OAE app server and runs it.
#
# == Parameters:
#
# $version_oae::   The version of OAE to run
#
# $downloaddir::   The URL to the download directory where the app jar lives
#
# $jarfile::       The name of the jar file to download
#
# $javamemorymax:: The max java heap size
#
# $javapermsize::  The max java perm gen space
#
# == Actions:
#   Install a Sakai OAE app jar and start it up
#
# == Sample Usage:
#
#   class { 'oae::app::server':
#     version_oae   => '1.1'
#     downloaddir   => 'http://192.168.1.124/jars/',
#     jarfile       => 'org.sakaiproject.nakamura.app-1.1-mysql.jar',
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
class oae::app::server($version_oae, $downloaddir, $jarfile,
                        $javamemorymax, $javapermsize) {

    include oae::app::setup

    Class['oae::app::setup'] -> Class['oae::app::server']

    file { "${oae::params::basedir}/sling/nakamura.properties":
        ensure => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0644',
        source  => "puppet:///modules/oae/nakamura.properties",
        notify  => Service['sakaioae']
    }

    $jar_dest = "${oae::params::basedir}/jars/${jarfile}"
    $app_jar = "${oae::params::basedir}/sakaioae.jar"

    exec { 'fetch-package':
        command => "curl --silent ${downloaddir}${jarfile} --output ${jar_dest}",
        cwd     => "${oae::params::basedir}/jars/",
        creates => "${jar_dest}",
        require => [ File["${oae::params::basedir}/jars/"], Package['curl'] ],
    }

    file { $app_jar:
        ensure  => link,
        target  => $jar_dest,
        require => Exec['fetch-package'],
        notify  => Service['sakaioae'],
    }

    file { '/etc/init.d/sakaioae':
        ensure  => present,
        mode    => '0755',
        content => template('oae/sakaioae.sh.erb'),
        notify  => Service['sakaioae'],
    }

    service { 'sakaioae':
        ensure => running,
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
    
    #
    # Configure a sling service by placing a file in sling/config/part/of/service/pid.config
    #
    # == Parameters
    #
    # $dirname = The path below sling/config where the config file will be placed.
    # $config  = A hash of configkey => value to configure the service
    #            Supports strings, booleans, and arrays
    #
    define sling_config($dirname, $config){

        $sling_config = "${oae::params::basedir}/sling/config"
        $config_dir   = "${sling_config}/${dirname}"

        if !defined(Mkdir_p[$config_dir]){
            # create the config file destination
            mkdir_p { $config_dir:
                owner => root,
                group => root,
                mode => 0644,
            }
        }

        # Write the config file and trigger a chown
        file { "${sling_config}/${name}":
            owner => root,
            group => root,
            mode  => 0444,
            content => template("oae/sling_config.erb"),
            require => Mkdir_p[$config_dir],
        }
    }
}
