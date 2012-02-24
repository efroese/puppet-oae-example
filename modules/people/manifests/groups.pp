class people::groups { 
	Class['Localconfig'] -> Class['People::Groups']

	@group { "${localconfig::group}":
		gid => $localconfig::gid,
	}
}
