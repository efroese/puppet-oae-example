
class localconfig::users {

    Class['localconfig'] -> Class['localconfig::users']

	@group { $localconfig::group:
		gid => $localconfig::gid,
	}

	@user { $localconfig::user:
		ensure => present,
		uid    => $localconfig::uid,
		gid    => $localconfig::gid,
		home   => $localconfig::basedir,
		managehome => true
	}
	
}
