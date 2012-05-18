#
# Apache global config
#
class rsmart-common::oae::apache (
    $httpd_conf_template = 'rsmart-common/httpd.conf.erb',
    $vhost_80_template   = 'rsmart-common/vhost-80.conf.erb'
    ) {

    Class['Localconfig'] -> Class['Rsmart-common::Oae::Apache']

    class { 'apache':
        httpd_conf_template => $httpd_conf_template
    }

    class { 'apache::ssl': }

    # Headers is not in the default set of enabled modules
    apache::module { 'headers': }
    apache::module { 'deflate': }

    file { "/etc/httpd/conf.d/traceenable.conf":
        owner => root,
        group => root,
        mode  => 644,
        content => 'TraceEnable Off',
    }

    apache::vhost { "${localconfig::http_name}:80":
        template => $vhost_80_template,
    }
}