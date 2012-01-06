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

    if $operatingsystem == 'CentOS' and $lsbmajdistrelease == '5' {

        opt_gem { 'curb': version => '0.7.15' }
        opt_gem { 'docsplit': }
        opt_gem { 'json': }
        opt_gem { 'rmagick': }
        opt_gem { 'getopt': }
        opt_gem { 'daemons': }

    } else {

        # Ruby Gems for the preview_processor.rb script
        $ruby_gems = ['curb', 'json', 'docsplit', 'rmagick', 'getopt', 'daemons']

        package { $ruby_gems:
            provider => 'gem',
            ensure => installed,
        }
    }
}
