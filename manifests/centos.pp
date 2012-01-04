class centos {
	package { 'redhat-lsb': ensure => installed }
	package { 'pwgen': ensure => installed }
}
