# = Class: oae::preview_processor::openoffice
#
# Install openoffice for the preview processor
#
class oae::preview_processor::openoffice {

    if $operatingsystem =~ /Amazon|Linux/ {
        $pkg_string = 'openoffice.org-core.x86_64 openoffice.org-javafilter.x86_64 openoffice.org-headless.x86_64 openoffice.org-base-core.x86_64 openoffice.org-calc-core.x86_64 openoffice.org-draw-core.x86_64 openoffice.org-math-core.x86_64 openoffice.org-writer-core.x86_64'
        exec { 'install-ooo-centos':
            command => "yum -y --enablerepo=centos6-base install ${pkg_string}",
            unless  => "rpm -q ${pkg_string}",
            notify => File['/usr/lib/openoffice'],
        }
    }
    else {
        package { [ 'openoffice.org-core',
                    'openoffice.org-javafilter',
                    'openoffice.org-headless',
                    'openoffice.org-base-core',
                    'openoffice.org-calc-core',
                    'openoffice.org-draw-core',
                    'openoffice.org-math-core',
                    'openoffice.org-writer-core' ]:
            ensure => installed,
            notify => [ Service['soffice'], File['/usr/lib/openoffice'] ],
        }
    }
    # Create Link /usr/lib/openoffice
    file { '/usr/lib/openoffice':
        ensure => link,
        target => '/usr/lib64/openoffice.org3',
        require => $operatingsystem ? {
            /Amazon|Linux/ => Exec['install-ooo-centos'],
            default => Package['openoffice.org-core'],
        }
    }

    # Run the OpenOffice service to convert docs
    file { '/etc/init.d/soffice':
        content => template('oae/soffice.sh.erb'),
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    service { 'soffice':
        ensure => running,
        enable => true,
    }
}
