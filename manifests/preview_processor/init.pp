# = Class: oae::preview_processor
#
# Install the OAE preview processor
#
# = Parameters
#
# $nakamura_git::   The url to your git repository (optional)
#
# $nakamura_tag::   The tag to check out (optional)
#
class oae::preview_processor::init ($nakamura_git, $nakamura_tag="") {

    Class['oae::params'] -> Class['oae::preview_processor::init']

    case $operatingsystem {
        /RedHat|CentOS/:   { include oae::preview_processor::redhat }
        /Debian|Ubuntu/:   { include oae::preview_processor::debian }
    }

    class { 'oae::preview_processor::openoffice': }
    class { 'oae::preview_processor::gems': }

    file { "${oae::params::basedir}/bin":
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 750,
    }



    # Checkout a specific tag if specified
    if $nakamura_tag != "" {
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

    ###########################################################################
    # Drop the script for the cron job
    file { "${basedir}/bin/run_preview_processor.sh":
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
    }
}
