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

    @group { 'lspeelmon': gid => '801' }
    @user { 'lspeelmon': 
        ensure     => present,
        uid        => '801',
        gid        => 'lspeelmon',
        home       => '/home/lspeelmon',
        managehome => true,
    }

    @group { 'dgillman': gid => '802' }
    @user { 'dgillman': 
        ensure     => present,
        uid        => '802',
        gid        => 'dgillman',
        home       => '/home/dgillman',
        managehome => true,
    }

    @group { 'cramaker': gid => '803' }
    @user { 'cramaker': 
        ensure     => present,
        uid        => '803',
        gid        => 'cramaker',
        home       => '/home/cramaker',
        managehome => true,
    }

    @group { 'efroese': gid => '804' }
    @user { 'efroese': 
        ensure     => present,
        uid        => '804',
        gid        => 'efroese',
        home       => '/home/efroese',
        managehome => true,
    }

    @group { 'karagon': gid => '805' }
    @user { 'karagon': 
        ensure     => present,
        uid        => '805',
        gid        => 'karagon',
        home       => '/home/karagon',
        managehome => true,
    }

    @group { 'efroese': gid => '806' }
    @user { 'efroese': 
        ensure     => present,
        uid        => '806',
        gid        => 'efroese',
        home       => '/home/efroese',
        managehome => true,
    }

    @group { 'dthomson': gid => '807' }
    @user { 'dthomson': 
        ensure     => present,
        uid        => '807',
        gid        => 'dthomson',
        home       => '/home/dthomson',
        managehome => true,
    }

    @group { 'mflitsch': gid => '808' }
    @user { 'mflitsch': 
        ensure     => present,
        uid        => '808',
        gid        => 'mflitsch',
        home       => '/home/mflitsch',
        managehome => true,
    }

    @group { 'ppilli': gid => '809' }
    @user { 'ppilli': 
        ensure     => present,
        uid        => '809',
        gid        => 'ppilli',
        home       => '/home/ppilli',
        managehome => true,
    }

    @group { 'mdesimone': gid => '810' }
    @user { 'mdesimone': 
        ensure     => present,
        uid        => '810',
        gid        => 'mdesimone',
        home       => '/home/mdesimone',
        managehome => true,
    }
}
