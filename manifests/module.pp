define apache::module ($ensure='present') {

  include apache::params

  $a2enmod_deps = $operatingsystem ? {
    /RedHat|CentOS|Amazon|Linux/ => [
      Package["httpd"],
      File["/etc/httpd/mods-available"],
      File["/etc/httpd/mods-enabled"],
      File["/usr/local/sbin/a2enmod"],
      File["/usr/local/sbin/a2dismod"]
    ],
    /Debian|Ubuntu/ => Package["apache"],
  }

  if $selinux == "true" {
    apache::redhat::selinux {$name: }
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        command => $operatingsystem ? {
          /RedHat|CentOS|Amazon|Linux/ => "/usr/local/sbin/a2enmod ${name}",
          default => "/usr/sbin/a2enmod ${name}"
        },
        onlyif => "[ ! -e ${apache::params::conf}/mods-enabled/${name}.load ]",
        require => $a2enmod_deps,
        notify  => Service["apache"],
      }
    }

    'absent': {
      exec { "a2dismod ${name}":
        command => $operatingsystem ? {
          /RedHat|CentOS|Amazon|Linux/ => "/usr/local/sbin/a2dismod ${name}",
          /Debian|Ubuntu/ => "/usr/sbin/a2dismod ${name}",
        },
        onlyif => "[ -e ${apache::params::conf}/mods-enabled/${name}.load ]",
        require => $a2enmod_deps,
        notify  => Service["apache"],
       }
    }

    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}
