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
# $nakamura_zip::   The url to a zip of nakamura.
#
#
class oae::preview_processor::init (
        $admin_password='admin',
        $upload_url,
        $nakamura_zip='http://nodeload.github.com/sakaiproject/nakamura/zipball/master') {

    Class['oae::params'] -> Class['oae::preview_processor::init']

    class { 'oae::preview_processor::gems': }
    class { 'oae::preview_processor::openoffice': }
    class { 'oae::preview_processor::packages': }

    if !defined(File["${oae::params::basedir}/bin"]) {
        file { "${oae::params::basedir}/bin":
            ensure => directory,
            owner  => $oae::params::user,
            group  => $oae::params::group,
            mode   => 750,
        }
    }

    exec { 'download nakamura':
        command => "curl -o nakamura.zip ${nakamura_zip}",
        cwd     => $oae::params::basedir,
        user    => $oae::params::user,
        creates => "${oae::params::basedir}/nakamura.zip",
        notify  => Exec['unpack nakamura'],
        timeout => 0,
    }

    exec { 'unpack nakamura':
        command => 'unzip nakamura.zip',
        cwd     => $oae::params::basedir,
        user    => $oae::params::user,
        refreshonly => true,
        require => Exec['download nakamura'],
        timeout => 0,
    }

    exec { 'mv nakamura':
        command => "mv `unzip -l nakamura.zip | head -5 | tail -1 | awk '{ print \$4 }'` nakamura",
        cwd     => $oae::params::basedir,
        user    => $oae::params::user,
        creates => "${oae::params::basedir}/nakamura",
        require => Exec['unpack nakamura'],
        timeout => 0,
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
        command => "${oae::params::basedir}/bin/run_preview_processor.sh",
        user => $oae::params::user,
        ensure => present,
        minute => '*',
        require => [
            File["${oae::params::basedir}/bin/run_preview_processor.sh"],
            File["${oae::params::basedir}/.oae_credentials.txt"],
        ],
    }
}
