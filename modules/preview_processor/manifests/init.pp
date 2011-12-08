class preview_processor {

    # Present in the base CentOS repositories
    $common_packages = ['cpp', 'fontconfig-devel', 'curl-devel', 'poppler-utils', 'rubygems']

    # From rpmforge
    $docsplit_packages = ['pdftk', 'tesseract']
    package { $docsplit_packages: ensure => installed }

    # CentOS 5, RHEL 5
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '5') {
        # CentOS needs updated ImageMagick and Ruby packages
        $centos_packages = ['ImageMagick-6.4.9-10', 'ImageMagick-devel-6.4.9-10', 'ruby1.9.2p0-1.9.2p0-1']
        package { $centos_packages: ensure => installed }
    }

    # CentOS 6, RHEL 6, Fedora
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '6') 
        || $operatingsystem == 'Fedora' {
        # Fedora can use the base packages.
        $fedora_packages = ['cron', 'ImageMagick', 'ImageMagick-devel']
        package { $fedora_packages: ensure => installed }
    }

    ###########################################################################
    # Run the OpenOffice service to convert docs
    $ooo_packages = [
            'openoffice.org-core',
            'openoffice.org-javafilter', 
            'openoffice.org-headless', 
            'openoffice.org-writer.x86_64',
        ]

    package { $ooo_packages: 
        ensure => installed,
        notify => Service['soffice']
    }
        
    # Create Link /usr/lib/openoffice
    file { '/usr/lib/openoffice':
        ensure => link,
        target => '/usr/lib64/openoffice.org3',
        require => Packages['openoffice.org-core'],
    }
    
    file { '/etc/init.d/soffice':
        source => 'puppet://modules/preview_processor/soffice.sh',
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    service { 'soffice':
        ensure => running,
    }
    
    ###########################################################################
    # Ruby Gems for the preview_processor.rb script
    $ruby_gems = ['json', 'docsplit', 'rmagick']

    package { $ruby_gems: 
        provider => 'gem',
        ensure => installed,
        require => Package['rubygems'],
    }

    ###########################################################################
    # A place for PP-specific files
    file { '/usr/local/share/preview_processor':
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 754,
    }

    ###########################################################################
    # Drop the script for the cron job
    file { '/usr/local/share/preview_processor/run_preview_processor.sh':
        source => 'puppet://modules/preview_processor/run_preview_processor.sh',
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    cron { 'run_preview_processor':
        command => '/usr/local/share/preview_processor/run_preview_processor.sh',
        ensure => present,
        user => root,
    }
}