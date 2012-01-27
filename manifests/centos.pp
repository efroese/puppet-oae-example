class centos {
    package { 'redhat-lsb': ensure => installed }

    if $operatingsystem == 'Amazon' and $operatingsystemrelease == '2011.09' {
        yumrepo { 'centos6-base':
            name       => 'centos6-base',
            mirrorlist => "http://mirrorlist.centos.org/?release=6&arch=${architecture}&repo=os",
            gpgcheck   => '1',
            gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6',
            priority   => 1,
        }
    }
}
