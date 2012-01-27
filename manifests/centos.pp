class centos {
	package { 'redhat-lsb': ensure => installed }

    if $lsbmajdistrelease == '6' or
        ($operatingsystem == 'Amazon' and $operatingsystemrelease == '2011.09') {
	    package { 'http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm':
	        ensure => installed
        }
	}
}
