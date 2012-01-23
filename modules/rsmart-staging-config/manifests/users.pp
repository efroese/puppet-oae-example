#
# User resources for sakai
#
class localconfig::users {

    Class['localconfig'] -> Class['localconfig::users']

	@group { $localconfig::group:
		gid => $localconfig::gid,
	}

	@user { $localconfig::user:
		ensure => present,
		uid    => $localconfig::uid,
		gid    => $localconfig::gid,
		home   => '/home/rsmart',
		managehome => true
	}

    @group { 'hyperic': gid => '701' }
    @user { 'hyperic': 
        ensure     => present,
        uid        => '701',
        gid        => 'hyperic',
        home       => '/home/hyperic',
        managehome => true,
    }

    @group { 'lspeelmon': gid => '501' }
    @user { 'lspeelmon': 
        ensure     => present,
        uid        => '501',
        gid        => 'lspeelmon',
        home       => '/home/lspeelmon',
        managehome => true,
        groups     => ['wheel',],
    }

    @group { 'dgillman': gid => '506' }
    @user { 'dgillman': 
        ensure     => present,
        uid        => '506',
        gid        => 'dgillman',
        home       => '/home/dgillman',
        managehome => true,
        groups     => ['wheel',],
    }

    @group { 'cramaker': gid => '503' }
    @user { 'cramaker': 
        ensure     => present,
        uid        => '503',
        gid        => 'cramaker',
        home       => '/home/cramaker',
        managehome => true,
        groups     => ['wheel',],
    }

    @group { 'dthomson': gid => '502' }
    @user { 'dthomson': 
        ensure     => present,
        uid        => '502',
        gid        => 'dthomson',
        home       => '/home/dthomson',
        managehome => true,
        groups     => ['wheel',],
    }

    @group { 'efroese': gid => '504' }
    @user { 'efroese':
        ensure     => present,
        uid        => '504',
        gid        => 'efroese',
        home       => '/home/efroese',
        managehome => true,
        groups     => ['wheel',],
    }
}
