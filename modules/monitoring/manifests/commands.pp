#
# = Class: monitoring::commands
#  Default set of commands for icinga
#
class monitoring::commands { 

    class { 'monitoring::commands::base': }
    class { 'monitoring::commands::notify': }
    class { 'monitoring::commands::esx': }

    $mail_cmd_location = $::operatingsystem ? {
        centos => '/bin/mail',
        default => '/usr/bin/mail'
    }

}
