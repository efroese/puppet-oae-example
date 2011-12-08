class users { 
	@group { 'sakai':
		gid => 8080,
	}

	@user { 'sakai':
		ensure => present,
		uid => 8080,
		gid => 8080,
		home       => '/home/sakai',
		managehome => true
	}
	
}
