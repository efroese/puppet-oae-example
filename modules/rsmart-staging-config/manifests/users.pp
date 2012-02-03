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
        groups     => ['lspeelmon', 'wheel',],
    }

    ssh_authorized_key { 'lspeelmon-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAp9p82llL03l1eOXpSaYBwNxu7CeOv2QevTquJpIMoaRKHFDmbaAggwUfAIRuIDPBh4b79Gvyr+1foeszgDaxHdP8rbvZFTexsvA9ImBg6bN+qRlCr5Pr+gOrYpTybAIBEuAkINMD3zOUP+SdSx/UDFcfRkpf9gS1j1qDrvzvBHLHsjcKvUHc1NqkYnO6c1xYFA+sZsQaOwRM0InuL0gBAiG68eBy4YW/rbEiSzVO6YBC95i9joxMz3KTJSySmawO922py06CUn5Xsrvka3qkvhFJ9KSs2o9cA82PCFESisrvQOSuAllE7SJ7ocLMmbrJgnhuXi81zVQ6+Fb028DOVw==',
        type => 'ssh-dss',
        user => 'lspeelmon'
    }

    @group { 'dgillman': gid => '506' }
    @user { 'dgillman': 
        ensure     => present,
        uid        => '506',
        gid        => 'dgillman',
        home       => '/home/dgillman',
        managehome => true,
        groups     => ['dgillman', 'wheel',],
    }

    ssh_authorized_key { 'dgillman-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAoxOaLODYDqQNAURGI2j2bMhFrYg/I1h7tydOMyVYh5nsu0qK/kc8RCknRNJeEABDUKfJaSQX7OwZKqPS+/R3aSBY/WxnyBX3pAJW1Lq4+1U7+y2S8Y13Fw4JXwDnHIIbNLJUHyqF+MIyl55A5inMm39Z2EEaXIr2KbpwLTsx8nmRMNvlmFov4WTui1HUAb7IM/gF9UInTGflQ5YMNZSYvMULhUldbKFpW/i1OGcwZb8z49vlh30gqVYaiHGJ3bO/tw9vvBpfhAhTEZsJtTNP73fZ+q6iBtC/dW9alr0Gy1i8jy5817K5rbpuBC1gsgCKH+8PCn9T+Sv6oWYS18U/OQ==',
        type => 'ssh-dss',
        user => 'dgillman'
    }

    @group { 'cramaker': gid => '503' }
    @user { 'cramaker': 
        ensure     => present,
        uid        => '503',
        gid        => 'cramaker',
        home       => '/home/cramaker',
        managehome => true,
        groups     => ['cramaker', 'wheel',],
    }

    ssh_authorized_key { 'cramaker-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1kc3MAAACBAJyF4oY9AfdqFYnllnvp9+33E54lfppzyXJe000lF7kuuBSokQ4XLrNVA0Q4sgFXgUlSShqP8QkfG8y4B6oOPCQQrTrdPEtEMzxr0t9ER+nkri9rer8B8zK4Ugu9oN1vyV7Z/eiRsAObEqWzws9xMG3mQ+x5Trjuxe/e3+BK5s0TAAAAFQDAsvrlx0J0D7obk7Hkx7BXd+boUwAAAIB2gfPK0iEltPKJO/2xjMVvr/2Vh2yVqUA6klEjBYnntDRe6MbK1pvkbJxJDRVZjJ6WmasSzFcJ9CsdRGubmawoXDjFrdIAAm6ludqL4tLQ7wbeXxr/UGCXHrB/gmSQaX/kW8KDqgdbOYALKfS5GA6P9VtIt2ytCB0k7ObJVQeq8QAAAIBpdzQpUQvE3AdZ8txSuriKsU1xDunwmxC8rQN+N+nvndzzJGrBmUzJ5jzEEDDp/iTsT8hKhLj2yys2m3Cem9dRLDVD/4pDq6lr2p5jB28PC3ymAlWWbq2bPZX+laB6XeZ54avxNTYJ78W2STsA3tkwp7mmymhlfJrMGK6MozWrRA==',
        type => 'ssh-dss',
        user => 'cramaker'
    }

    @group { 'dthomson': gid => '502' }
    @user { 'dthomson': 
        ensure     => present,
        uid        => '502',
        gid        => 'dthomson',
        home       => '/home/dthomson',
        managehome => true,
        groups     => ['dthomson', 'wheel',],
    }

    ssh_authorized_key { 'dthomson-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAtvIEDg+2bLGS6EHspDejSBSRC0MykAz1E7YtsjLiIA9fteSpldg0sCWwRHhOZQ5WNRa36JALWYy8mKXsuQEPEeudPBSYW+qGZP5Xm5fo7iQEp0ANNIdBdoZAzG11Lo9DIMPyo1C/Ylbz6mGKMY98F8wmRYxeCqVMO3HrBJn2qIgHhKLnSj+14Bfu2Tup2nKv/7Ard7bNfVXAeu/N4ksu/qZEB/55dvEhqqdeEGkk+3vM47eCWNoxbLkJgo2Mhu6F2YazA8fG0DZ51f1Afqez9qEM6pqExuzEGDzx6KdT9VFTN25csv8zcBwpOh2WpqzkCosL/ji6l43KK22PITA3Gw==',
        type => 'ssh-rsa',
        user => 'dthomson'
    }

    @group { 'efroese': gid => '504' }
    @user { 'efroese':
        ensure     => present,
        uid        => '504',
        gid        => 'efroese',
        home       => '/home/efroese',
        managehome => true,
        groups     => ['efroese', 'wheel',],
    }

    ssh_authorized_key { 'efroese-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAyj3Ibcpjod26vYzpbNbxkV5lAE9ul2Q24sJJ41BGYl6kizm1FTrU7xkaIAMsQw/hIVKbHrgjRtmBzPYmlP5cX2/oIkYeOswkTxj6FLYcn0xbZAf2Pd5b8CI+bA0cA5lPbP/00dPui8UAZcd92lct8dBOoqaCsAJ1WVyzDTrOmWkIdEg7XL+wFUAHmKHP8lXqKrzNvnT+cKbZnXTPRwtfxi//fyz439ruPiWJMVJnWf9qkiX76c/EUIVMAUTv1SWofMSJT9LXh/I9Z4DIw/y5mLJdbXRPYBwcO/sTjna9KkGUz/7Vr3QL6+LUwYe3ZFKd44bjC8oN36BALF/alxijvQ==',
        type => 'ssh-rsa',
        user => 'efroese'
    }
}
