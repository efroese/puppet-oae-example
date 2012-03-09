/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see apache::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  include apache

*/
class apache ($httpd_conf_template='apache/httpd.conf.erb'){
  case $::operatingsystem {
    Debian,Ubuntu: {
        class { 'apache::debian':
            httpd_conf_template => $httpd_conf_template,
        }
    }
    RedHat,CentOS,Linux,Amazon: {
        class { 'apache::redhat':
            httpd_conf_template => $httpd_conf_template,
        }
    }
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
