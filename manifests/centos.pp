class centos {

    package { 'redhat-lsb': ensure => installed }

    yumrepo { 'centos6-base':
        name       => 'centos6-base',
        baseurl    => "http://mirror.7x24web.net/centos/6/os/x86_64/",
        gpgcheck   => '1',
        gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6',
        priority   => '99',
        enabled    => '0',
    }
}
