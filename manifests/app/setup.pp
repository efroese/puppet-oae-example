# = Class: oae::app::server
#
# This class sets up the directories ecesary for an OAE install
#
# == Paramters:
#
# $store_dir:: Where content bodies get stored.
#   A link is created due to a race condition with bringing up OSGi services
#   that causes sparse to temporarily come up with its default configuration.
#
# == Actions:
#   Create a few directories and links.
#
# == Sample Usage:
#
#   You don't use this class directly. The oae::app::server class includes it.
#
class oae::app::setup($store_dir=undef){

    Class['oae::params'] -> Class['oae::app::setup']

    package { 'curl': ensure => installed }

    $log_dir  = "/var/log/sakaioae"
    $jar_dir  = "${oae::params::basedir}/jars"

    $sling_dir  = "${oae::params::basedir}/sling"
    $config_dir = "${sling_dir}/config"
    $bin_dir    = "${oae::params::basedir}/bin"
    $save_dir    = "${oae::params::basedir}/save"

    file { [ $jar_dir, $sling_dir, $config_dir, $log_dir, $bin_dir, $save_dir]:
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

    cron { 'zip-oae-logs':
        user => $oae::params::user,
        command => "(cd $log_dir && for log in `ls *.log.* | grep -v gz`; do gzip \$log; done)",
        hour    => '1',
        minute  => '0',
    }

    # This is owned by root so we can delegate write-access access only to certain services
    file { "${config_dir}/org":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 0644,
    }

    if $store_dir != undef {
        file { "${oae::params::basedir}/store":
            ensure  => link,
            owner   => $oae::params::user,
            group   => $oae::params::user,
            target  => $store_dir,
            require => File[$oae::params::basedir]
        }
    }

    file { '/etc/profile.d/sakaioae.sh':
        mode => 0755,
        content => "export OAE_HOME=${oae::params::basedir}\nexport OAE_LOG_DIR=${log_dir}",
    }

    # Create a directory that is siblings of the sling directory.
    # Create a link underneath the sling directory to the sling sibling.
    # The allows us to delete the sling directory and preserve certain folders/data.
    define linked_oae_dir() {
        file { "${oae::app::setup::save_dir}/${name}":
            ensure => directory,
            owner  => $oae::params::user,
            group  => $oae::params::group,
            mode   => 0755,
            require => File[$oae::app::setup::save_dir],
        }

        file { "${oae::app::setup::sling_dir}/${name}":
            ensure => link,
            target => "${oae::app::setup::save_dir}/${name}",
            require => [ File["${oae::app::setup::save_dir}/${name}"], File[$oae::app::setup::sling_dir] ],
        }
    }

    linked_oae_dir { 'activemq-data': }
    linked_oae_dir { 'solr': }

    # The sling logging bundle causes the config admin service to write configs under org/apache/sling/...
    # TODO: we may want to tighten up the perms in this directory to avoid runtime reconfigurations
    file { "${config_dir}/org/apache":
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 0644,
    }
}
