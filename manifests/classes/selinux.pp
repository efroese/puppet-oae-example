/*
== Class: selinux::base

This class ensures selinux utilities and services are installed and running.
It will also install the ruby bindings which are required to use puppet's
selinux resource types.

*/
class selinux::base {

  service { "auditd":
    enable => true,
    ensure => running,
  }

  # required to build custom policy modules.
  package { ["checkpolicy", "policycoreutils"]: ensure => present }

  case $operatingsystem {
    RedHat: {
      case $lsbdistrelease {
        "5.4", "5.5", "5.6", "5.7", "5.8", "5.9": {
          package { "libselinux-ruby-puppet":
            ensure => absent,
            before => Package["libselinux-ruby"],
          }
          $rubypkg_alias = "libselinux-ruby"
        }
        default: { $rubypkg_alias = "libselinux-ruby-puppet" }
      }
    }

    Fedora: {
      case $lsbdistcodename {
        Cambridge: { $rubypkg_alias = "libselinux-ruby" }
        default: { $rubypkg_alias = "libselinux-ruby-puppet" }
      }
    }

    Debian: {
      case $lsbdistcodename {
        sid: { $rubypkg_alias = "libselinux-ruby1.8" }
        default: { $rubypkg_alias = "libselinux-puppet-ruby1.8" }
      }
    }

  }

  # if needed, you can fetch and build libselinux-ruby-puppet from
  # http://github.com/twpayne/libselinux-ruby-puppet
  package { "$rubypkg_alias":
    ensure => present,
    alias => "selinux-ruby-bindings",
  }
}
