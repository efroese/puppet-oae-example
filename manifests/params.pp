class apache::params {

  $pkg = $operatingsystem ? {
    /RedHat|CentOS|Amazon/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
  }

  $root = $apache_root ? {
    "" => $operatingsystem ? {
      /RedHat|CentOS|Amazon/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
    },
    default => $apache_root
  }

  $user = $operatingsystem ? {
    /RedHat|CentOS|Amazon/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
  }

  $conf = $operatingsystem ? {
    /RedHat|CentOS|Amazon/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
  }

  $log = $operatingsystem ? {
    /RedHat|CentOS|Amazon/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
  }

  $access_log = $operatingsystem ? {
    /RedHat|CentOS|Amazon/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
  }

  $error_log = $operatingsystem ? {
    /RedHat|CentOS|Amazon/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
  }

}
