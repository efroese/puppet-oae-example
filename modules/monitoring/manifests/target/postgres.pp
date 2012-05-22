#
# = Class: monitoring::target::postgres
# Set up monitoring for a PostgreSQL server.
#
# == Parameters:
#
# $local_monitoring_server:: The icinga server that will actively check this host.
#
# $central_monitoring_server:: The central icinga that will receive the results of the checks
#
# == Sample Usage:
#
#  class { 'monitoring::target::postgres'
#    local_monitoring_server => 'cluster0-recon.example.com',
#    central_monitoring_server => 'central-recon.example.com',
#  } 
#
class monitoring::target::postgres(
    $local_monitoring_server,
    $central_monitoring_server,
    $command_line="/usr/bin/check_postgres.pl -H localhost --action=backends") {
        
    Class['nrpe'] -> Class['Monitoring::Target::Postgres']

    # Requires the EPEL yum repository.
    package { [ 'check_postgres', 'perl-Time-HiRes', ]:
        ensure => installed,
    }

    icinga::nrpe_service { "${::fqdn}_nrpe_postgres" :
        command_name => "check_postgres",
        command_line => $command_line,
        service_description => "PostgreSQL",
        notification_options => "w,c,u",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${::fqdn}_nrpe_postgres":
        service_description => "PoistgreSQL",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

}