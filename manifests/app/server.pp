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
    
}
