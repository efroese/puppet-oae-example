class apache::ssl::redhat inherits apache::base::ssl {

  package {"mod_ssl":
    ensure => installed,
  }

  file {"/etc/httpd/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  apache::module { "ssl":
    ensure => present,
    require => File["/etc/httpd/conf.d/ssl.conf"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

    $release = $operatingsystem ? {
        /Amazon|Linux/ => '6',
        default          => $lsbmajdistrelease,
    }

  file {"/etc/httpd/mods-available/ssl.load":
    ensure => present,
    content => template("apache/ssl.load.rhel${release}.erb"),
    mode => 644,
    owner => "root",
    group => "root",
    seltype => "httpd_config_t",
    require => File["/etc/httpd/mods-available"],
  }
}
