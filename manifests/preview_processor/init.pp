# = Class: oae::preview_processor
#
# Install the OAE preview processor
#
# == Parameters:
#
# $admin_password::   The OAE admin password
#
# $upload_protocol::   The protocol that the preview pocessor will use to upload images. (https or http)
#
# $nakamura_git::   The url to your git repository (optional)
#
# $nakamura_tag::   The tag to check out (optional)
#
class oae::preview_processor::init (
        $admin_password='admin',
        $upload_url,
        $nakamura_git,
        $nakamura_tag=undef) {

    Class['oae::params'] -> Class['oae::preview_processor::init']

    class { 'oae::preview_processor::openoffice': }
    class { 'oae::preview_processor::gems': }

    if !defined(File["${oae::params::basedir}/bin"]) {
        file { "${oae::params::basedir}/bin":
            ensure => directory,
            owner  => $oae::params::user,
            group  => $oae::params::group,
            mode   => 750,
        }
    }

    # Checkout a specific tag if specified
    if $nakamura_tag != undef {
        # clone a copy of nakamura to /usr/local/sakaioae/nakamura.
        # technically we only need the preview_processor
        exec { "clone nakamura":
            command => "git clone ${nakamura_git} ${oae::params::basedir}/nakamura",
            creates => "${oae::params::basedir}/nakamura",
            require => Package['git'],
            notify  => Exec['checkout nakamura tag'],
        }
        
        exec { "checkout nakamura tag":
            command => "git checkout ${nakamura_tag}",
            cwd     => "${oae::params::basedir}/nakamura",
            require => [ Package['git'], Exec['clone nakamura'], ],
            refreshonly => true, # only do this when notified, not on every run
        }
    }
    else {
        # clone a copy of nakamura to /usr/local/sakaioae/nakamura.
        # technically we only need the preview_processor
        exec { "clone nakamura":
            command => "git clone ${nakamura_git} ${oae::params::basedir}/nakamura",
            creates => "${oae::params::basedir}/nakamura",
            require => Package['git'],
        }
    }

    file { "${oae::params::basedir}/.oae_credentials.txt":
        owner => $oae::params::user,
        group => $oae::params::group,
        mode  => 0600,
        content => "${upload_url} ${admin_password}",
    }

    ###########################################################################
    # Drop the script for the cron job
    file { "${oae::params::basedir}/bin/run_preview_processor.sh":
        content => template('oae/run_preview_processor.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    $full_os = "${operatingsystem}${lsbmajdistrelease}"

    cron { 'run_preview_processor':
        command => $full_os ? {
            /CentOS5|RedHat5/ => "PATH=/opt/local/bin:\$PATH ${oae::params::basedir}/bin/run_preview_processor.sh",
            default           => "${oae::params::basedir}/bin/run_preview_processor.sh",
        },
        user => $oae::params::user,
        ensure => present,
        minute => '*',
        require => [
            File["${oae::params::basedir}/bin/run_preview_processor.sh"],
            File["${oae::params::basedir}/.oae_credentials.txt"],
        ],
    }
}
