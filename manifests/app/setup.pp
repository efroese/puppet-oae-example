# = Class: oae::app::server
#
# This class sets up the directories ecesary for an OAE install
#
# == Actions:
#   Create a few directories and links.
#
# == Sample Usage:
#
#   You don't use this class directly. The oae::app:;server class includes it.
#
class oae::app::setup {

    Class['oae::params'] -> Class['oae::app::setup']

    package { 'curl': ensure => installed }

    $log_dir  = "/var/log/sakaioae"
    $jar_dir  = "${oae::params::basedir}/jars"

    $sling_dir  = "${oae::params::basedir}/sling"
    $config_dir = "${sling_dir}/config"
    $bin_dir    = "${oae::params::basedir}/bin"

    file { [ $jar_dir, $sling_dir, $config_dir, $log_dir, $bin_dir]:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 0775,
    }

    file { "${sling_dir}/logs":
        ensure  => link,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        target  => $log_dir,
    }

    file { "${config_dir}/org":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 0644,
    }

    # The sling logging bundle causes the config admin service to write configs under org/apache/sling/...
    # TODO: we may want to tighten up the perms in this directory to avoid runtime reconfigurations
    file { "${config_dir}/org/apache":
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 0644,
    }
}
