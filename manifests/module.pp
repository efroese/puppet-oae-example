/*
== Definition: selinux::module

This definition builds a binary SELinux module from a supplied set of SELinux
security policies. It is then possible to load it using a Selmodule resource.

Parameters:

- *name*: the name of the SELinux module
- *workdir*: where the module source and binary files are stored. Defaults to
  "/etc/puppet/selinux"
- *dest*: where the binary module must be copied. Defaults to
  "/usr/share/selinux/targeted/"
- *content*: inline content or template of the module source
- *source*: file:// or puppet:// URI of the module source file

Example usage:

  selinux::module { "foobar":
    notify => Selmodule["foobar"],
    source => "puppet:///myproject/foobar.te",
  }

  selmodule { "foobar":
    ensure      => present,
    syncversion => true,
  }

*/
define selinux::module ($workdir="/etc/puppet/selinux", $dest="/usr/share/selinux/targeted/", $content=undef, $source=undef) {

  if !defined(File[$workdir]) {
    file { "$workdir":
      ensure => directory,
      mode   => 0700,
      owner  => "root",
    }
  }

  if $content {
    file { "${workdir}/${name}.te":
      ensure => present,
      content => $content,
      require => File[$workdir],
      notify => Exec["build selinux policy module ${name}"],
    }
  }
  if $source {
    file { "${workdir}/${name}.te":
      ensure => present,
      source => $source,
      require => File[$workdir],
      notify => Exec["build selinux policy module ${name}"],
    }
  }

  exec { "build selinux policy module ${name}":
    cwd => $workdir,
    command => "checkmodule -M -m ${name}.te -o ${name}.mod",
    refreshonly => true,
    require => [File["${workdir}/${name}.te"], Package["checkpolicy"]],
    notify => Exec["build selinux policy package ${name}"],
  }

  exec { "build selinux policy package ${name}":
    cwd => $workdir,
    command => "semodule_package -o ${dest}/${name}.pp -m ${name}.mod",
    refreshonly => true,
    require => [Exec["build selinux policy module ${name}"], Package["policycoreutils"]],
  }
}
