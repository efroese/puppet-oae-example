#
# Apache virtualhost that serves untrusted OAE content via a proxy balancer
#
class rsmart-common::oae::apache::untrusted (
    $cert,
    $certkey,
    $certchain"
    ){

    Class['Localconfig'] -> Class['Rsmart-common::Oae::Apache::Untrusted']

    ###########################################################################
    # https://${localconfig::http_name_untrusted}:443

    # Serve untrusted content from another hostname on port 443
    apache::vhost-ssl { "${localconfig::http_name_untrusted}:443":
        sslonly  => true,
        cert     => $cert,
        certkey  => $certkey,
        certchain => $certchain,
        template  => 'rsmart-common/vhost-untrusted.conf.erb',
    }

    # Balancer pool for untrusted content
    apache::balancer { "apache-balancer-oae-app-untrusted":
        vhost      => "${localconfig::http_name_untrusted}:443",
        location   => "/",
        proto      => "http",
        members    => $localconfig::apache_lb_members_untrusted,
        params     => ["retry=20", "min=3", "flushpackets=auto"],
        standbyurl => $localconfig::apache_lb_standbyurl,
    }

}
