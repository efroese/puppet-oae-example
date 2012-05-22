#
# = Class: monitoring::target::mysql
# Set up monitoring for a MySQL server.
#
# == Parameters:
#
# $local_monitoring_server:: The icinga server that will actively check this host.
#
# $central_monitoring_server:: The central icinga that will receive the results of the checks
#
# == Sample Usage:
#
#  class { 'monitoring::target::mysql'
#    local_monitoring_server => 'cluster0-recon.example.com',
#    central_monitoring_server => 'central-recon.example.com',
#  } 
#
class monitoring::target::mysql(
    $local_monitoring_server,
    $central_monitoring_server) {

    Class['nrpe'] -> Class['Monitoring::Target::Mysql']

    package { 'nagios-plugins-mysql': ensure => installed }

    icinga::nrpe_service { "${::fqdn}_nrpe_mysql" :
        command_name => "check_mysql",
        command_line => "${icinga::params::nagiosplugins}/check_mysql",
        service_description => "MySQL",
        notification_options => "w,c,u",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${::fqdn}_nrpe_mysql":
        service_description => "PoistgreSQL",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

}