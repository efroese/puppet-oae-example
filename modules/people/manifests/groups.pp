#
# User resources for sakai
#
class people::groups ($sakai_group='sakaioae', $gid='8080') {

    # rsmart
	@group { $sakai_group:
		gid => $gid,
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
