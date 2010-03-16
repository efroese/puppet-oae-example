# Rationale:
# - puppet selinux code kicks in automatically as soon as ruby bindings are
#   available
# - http://projects.reductivelabs.com/issues/1963 must be fixed before selinux
#   code gets run
# - selinux ruby bindings are available only on newer distributions
# - for legacy distros, http://github.com/twpayne/libselinux-ruby-puppet/ can
#   be used.

class selinux::base {

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

    # TODO: /0\.2(4\.8|5\..*)/
    "0.24.8", "0.24.9", "0.25.0", "0.25.1", "0.25.2", "0.25.3", "0.25.4": {
      package { "$rubypkg_alias":
        ensure => present,
        alias => "selinux-ruby-bindings",
      }
    }

  }
}
