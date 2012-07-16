# = Class: oae::preview_processor::redhat
#
# Set up the preview processor on a redhat machine
#
class oae::preview_processor::redhat {

    Class['oae::params'] -> Class['oae::preview_processor::packages']

    $packages = ['cronie', 'cpp', 'gcc', 'gcc-c++',
                'fontconfig-devel', 'libcurl-devel',
                'GraphicsMagick', 'ImageMagick', 'ImageMagick-devel',
                'poppler-utils', 'rubygems',
                'libxml2-devel', 'libxslt-devel', 'libffi-devel']

    package { $packages: ensure => installed }

    if !defined(Package['ruby-devel']) {
        package { 'ruby-devel': ensure => installed }
    }

    exec { 'install pdftk-1.44-1.el6.rf.x86_64':
        command => "rpm -i --nodeps http://dl.dropbox.com/u/24606888/puppet-oae-files/pdftk-1.44-1.el6.rf.x86_64.rpm",
        unless  => "rpm -q pdftk-1.44-1.el6.rf.x86_64"
    }
}
