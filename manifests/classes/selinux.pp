# Rationale:
# - puppet selinux code kicks in automatically as soon as ruby bindings are
#   available
# - http://projects.reductivelabs.com/issues/1963 must be fixed before selinux
#   code gets run
# - selinux ruby bindings are available only on newer distributions
# - for legacy distros, http://github.com/twpayne/libselinux-ruby-puppet/ can
#   be used.

class selinux::base {

  case $operatingsystem {
    RedHat: {
      case $lsbdistcodename {
        Tikanga: { $rubypkg_alias = "libselinux-ruby-puppet" }
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


  case $puppetversion {

    "0.24.7": {

      if $issue1963fixed == "yes" {

        package { "$rubypkg_alias":
          ensure => present,
          alias => "selinux-ruby-bindings",
        }

        file { "/tmp/issue1963.patch": ensure => absent }

      }
      else {

        file { "/tmp/issue1963.patch":
          source => "puppet:///selinux/changeset_r0e467869f4d427a8c42e1c2ff6a0bb215f288b09.diff",
          ensure => present,
        }

        exec { "patch selinux.rb with issue1963.patch":
          command => "cat /tmp/issue1963.patch | patch -p0 ${rubysitedir}/puppet/util/selinux.rb",
          unless => "grep -q 'File.open(\"/proc/mounts\", NONBLOCK)' ${rubysitedir}/puppet/util/selinux.rb",
          require => File["/tmp/issue1963.patch"],
        }
      }
    }

    "0.24.6","0.24.5","0.24.4": {
      # no ruby-selinux implementation in older versions
    }

    "0.24.8": {
      package { "$rubypkg_alias":
        ensure => present,
        alias => "selinux-ruby-bindings",
      }
    }

  }
}
