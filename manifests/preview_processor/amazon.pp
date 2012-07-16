# = Class: oae::preview_processor::amazon
#
# Set up the preview processor on a redhat machine
#
class oae::preview_processor::amazon {

    Class['oae::params'] -> Class['oae::preview_processor::packages']

    exec { 'yum-install-tk-centos6-repo':
        command => "yum -y -t --enablerepo=centos6-base install tk",
        unless  => 'rpm -q tk',
    }
}
