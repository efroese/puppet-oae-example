# = Class: oae::preview_processor::gems
#
# Set up the ruby gems needed by the preview processor
#
class oae::preview_processor::gems {

    Class['oae::preview_processor::packages'] -> Class['oae::preview_processor::gems']

    define opt_gem($version = ""){
        if $version == "" {
            exec { "gem-install-${name}":
                command => "/opt/local/bin/gem install ${name}",
                unless => "/opt/local/bin/gem list --local | grep ${name}",
            }
        }
        else {
            exec { "gem-install-${name}":
                command => "/opt/local/bin/gem install ${name} -v ${version}",
                unless => "/opt/local/bin/gem list --local ${name} | grep '(${version})'",
            }
        }
    }

    define gem($version) {
        package { $name:
            ensure   => $version,
            provider => 'gem',
        }
    }

    $nakamura_gem_version = '0.6'
    $bundler_gem_version  = '1.0.18'
    $curb_gem_version     = '0.7.15'
    $docsplit_gem_version = '0.6.3'
    $json_gem_version     = '1.6.3'
    $rmagick_gem_version  = '2.13.1'
    $getopt_gem_version   = '1.4.1'
    $daemons_gem_version  = '1.1.5'
    $rbtagger_version     = '0.4.7'
    $termextract_gem_version  = '0.5.2'

    if $operatingsystem == 'CentOS' and $lsbmajdistrelease == '5' {
        opt_gem { 'curb':     version => $curb_gem_version }
        opt_gem { 'bundler':  version => $bundler_gem_version }
        opt_gem { 'docsplit': version => $docsplit_gem_version }
        opt_gem { 'json':     version => $json_gem_version }
        opt_gem { 'rmagick':  version => $rmagick_gem_version }
        opt_gem { 'getopt':   version => $getopt_gem_version }
        opt_gem { 'daemons':  version => $daemons_gem_version }
        opt_gem { 'rbtagger': version => $rbtagger_version }
        opt_gem { 'term-extract': version => $termextract_gem_version }
        opt_gem { 'nakamura': version => $nakamura_gem_version }
    } 
    else {
        gem { 'curb':     version => $curb_gem_version }
        gem { 'bundler':  version => $bundler_gem_version }
        gem { 'docsplit': version => $docsplit_gem_version }
        gem { 'json':     version => $json_gem_version }
        gem { 'rmagick':  version => $rmagick_gem_version }
        gem { 'getopt':   version => $getopt_gem_version }
        gem { 'daemons':  version => $daemons_gem_version }
        gem { 'rbtagger': version => $rbtagger_version }
        gem { 'term-extract': version => $termextract_gem_version }
        gem { 'nakamura': version => $nakamura_gem_version }
    }

    $docsplit_gem_path = $lsbmajdistrelease ? {
        '5'     => "/opt/local/lib64/ruby/gems/1.9.1/gems/docsplit-${docsplit_gem_version}",
        default => "/usr/lib/ruby/gems/1.8/gems/docsplit-${docsplit_gem_version}",
    }

    exec { "patch-docsplit":
        command => "patch -p0 < ${oae::params::basedir}/patches/info_extractor.rb.patch info_extractor.rb",
        cwd     => "${docsplit_gem_path}/lib/docsplit/",
        unless  => "grep Iconv ${docsplit_gem_path}/lib/docsplit/info_extractor.rb",
        require => $lsbmajdistrelease ? {
            5       => [ File["${oae::params::basedir}/patches/info_extractor.rb.patch"], Opt_gem['docsplit'] ],
            default => [ File["${oae::params::basedir}/patches/info_extractor.rb.patch"], Gem['docsplit'] ],
        },
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
