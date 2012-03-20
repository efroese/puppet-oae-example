#
# = Class kaleidoscope::analytics
# Set up the kaleidoscope log analytics
#
# = Parameters
# $basedir:: The root of the installation
# $user:: The user to run the cron job
#
# = Requires
# Class['Oae::Preview_processor::Init']
#
class kaleidoscope::analytics(
    $basedir,
    $user) {

    Class['Oae::Preview_processor::Init'] -> Class ['Kaleidoscope::Analytics']

    package { ['net-scp', 'net-sftp', 'minitar', ]:
        provider => gem,
        ensure => installed,
    }

    # Drop the ruby script
    file { "${basedir}/bin/parse_logs.rb":
        source => "puppet:///modules/kaleidoscope/parse_logs.rb",
        owner  => root,
        group  => root,
        mode   => 755,
    }

    file { "${basedir}/bin/worlds.txt":
        source => "puppet:///modules/kaleidoscope/worlds.txt",
        owner  => root,
        group  => root,
        mode   => 644,
    }

    # Drop the script for the cron job
    file { "${basedir}/bin/run_kal_analytics.sh":
        content => template('kaleidoscope/run_kal_analytics.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }

    cron { 'parse_logs':
        command => "${basedir}/bin/run_kal_analytics.sh",
        user => $user,
        ensure => present,
        hour => '0',
        minute => '15',
        require => [
            File["${basedir}/bin/run_kal_analytics.sh"],
        ],
    }

}
