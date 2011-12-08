class preview_processor::openoffice {

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
        require => Package['openoffice.org-core'],
    }
    
    file { '/etc/init.d/soffice':
        content => template('preview_processor/soffice.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    service { 'soffice':
        ensure => running,
    }
}
