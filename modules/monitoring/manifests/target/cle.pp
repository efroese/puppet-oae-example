#
# = Class: monitoring::target::cle
# Set up monitoring for a Sakai CLE server.
#
# == Parameters:
#
# $local_monitoring_server:: The icinga server that will actively check this host.
#
# $central_monitoring_server:: The central icinga that will receive the results of the checks
#
# == Sample Usage:
#
#  class { 'monitoring::target::cle'
#    local_monitoring_server => 'cluster0-recon.example.com',
#    central_monitoring_server => 'central-recon.example.com',
#  } 
#
class monitoring::target::cle(
    $local_monitoring_server,
    $central_monitoring_server,
    $hostname,
    $user,
    $password) {

    Class['nrpe'] -> Class['Monitoring::Target::Cle']

}