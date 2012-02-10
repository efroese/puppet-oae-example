class centos {

    package { 'redhat-lsb': ensure => installed }

    yumrepo { 'centos6-base':
        name       => 'centos6-base',
        baseurl    => "http://mirrorlist.centos.org/?release=6&arch=${architecture}&repo=os",
        gpgcheck   => '1',
        gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6',
        priority   => '99',
        enabled    => '0',
    }
}
