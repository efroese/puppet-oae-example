class people::users {

	Class['Localconfig'] -> Class['People::Users']
	Class['People::Groups'] -> Class['People::Users']

	@user { $localconfig::user:
		uid => $localconfig::uid,
		gid => $localconfig::gid,
		home => "/home/${localconfig::user}",
		managehome => true,
	}
}
