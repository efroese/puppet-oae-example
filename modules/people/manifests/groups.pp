#
# User resources for sakai
#
class people::groups {

    # rsmart
	@group { $localconfig::group:
		gid => $localconfig::gid,
	}

    # Real live human beings!
    @group { 'lspeelmon': gid => '501' }
    @group { 'dthomson':  gid => '502' }
    @group { 'cramaker':  gid => '503' }
    @group { 'efroese':   gid => '504' }
    @group { 'kcampos':   gid => '505' }
    @group { 'dgillman':  gid => '506' }

    # Services/Applications/Robots/Aliens
    @group { 'hyperic':   gid => '701' }
}
