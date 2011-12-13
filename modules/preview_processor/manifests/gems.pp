class preview_processor::gems {

    # Ruby Gems for the preview_processor.rb script
    $ruby_gems = ['curb', 'json', 'docsplit', 'rmagick']

    if $operatingsystem == 'CentOS' and $lsbmajdistrelease == '5' {

        exec { 'gem-install-curb':
            command => '/opt/local/bin/gem install -v 0.7.15 curb',
            unless => 'stat /opt/local/lib64/ruby/gems/1.9.1/gems/curb-0.7.15',
        }

        exec { 'gem-install-json':
            command => '/opt/local/bin/gem install json',
            unless => 'stat /opt/local/lib64/ruby/gems/1.9.1/gems/json-*',
        }

        exec { 'gem-install-docsplit':
            command => '/opt/local/bin/gem install docsplit',
            unless => 'stat /opt/local/lib64/ruby/gems/1.9.1/gems/docsplit-*',
        }

        exec { 'gem-install-rmagick':
            command => '/opt/local/bin/gem install rmagick',
            unless => 'stat /opt/local/lib64/ruby/gems/1.9.1/gems/rmagick-*',
        }

    } else {

        package { $ruby_gems:
            provider => 'gem',
            ensure => installed,
        }
    }
}
