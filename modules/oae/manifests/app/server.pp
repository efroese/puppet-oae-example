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
#   class { 'oae::app::server':
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
#   class { 'oae::app::server':
#     jarsource     => '/home/sakaioae/jars/org.sakaiproject.nakamura.app-1.1-custom.jar',
#     javamemorymax => 512,
#     javapermsize  => 256,
#   }
#
class oae::app::server( $downloadurl = '',
                        $jarsource   = '',
                        $java        = '/usr/bin/java',
                        $javamemorymax,
                        $javamemorymin,
                        $javapermsize,
                        $setenv_template ='oae/setenv.sh.erb',
                        $sparseconfig_properties_template = undef,
                        $store_dir=undef) {

    Class['oae::app::setup'] -> Class['oae::app::server']

    class { 'oae::app::setup':
        store_dir => $store_dir,
    }

    file { "${oae::params::basedir}/sling/nakamura.properties":
        ensure  => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0644',
        source  => "puppet:///modules/oae/nakamura.properties",
        notify  => Service['sakaioae']
    }

    file { "${oae::params::basedir}/bin/setenv.sh":
        ensure  => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0755',
        content => template($setenv_template),
        notify  => Service['sakaioae']
    }

    if $sparseconfig_properties_template != undef {
        file { "${oae::params::basedir}/bin/sparseconfig.properties":
            ensure  => present,
            owner   => $oae::params::user,
            group   => $oae::params::user,
            mode    => '0755',
            content => template($sparseconfig_properties_template),
            notify  => Service['sakaioae']
        }
    }

    if ($downloadurl == '') and ($jarsource == '') {
        fail("You must pass either the downloadurl or jarsource parameter.")
    }

    $jar_file = $downloadurl ? {
        ''      => inline_template("<%= File.basename('${jarsource}') %>"),
        default => inline_template("<%= File.basename('${downloadurl}') %>"),
    }

    $jar_dest = "${oae::params::basedir}/jars/${jar_file}"
    $app_jar = "${oae::params::basedir}/sakaioae.jar"

    exec { 'fetch-package':
        command => $downloadurl ? {
            ''      => "cp ${jarsource} .",
            default => "curl --silent ${downloadurl} --output ${jar_dest}",
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
                mode => '0644',
                notify  => Exec["chown_sling_config_org_apache"],
            }
        }

        # Write the config file
        file { "${sling_config}/${dirname}/${basename}.config":
            owner => $locked ? { false => $oae::params::user, default => 'root' },
            group => $locked ? { false => $oae::params::group, default => 'root' },
            mode => $locked ? { true => '0444', false => '0644' },
            content => template("oae/sling_config.erb"),
            require => Mkdir_p["${sling_config}/${dirname}"],
        }
    }

    exec { "chown_sling_config_org_apache":
        refreshonly => true,
        command => "chown -R ${oae::params::user}:${oae::params::group} ${oae::params::basedir}/sling/config/org/apache",
    }
}
