# = Class: oae::preview_processor::amazon
#
# Set up the preview processor on a redhat machine
#
class oae::preview_processor::amazon {

    Class['oae::params'] -> Class['oae::preview_processor::packages']
    
    $common_packages = [ 'cronie', 'cpp', 'gcc', 'gcc-c++',
        'fontconfig-devel', 'libcurl-devel',
        'GraphicsMagick', 'ImageMagick', 'ImageMagick-devel',
        'poppler-utils', 'rubygems',
        'ruby-devel', 'libgcj', 'pdftk', ]

    package { $common_packages: ensure => installed }

    exec { 'yum-install-tk-centos6-repo':
        command => "yum -y -t --enablerepo=centos6-base install tk",
        unless  => 'rpm -q tk',
    }
}