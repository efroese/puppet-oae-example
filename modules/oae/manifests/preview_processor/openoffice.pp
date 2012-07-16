# = Class: oae::preview_processor::openoffice
#
# Install openoffice for the preview processor
#
class oae::preview_processor::openoffice {

    if $operatingsystem =~ /Amazon|Linux/ {
        $pkg_string = 'libreoffice-core.x86_64 libreoffice-javafilter.x86_64 libreoffice-headless.x86_64 libreoffice-base.x86_64 libreoffice-calc.x86_64 libreoffice-draw.x86_64 libreoffice-math.x86_64 libreoffice-writer.x86_64'
        exec { 'install-ooo-centos':
            command => "yum -y --enablerepo=centos6-base install ${pkg_string}",
            unless  => "rpm -q ${pkg_string}",
            notify => File['/usr/lib/libreoffice'],
        }
    }
    else {
        package { [ 'libreoffice-core',
                    'libreoffice-brand',
                    'libreoffice-javafilter',
                    'libreoffice-headless',
                    'libreoffice-base-core',
                    'libreoffice-calc-core',
                    'libreoffice-draw-core',
                    'libreoffice-math-core',
                    'libreoffice-writer-core' ]:
            ensure => installed,
            notify => File['/usr/lib/openoffice'],
        }
    }
    # Create Link /usr/lib/libreoffice
    file { '/usr/lib/libreoffice':
        ensure => link,
        target => '/usr/lib64/libreoffice3',
        require => $operatingsystem ? {
            /Amazon|Linux/ => Exec['install-ooo-centos'],
            default => Package['libreoffice-core'],
        }
    }
}
