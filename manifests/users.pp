class users { 
	@group { 'sakaioae':
		gid => 8080,
	}

	@user { 'sakaioae':
		ensure => present,
		uid => 8080,
		gid => 8080,
		home => '/usr/local/sakaioae',
		managehome => true
	}
	
}
