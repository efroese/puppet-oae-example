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
# $setenv_template::  The template to use to render the setenv.sh file. (optional)
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
    # $name    = The serice pid
    # $config  = A hash of configkey => value to configure the service
    #            Supports strings, booleans, and arrays
    # $locked  = Lock the config file so only root can edit it.
    define sling_config($config, $locked = true){
        
        $pid = $name
        $basename = template('oae/basename.erb')
        $dirname = template('oae/dirname.erb')
        $sling_config = "${oae::params::basedir}/sling/config"

        # Multiple defines may try to create the same dir. its ok.
        if !defined(Mkdir_p["${sling_config}/${dirname}"]){
            # create the config file destination
            mkdir_p { "${sling_config}/${dirname}":
                owner => $locked ? { false => $oae::params::user, default => 'root' },
                group => $locked ? { false => $oae::params::group, default => 'root' },
                mode => 0644,
                notify => Exec["chown_${config_dir}/org/apache"],
            }
        }

        # Write the config file
        file { "${sling_config}/${dirname}/${basename}.config":
            owner => root,
            group => root,
            mode  => 0444,
            content => template("oae/sling_config.erb"),
            require => Mkdir_p["${sling_config}/${dirname}"],
        }
    }
}
