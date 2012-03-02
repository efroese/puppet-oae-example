class kaleidoscope {
    
}

class kaleidoscope::analytics {

    include oae::preview_processor::init

    gem { 'net-scp': ensure => installed }

    ###########################################################################
    # Drop the ruby script
    file { "${oae::params::basedir}/bin/parse_logs.rb":
        source => "puppet:///modules/kaleidoscope/parse_logs.rb",
        owner  => root,
        group  => root,
        mode   => 755,
    }

    ###########################################################################
    # Drop the script for the cron job
    file { "${oae::params::basedir}/bin/run_preview_processor.sh":
        content => template('kaleidoscope/run_kal_analytics.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }

    $full_os = "${operatingsystem}${lsbmajdistrelease}"

    cron { 'parse_logs':
        command => $full_os ? {
            /CentOS5|RedHat5/ => "PATH=/opt/local/bin:\$PATH ${oae::params::basedir}/bin/run_kal_analytics.sh",
            default           => "${oae::params::basedir}/bin/run_kal_analytics.sh",
        },
        user => $oae::params::user,
        ensure => present,
        hour => '0',
        minute => '15',
        require => [
            File["${oae::params::basedir}/bin/run_kal_analytics.sh"],
            File["${oae::params::basedir}/.oae_credentials.txt"],
        ],
    }

}
