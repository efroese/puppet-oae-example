# = Class: oae::preview_processor::gems
#
# Set up the ruby gems needed by the preview processor
#
class oae::preview_processor::gems {

    Class['oae::preview_processor::packages'] -> Class['oae::preview_processor::gems']

    define gem($version) {
        package { $name:
            ensure   => $version,
            provider => 'gem',
        }
    }

    gem { 'bundler':  version => '1.0.18' }

    exec { 'bundle-install-nakamura':
        command => 'bundle install',
        cwd     => "${oae::params::basedir}/nakamura",
        unless  => 'bundle check',
        require => Gem['bundler'],
    }

    $docsplit_gem_path = "/usr/lib/ruby/gems/1.8/gems/docsplit-${docsplit_gem_version}"
    exec { "patch-docsplit":
        command => "patch -p0 < ${oae::params::basedir}/patches/info_extractor.rb.patch info_extractor.rb",
        cwd     => "${docsplit_gem_path}/lib/docsplit/",
        unless  => "grep Iconv ${docsplit_gem_path}/lib/docsplit/info_extractor.rb",
        require => [ File["${oae::params::basedir}/patches/info_extractor.rb.patch"], Exec['bundle-install-nakamura'] ],
    }

    file { "${oae::params::basedir}/patches":
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 0750,
    }

    file { "${oae::params::basedir}/patches/info_extractor.rb.patch":
        ensure => present,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 0640,
        content => "0a1,2
> require 'iconv'
> 
22c24
<       result = `#{cmd}`.chomp
---
>       result = Iconv.conv('ASCII//IGNORE', 'UTF8', `#{cmd}`.chomp)
"
    }
}
