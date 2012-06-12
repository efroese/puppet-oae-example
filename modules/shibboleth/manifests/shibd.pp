/*

== Class: shibboleth::shibd

Enables the shibd daemon.

Requires:
- Class[shibboleth::sp]
- selinux module

*/
class shibboleth::shibd {

  service { "shibd":
    ensure  => running,
    enable  => true,
    require => Package["shibboleth"],
  }

  # apache must be able to connect to shibd's socket.
  if $::selinux == true {

    file { "/var/run/shibboleth/":
      ensure  => "directory",
      seltype => "httpd_var_run_t",
      notify  => Service["shibd"],
      require => Package["shibboleth"],
    }

    selinux::module { "shibd":
      notify  => Selmodule["shibd"],
      content => "# file managed by puppet

module shibd 1.0;

require {
        type httpd_t;
        type initrc_t;
        class unix_stream_socket connectto;
}

#============= httpd_t ==============
allow httpd_t initrc_t:unix_stream_socket connectto;
",

    }

    selmodule { "shibd":
      ensure      => present,
      syncversion => true,
    }

  }

}
