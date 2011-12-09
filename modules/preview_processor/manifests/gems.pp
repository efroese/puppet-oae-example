class preview_processor::gems {

    # Ruby Gems for the preview_processor.rb script
    $ruby_gems = ['json', 'docsplit', 'rmagick']

    package { $ruby_gems:
        provider => 'gem',
        ensure => installed,
    }

    if $operatingsystem == 'CentOS' and $lsbmajordistrelease == '5' {
        package { "curb":
            provider => 'gem',
            ensure => installed,
            version => '0.7.15',
        }
    } else {
        package { "curb":
            provider => 'gem',
            ensure => installed,
        }
    }
        
}
