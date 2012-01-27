class centos {
    package { 'redhat-lsb': ensure => installed }

    if $lsbmajdistrelease == '6' or
        ($operatingsystem == 'Amazon' and $operatingsystemrelease == '2011.09') {
        package { 'rpmforge-release':
            source => 'http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm',
            ensure => installed
        }
    }

    if $operatingsystem == 'Amazon' and $operatingsystemrelease == '2011.09' {
        yumrepo { 'centos6-base':
            mirrorlist => "http://mirrorlist.centos.org/?release=6&arch=${architecture}&repo=os",
            gpgcheck   => '1',
            gpgkey     => 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6',
            priority   => 1,
        }
    }
}
