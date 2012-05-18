#
# Apache virtualhost that serves trusted OAE content via a proxy balancer
#
class rsmart-common::oae::apache::trusted (
    $cert,
    $certkey,
    $certchain
    ) {

    Class['Localconfig'] -> Class['Rsmart-common::Oae::Apache::Trusted']

    ###########################################################################
    # https://${localconfig::http_name}:443

    # Serve the OAE app (trusted content) on 443
    apache::vhost-ssl { "${localconfig::http_name}:443":
        sslonly  => true,
        cert     => $cert,
        certkey  => $certkey,
        certchain => $certchain,
        template  => 'rsmart-common/vhost-trusted.conf.erb',
    }

    $locations_noproxy = $localconfig::locations_noproxy ? {
        undef => ['/server-status', '/balancer-manager', '/access', '/imsblti'],
        default => $localconfig::locations_noproxy
    }

    # Balancer pool for trusted content
    apache::balancer { "apache-balancer-oae-app":
        vhost      => "${localconfig::http_name}:443",
        location   => "/",
        locations_noproxy => $localconfig::mock_cle_content ? {
            # Don't proxy to the access and lti tools.
            # This is just a workaround, not a comprehensive list of CLE urls
            true  => $locations_noproxy,
            default => ['/server-status', '/balancer-manager'],
        },
        proto      => "http",
        members    => $localconfig::apache_lb_members,
        params     => $localconfig::apache_lb_params,
        standbyurl => $localconfig::apache_lb_standbyurl,
        template   => 'rsmart-common/balancer-trusted.erb',
    }

}