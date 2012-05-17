#
# Apache global config
#
class rsmart-common::oae::apache {

    Class['Localconfig'] -> Class['Rsmart-common::Oae::Apache']

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
}