#
# User resources for sakai
#
class people::groups {

    Class['Localconfig'] -> Class['People::Groups']

    # rsmart
	@group { "${localconfig::group}":
		gid => $localconfig::gid,
	}

    # Real live human beings!
    @group { 'lspeelmon': gid => '501' }
    @group { 'dthomson':  gid => '502' }
    @group { 'cramaker':  gid => '503' }
    @group { 'efroese':   gid => '504' }
    @group { 'kcampos':   gid => '505' }
    @group { 'dgillman':  gid => '506' }
    @group { 'mdesimone': gid => '507' }

    # Services/Applications/Robots/Aliens
    @group { 'hyperic':   gid => '701' }
    @group { 'rsmartian':   gid => '800' }
    @group { 'devops':   gid => '900' }
}
