# = Class: oae::preview_processor::redhat
#
# Set up the preview processor on a redhat machine
#
class oae::preview_processor::redhat {

    Class['oae::params'] -> Class['oae::preview_processor::packages']
    
    $common_packages = ['cpp', 'gcc', 'gcc-c++', 'fontconfig-devel',
                        'poppler-utils', 'rubygems', 'GraphicsMagick']

    package { $common_packages: ensure => installed }

    $centos6_pkgs = ['cronie', 'libcurl-devel', 'ImageMagick', 'ImageMagick-devel', 'ruby-devel', 'libgcj']
    package { $centos6_pkgs: ensure => installed }

    package { 'pdftk-1.44-1.el6.rf.x86_64':
         ensure   => present,
         source   => "http://dl.dropbox.com/u/24606888/puppet-oae-files/pdftk-1.44-1.el6.rf.x86_64.rpm",
         provider => 'rpm',
         require  => Package['libgcj']
    }
}
