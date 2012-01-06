class oae::preview_processor::gems {

    define opt_gem($version = ""){
        if $version == "" {
            exec { "gem-install-${name}":
                command => "/opt/local/bin/gem install ${name}",
                unless => "stat /opt/local/lib64/ruby/gems/1.9.1/gems/${name}-*",
            }
        }
        else {
            exec { "gem-install-${name}":
                command => "/opt/local/bin/gem install ${name} -v ${version}",
                unless => "stat /opt/local/lib64/ruby/gems/1.9.1/gems/${name}-${version}",
            }
        }
    }

    define gem($version) {
        package { $name:
            ensure => installed,
            provider => 'gem',
            version => $version
        }
    }

    if $operatingsystem == 'CentOS' and $lsbmajdistrelease == '5' {
        opt_gem { 'curb':     version => '0.7.15' }
        opt_gem { 'docsplit': version => '0.6.3' }
        opt_gem { 'json':     version => '1.6.3' }
        opt_gem { 'rmagick':  version => '2.13.1' }
        opt_gem { 'getopt':   version => '1.4.1' }
        opt_gem { 'daemons':  version => '1.1.5' }

        exec { 'patch-docsplit':
            command => "patch -p0 < ${oae::params::basedir}/patches/info_extractor.rb.patch info_extractor.rb",
            cwd     => "/opt/local/lib64/ruby/gems/1.9.1/gems/docsplit-0.6.3/lib/docsplit/",
            require => File["${oae::params::basedir}/patches/info_extractor.rb.patch"],
            unless  => 'grep Iconv /opt/local/lib64/ruby/gems/1.9.1/gems/docsplit-0.6.3/lib/docsplit/info_extractor.rb'
        }

    } 
    else {
        gem { 'curb':     version => '0.7.15' }
        gem { 'docsplit': version => '0.6.3' }
        gem { 'json':     version => '1.6.3' }
        gem { 'rmagick':  version => '2.13.1' }
        gem { 'getopt':   version => '1.4.1' }
        gem { 'daemons':  version => '1.1.5' }
        
        exec { 'patch-docsplit': 
            command => "patch -p0 < ${oae::params::basedir}/patches/info_extractor.rb.patch info_extractor.rb",
            cwd     => "/usr/lib/ruby/gems/1.8/gems/docsplit-0.6.3/lib/docsplit",
            require => File["${oae::params::basedir}/patches/info_extractor.rb.patch"],
            unless  => 'grep Iconv /usr/lib/ruby/gems/1.8/gems/docsplit-0.6.3/lib/docsplit/info_extractor.rb'
        }
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
