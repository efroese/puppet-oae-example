#
# Basic apache config for OAE httpd LBs
#
class rsmart-common::oae::apache::http (
    $httpd_conf_template = 'rsmart-common/httpd.conf.erb',
    $vhost_80_template   = 'rsmart-common/vhost-80.conf.erb'
    ) {

    Class['Localconfig'] -> Class['Rsmart-common::Oae::Apache::Http']

    class { 'apache':
        httpd_conf_template => $httpd_conf_template
    }

    # http://${localconfig::http_name} to redirects to 443
    apache::vhost { "${localconfig::http_name}:80":
        template => $vhost_80_template,
    }
}
