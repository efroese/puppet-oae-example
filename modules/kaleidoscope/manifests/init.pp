class kaleidoscope {
    
}

class kaleidoscope::analytics {

    Class['oae::preview_processor::init'] -> Class ['Kaleidoscope::Analytics']

    package { 'net-scp':
        ensure => installed,
        provider => gem
    }
    package { 'net-sftp':
        ensure => installed,
        provider => gem
    }

    ###########################################################################
    # Drop the ruby script
    file { "${oae::params::basedir}/bin/parse_logs.rb":
        source => "puppet:///modules/kaleidoscope/parse_logs.rb",
        owner  => root,
        group  => root,
        mode   => 755,
    }
    file { "${oae::params::basedir}/bin/worlds.txt":
        source => "puppet:///modules/kaleidoscope/worlds.txt",
        owner  => root,
        group  => root,
        mode   => 644,
    }

    ###########################################################################
    # Drop the script for the cron job
    file { "${oae::params::basedir}/bin/run_kal_analytics.sh":
        content => template('kaleidoscope/run_kal_analytics.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }

    cron { 'parse_logs':
        command => "${oae::params::basedir}/bin/run_kal_analytics.sh",
        user => $oae::params::user,
        ensure => present,
        hour => '0',
        minute => '15',
        require => [
            File["${oae::params::basedir}/bin/run_kal_analytics.sh"],
        ],
    }

}
