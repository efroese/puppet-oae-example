# = Class: oae::preview_processor::redhat
#
# Set up the preview processor on a redhat machine
#
class oae::preview_processor::redhat {

    Class['oae::params'] -> Class['oae::preview_processor::redhat']

    $common_packages = ['cpp', 'gcc', 'fontconfig-devel', 'poppler-utils', 'pdftk', 'rubygems', 'tk', 'GraphicsMagick']
    package { $common_packages: ensure => installed }

    # CentOS 5, RHEL 5
    if  $lsbmajdistrelease == '5'  {

        $centos5_pkgs = ['curl-devel', 'tesseract', 'bzip2-devel', 'ghostscript-devel', 'jasper-devel',
			'lcms-devel', 'libX11-devel', 'libXext-devel', 'libXt-devel', 'libjpeg-devel', 
			'libtiff-devel', 'djvulibre', 'librsvg2', 'libwmf',]
        package { $centos5_pkgs: ensure => installed }

        # CentOS needs updated ImageMagick and Ruby packages
        package { 'ruby1.9.2p0-1.9.2p0-1.x86_64':
             ensure   => present,
             # This is efroese's personal dropbox
             # TODO find a better place to host these files.
             source   => "http://dl.dropbox.com/u/24606888/puppet-oae-files/ruby1.9.2p0-1.9.2p0-1.x86_64.rpm",
             provider => 'rpm',
        }
        
        package { 'ImageMagick-6.4.9-10.x86_64':
             ensure   => present,
             source   => "http://dl.dropbox.com/u/24606888/puppet-oae-files/ImageMagick-6.4.9-10.x86_64.rpm",
             provider => 'rpm',
        }

        package { 'ImageMagick-devel-6.4.9-10.x86_64':
             ensure   => present,
             source   => "http://dl.dropbox.com/u/24606888/puppet-oae-files/ImageMagick-devel-6.4.9-10.x86_64.rpm",
             provider => 'rpm',
        }

        # Reconfigure the library loader to look in /opt/local/lib64
        file { "/etc/ld.so.conf.d/optlocal.conf":
            owner => root, 
            group => root, 
            mode  => 750,
            content => '/opt/local/lib64',
            notify => Exec['ldconfig-ruby19'],
        }

        exec { 'ldconfig-ruby19':
            command => "/sbin/ldconfig",
            unless  => 'ldd /opt/local/bin/ruby  | grep libruby.so.1.9'
        } 
    } 

    # CentOS 6, RHEL 6
    if $lsbmajdistrelease == '6' {
        $centos6_pkgs = ['cronie', 'curlpp-devel', 'ImageMagick', 'ImageMagick-devel', 'ruby-devel']
        package { $centos6_pkgs: ensure => installed }
    }

    if $operatingsystem == 'Amazon' and $operatingsystemrelease == '2011.09' {
        $amazon_pkgs = ['cronie', 'ImageMagick', 'ImageMagick-devel', 'ruby-devel']
        package { $amazon_pkgs: ensure => installed }
    }
}
