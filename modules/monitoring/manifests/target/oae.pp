#
# = Class: monitoring::target::oae
# Set up monitoring for a Sakai OAE server.
#
# == Parameters:
#
# $local_monitoring_server:: The icinga server that will actively check this host.
#
# $central_monitoring_server:: The central icinga that will receive the results of the checks
#
# == Sample Usage:
#
#  class { 'monitoring::target::oae'
#    local_monitoring_server => 'cluster0-recon.example.com',
#    central_monitoring_server => 'central-recon.example.com',
#    oae_hostname => 'oae.example.com',
#    public_content_id => 'kr349dbaa',
#    auth_content_id => 'pkbca1ea',
#  } 
#
class monitoring::target::oae(
    $local_monitoring_server,
    $central_monitoring_server,
    $oae_hostname,
    $port = "443",
    $public_content_id,
    $auth_content_id,
    $user,
    $password) {
        
    Class['nrpe'] -> Class['Monitoring::Target::Oae']

    # Check that we can view a piece of public content
    # This verifies that solr is working since /p/$id.json comes from solr
    icinga::service { "${::fqdn}_oae_public_content" :
        service_description => "OAE Public Content",
        check_command => "check_https_port_url_content!{$hostname}|${port}|/p/${public_content_id}.json|_bodyLocation",
        dependent_service_description => "",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${::fqdn}_oae_public_content":
        service_description => "OAE Public Content",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

    # Check that we can view a piece of protected content
    # This verifies that solr and authentication are working
    icinga::service { "${::fqdn}_oae_auth_content" :
        service_description => "OAE Authenticated Content",
        check_command => "check_https_auth_port_url_content!{$hostname}|${port}|/p/${auth_content_id}.json|_bodyLocation|${user}:${password}",
        dependent_service_description => "",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${::fqdn}_oae_auth_content":
        service_description => "OAE Authenticated Content",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }
}