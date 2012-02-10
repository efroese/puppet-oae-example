# = Class: oae::preview_processor::openoffice
#
# Install openoffice for the preview processor
#
class oae::preview_processor::openoffice {

    if $operatingsystem =~ /Amazon|Linux/ {
        $pkg_string = 'openoffice.org-core.x86_64 openoffice.org-javafilter.x86_64 openoffice.org-headless.x86_64 openoffice.org-writer.x86_64'
        exec { 'install-ooo-centos':
            command => "yum -y --enablerepo=centos-base install ${pkg_string}",
            unless  => "rpm -q ${pkg_string}",
            notify => File['/usr/lib/openoffice'],
        }
    }
    else {
        package { [ 'openoffice.org-core', 'openoffice.org-javafilter',
                    'openoffice.org-headless',  'openoffice.org-writer' ]: 
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
