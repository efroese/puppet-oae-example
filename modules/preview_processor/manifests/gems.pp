class preview_processor::gems {

    # Ruby Gems for the preview_processor.rb script
    $ruby_gems = ['json', 'docsplit', 'rmagick']

    package { $ruby_gems:
        provider => 'gem',
        ensure => installed,
        require => Package['rubygems'],
    }
}
