# Rationale:
# - puppet selinux code kicks in automatically as soon as ruby bindings are
#   available
# - http://projects.reductivelabs.com/issues/1963 must be fixed before selinux
#   code gets run
# - selinux ruby bindings are available only on newer distributions
# - for legacy distros, http://github.com/twpayne/libselinux-ruby-puppet/ can
#   be used.

class selinux::base {

  # should be pushed with "factsync = true"
  file { "/var/puppet/lib/puppet/facter/issue1963fixed.rb": }

  if $issue1963fixed {

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

    package { "$rubypkg_alias":
      ensure => present,
      alias => "selinux-ruby-bindings",
      require => File["/var/puppet/lib/puppet/facter/issue1963fixed.rb"],
    }

    file { "/tmp/issue1963.patch": ensure => absent }

  }
  else {
    package {["libselinux-ruby-puppet", "libselinux-ruby", "libselinux-ruby1.8", "libselinux-puppet-ruby1.8"]:
      ensure => absent
    }

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
