# = Class: oae::app::server
#
# This class installs an OAE app server and runs it.
#
# == Parameters:
#
# $downloadurl::   The URL to the the app jar
#
# $jarsource::     The path to the jar on the local machine.
#
# $jarfile::       The name of the jar
#
# $jav::           The path to java
#
# $javamemorymin:: The min java heap size
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
#     downloadurl   => 'http://192.168.1.124/jars/org.sakaiproject.nakamura.app-1.1-mysql.jar',
#     jarfile       => 'org.sakaiproject.nakamura.app-1.1-mysql.jar',
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
#   class { 'oae::app::server':
#     jarsource     => '/home/sakaioae/jars/org.sakaiproject.nakamura.app-1.1-mysql.jar',
#     jarfile       => 'org.sakaiproject.nakamura.app-1.1-mysql.jar',
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
class oae::app::server( $downloadurl = "",
                        $jarsource = "",
                        $jarfile,
                        $java="usr/bin/java",
                        $javamemorymax,
                        $javamemorymin,
                        $javapermsize,
                        $setenv_template='oae/setenv.sh.erb') {

    Class['oae::app::setup'] -> Class['oae::app::server']

    include oae::app::setup

    file { "${oae::params::basedir}/sling/nakamura.properties":
        ensure => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0644',
        source  => "puppet:///modules/oae/nakamura.properties",
        notify  => Service['sakaioae']
    }

    file { "${oae::params::basedir}/bin/setenv.sh":
        ensure => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0755',
        content  => template($setenv_template),
        notify  => Service['sakaioae']
    }

    $jar_dest = "${oae::params::basedir}/jars/${jarfile}"
    $app_jar = "${oae::params::basedir}/sakaioae.jar"


    exec { 'fetch-package':
        command => $downloadurl ? {
            /""/ => "curl --silent ${downloaddir}${jarfile} --output ${jar_dest}",
            default => "cp ${jarsource} .",
        },
        cwd     => "${oae::params::basedir}/jars/",
        creates => $jar_dest,
        require => File["${oae::params::basedir}/jars/"],
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
        enable => true,
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

        # Write the config file
        file { "${sling_config}/${name}":
            owner => root,
            group => root,
            mode  => 0444,
            content => template("oae/sling_config.erb"),
            require => Mkdir_p[$config_dir],
        }
    }
}
