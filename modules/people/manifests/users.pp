#
# User resources for sakai
#
class people::users {
    Class['Localconfig'] -> Class['People::Users']
    Class['People::Groups'] -> Class['People::Users']

    # rsmart
    @user { $localconfig::user:
        ensure => present,
		uid => $localconfig::uid,
		gid => $localconfig::gid,
		home => "/home/${localconfig::user}",
		managehome => true,
	}
		
	@ssh_authorized_key { "${localconfig::user}-pub":
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAxcIV32jkMIEEfTVWHsDxNuUHHwaXMWviRAmU7dShSVw3BeMVDsh1syd54p1TRTKICD/9hlVtFDS0MQ7WEyNWUsC/XCO5vSkct5NCsivD1NO7g+Do3V6p+Hzj3Ja18GOjKBU+wi3QVIiyMFhTCqdM1VR9AT/1lPFBxPG+3RWRiwCn7w4YjfumGrDBLJsQh0cCs46kXV3F78VfLOR1QwECiyICBtP77Qzusq2wlVOBolSGrvytXLYDJs5WgdlpU1lSJsr4vHD2WjTicyP8dMbwZAXRUsB4YIT5k7blsEj1iezdZ5EntEvOgDFyWchIF8kzw+LmVw90aLTZco/kyeJYXw== rsmartian@deploy',
        type => 'ssh-rsa',
        user => $localconfig::user,
        require => User[$localconfig::user],
    }

	@user { 'rsmartian':
        ensure     => present,
        uid        => '800',
        gid        => 'rsmartian',
        home       => '/home/rsmartian',
        managehome => true,
        groups     => ['rsmartian', 'wheel',],
    }

    @user { 'hyperic': 
        ensure     => present,
        uid        => '701',
        gid        => 'hyperic',
        home       => '/home/hyperic',
        managehome => true,
    }

    @user { 'lspeelmon': 
        ensure     => present,
        uid        => '501',
        gid        => 'lspeelmon',
        home       => '/home/lspeelmon',
        managehome => true,
        groups     => ['lspeelmon', 'wheel',],
    }

    @ssh_authorized_key { 'lspeelmon-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAp9p82llL03l1eOXpSaYBwNxu7CeOv2QevTquJpIMoaRKHFDmbaAggwUfAIRuIDPBh4b79Gvyr+1foeszgDaxHdP8rbvZFTexsvA9ImBg6bN+qRlCr5Pr+gOrYpTybAIBEuAkINMD3zOUP+SdSx/UDFcfRkpf9gS1j1qDrvzvBHLHsjcKvUHc1NqkYnO6c1xYFA+sZsQaOwRM0InuL0gBAiG68eBy4YW/rbEiSzVO6YBC95i9joxMz3KTJSySmawO922py06CUn5Xsrvka3qkvhFJ9KSs2o9cA82PCFESisrvQOSuAllE7SJ7ocLMmbrJgnhuXi81zVQ6+Fb028DOVw==',
        type => 'ssh-dss',
        user => 'lspeelmon',
        require => User['lspeelmon'],
    }

    @user { 'dgillman': 
        ensure     => present,
        uid        => '506',
        gid        => 'dgillman',
        home       => '/home/dgillman',
        managehome => true,
        groups     => ['dgillman', 'wheel',],
    }

    @ssh_authorized_key { 'dgillman-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAoxOaLODYDqQNAURGI2j2bMhFrYg/I1h7tydOMyVYh5nsu0qK/kc8RCknRNJeEABDUKfJaSQX7OwZKqPS+/R3aSBY/WxnyBX3pAJW1Lq4+1U7+y2S8Y13Fw4JXwDnHIIbNLJUHyqF+MIyl55A5inMm39Z2EEaXIr2KbpwLTsx8nmRMNvlmFov4WTui1HUAb7IM/gF9UInTGflQ5YMNZSYvMULhUldbKFpW/i1OGcwZb8z49vlh30gqVYaiHGJ3bO/tw9vvBpfhAhTEZsJtTNP73fZ+q6iBtC/dW9alr0Gy1i8jy5817K5rbpuBC1gsgCKH+8PCn9T+Sv6oWYS18U/OQ==',
        type => 'ssh-rsa',
        user => 'dgillman',
        require => User['dgillman'],
    }

    @user { 'cramaker': 
        ensure     => present,
        uid        => '503',
        gid        => 'cramaker',
        home       => '/home/cramaker',
        managehome => true,
        groups     => ['cramaker', 'wheel',],
    }

    @ssh_authorized_key { 'cramaker-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1kc3MAAACBAJyF4oY9AfdqFYnllnvp9+33E54lfppzyXJe000lF7kuuBSokQ4XLrNVA0Q4sgFXgUlSShqP8QkfG8y4B6oOPCQQrTrdPEtEMzxr0t9ER+nkri9rer8B8zK4Ugu9oN1vyV7Z/eiRsAObEqWzws9xMG3mQ+x5Trjuxe/e3+BK5s0TAAAAFQDAsvrlx0J0D7obk7Hkx7BXd+boUwAAAIB2gfPK0iEltPKJO/2xjMVvr/2Vh2yVqUA6klEjBYnntDRe6MbK1pvkbJxJDRVZjJ6WmasSzFcJ9CsdRGubmawoXDjFrdIAAm6ludqL4tLQ7wbeXxr/UGCXHrB/gmSQaX/kW8KDqgdbOYALKfS5GA6P9VtIt2ytCB0k7ObJVQeq8QAAAIBpdzQpUQvE3AdZ8txSuriKsU1xDunwmxC8rQN+N+nvndzzJGrBmUzJ5jzEEDDp/iTsT8hKhLj2yys2m3Cem9dRLDVD/4pDq6lr2p5jB28PC3ymAlWWbq2bPZX+laB6XeZ54avxNTYJ78W2STsA3tkwp7mmymhlfJrMGK6MozWrRA==',
        type => 'ssh-dss',
        user => 'cramaker',
        require => User['cramaker'],
    }

    @user { 'dthomson': 
        ensure     => present,
        uid        => '502',
        gid        => 'dthomson',
        home       => '/home/dthomson',
        managehome => true,
        groups     => ['dthomson', 'wheel',],
    }

    @ssh_authorized_key { 'dthomson-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAtvIEDg+2bLGS6EHspDejSBSRC0MykAz1E7YtsjLiIA9fteSpldg0sCWwRHhOZQ5WNRa36JALWYy8mKXsuQEPEeudPBSYW+qGZP5Xm5fo7iQEp0ANNIdBdoZAzG11Lo9DIMPyo1C/Ylbz6mGKMY98F8wmRYxeCqVMO3HrBJn2qIgHhKLnSj+14Bfu2Tup2nKv/7Ard7bNfVXAeu/N4ksu/qZEB/55dvEhqqdeEGkk+3vM47eCWNoxbLkJgo2Mhu6F2YazA8fG0DZ51f1Afqez9qEM6pqExuzEGDzx6KdT9VFTN25csv8zcBwpOh2WpqzkCosL/ji6l43KK22PITA3Gw==',
        type => 'ssh-rsa',
        user => 'dthomson',
        require => User['dthomson'],
    }

    @user { 'efroese':
        ensure     => present,
        uid        => '504',
        gid        => 'efroese',
        home       => '/home/efroese',
        managehome => true,
        groups     => ['efroese', 'wheel',],
    }

    @ssh_authorized_key { 'efroese-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAyj3Ibcpjod26vYzpbNbxkV5lAE9ul2Q24sJJ41BGYl6kizm1FTrU7xkaIAMsQw/hIVKbHrgjRtmBzPYmlP5cX2/oIkYeOswkTxj6FLYcn0xbZAf2Pd5b8CI+bA0cA5lPbP/00dPui8UAZcd92lct8dBOoqaCsAJ1WVyzDTrOmWkIdEg7XL+wFUAHmKHP8lXqKrzNvnT+cKbZnXTPRwtfxi//fyz439ruPiWJMVJnWf9qkiX76c/EUIVMAUTv1SWofMSJT9LXh/I9Z4DIw/y5mLJdbXRPYBwcO/sTjna9KkGUz/7Vr3QL6+LUwYe3ZFKd44bjC8oN36BALF/alxijvQ==',
        type => 'ssh-rsa',
        user => 'efroese',
        require => User['efroese'],
    }

    @user { 'kcampos':
        ensure     => present,
        uid        => '505',
        gid        => 'kcampos',
        home       => '/home/kcampos',
        managehome => true,
        groups     => ['kcampos', 'wheel',],
    }

    @ssh_authorized_key { 'kcampos-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAweJmgQAL6kNjPdesK8PYgCIbiV4QLx9afk35yt741u4e9lE/fbQ4vBu94qAAv63brUp9s4hGBmtTf1xhxSaeZPd9/pQHlaH00URA0ZORXD8WloSuVst4SvK1Ll2L6vz+ZInTmefWoo571HL9omFXxnwuvSLAjYBDBPaeAaeNS9uNSLcDrnkb1sRRepVxrApJt7j4+dZ3bbNaGH9gOxh+EtBuo6ZoBtxRkpvr7NKCxcM3K4PpmD5mRDCqF6Ojc52PlpEXIMDnt+xUrQ6ACfNism2julmSBTO7rH7xSn6FAREeYjoBF6+K/AL1lWx9SoOBPCuxNbd7Vivb2890FXoZYQ==',
        type => 'ssh-rsa',
        user => 'kcampos',
        require => User['kcampos'],
    }

    @user { 'mdesimone':
        ensure     => present,
        uid        => '507',
        gid        => 'mdesimone',
        home       => '/home/mdesimone',
        managehome => true,
        groups     => ['mdesimone', 'wheel',],
    }

    @ssh_authorized_key { 'mdesimone-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAyaOsc4zC2b4w6CQNoHYFAOiDt1gzUFrYNUoOO/TvCVgiEI4d9vmMxPxNxSdxq70WLMoB13f0Wnd3H4u4DwY0cs5jPEjt/XuWXHf/z+HAw/+5z916mnxLi7zp/ylHhDryajiKxNIVqn6dZlNySyj5kt97zaA7/9+/r5bKlXA/aK2pFhUnVV2g3Ij0ocbLp31m38LI+QRSUwnIVrcdVxIVykTEGWRTWUe/x46VJOJ1Ur/POTfdEbNMnG1cdjv9sHk+26EEzkJo0RqWp9Ln4HmaMp2vQy/U7X06+OfMtPubnfPtR+l9KHN4hzrGtU6SKgfE0X2OhxwT7LCFhZXN465dbQ==',
        type => 'ssh-rsa',
        user => 'mdesimone',
        require => User['mdesimone'],
    }

    @user { 'mflitsch':
        ensure     => present,
        uid        => '508',
        gid        => 'mflitsch',
        home       => '/home/mflitsch',
        managehome => true,
        groups     => ['mflitsch', 'wheel',],
    }

    @ssh_authorized_key { 'mflitsch-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA62NShmgqF5Z78YmMKJV4j9UP8VqC/nLyKmmJ1L6SuivGszXhNw6xsrIVzHkvfBGQq4Qcxh8WhvWJlTeamufLN3h7OXs/ieWs43YpC6K0h3EN54DnfVMnPcNjZZErT/NZUK3w17bb2MjPEZjjMtz49Txv5IVZxRBe2TUSJcnrTEURBPT5CEQUCciDpzWsGeTWh/SCKTnMWjOpr7GgKxnuIDrQ1dnuvVbwVu5cLqX3O+rM9YADD3t9yCwf6v4bzzk1MugC5SzptjO6DDoJrmZhpITN5T/sRmP1EA5TJXY1R0fWeqKf9v8yy9e3M/9qmdYlvZT1qlo4WuuyMSfZwvLjRQ==',
        type => 'ssh-rsa',
        user => 'mflitsch',
        require => User['mflitsch'],
    }

    @user { 'karagon':
        ensure     => present,
        uid        => '509',
        gid        => 'karagon',
        home       => '/home/karagon',
        managehome => true,
        groups     => ['karagon', 'wheel',],
    }

    @ssh_authorized_key { 'karagon-laptop-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAum3+O4EXUMyusGDiIDre1DIx/+T1DvNZM0emF4CM+0y/91jKt129hCOSoAmAzZx1XeXYHjcDBkFsgvRNxqyUH4veS5MFNi7xid8yJmMFasvxDrI+2NZXAFFIGl2eKq6jWKUssaYLBeJft8g+UiEPAgFpRk8GZv1k+0w62Arzk38JKFctEvs2eXfBXXYJx9TrzBwwmDbuCdEN0pfoASU6Gc4G5el9iod9aECpoI5GuyMTi2C8swqT6DASEzTILVqHyo7uPVBCJdt0jvGh40wc1QIjjgNCTwQWkqZHtQG14jNdiQdbFmS9UNKkELHtKDOfhYsWdFeSIlg4LXAKBcu5FQ==',
        type => 'ssh-rsa',
        user => 'karagon',
        require => User['karagon'],
    }

    @ssh_authorized_key { 'karagon-mbp-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1kc3MAAACBAI1hojKvAxCLNvfqVF8ijw9QdbLpeXuFAWqBRc/n+rLj53a3Wk/Vocs2eQ9atNHsi0R5mQ70v/I1fWpxWescQmZtvtJ2vr7PnPaJzLtWeNR/TdsclTnuQ6BCPj95FvFaEQp4cNWUerAR4H/ucw3WR/KxPc6WEjMjgyrKU3PNJkRLAAAAFQC18E+EHmzX8kvO5PAetfpemcwCRQAAAIBlC5oWcG6dCvizK4j3axPYrl3mvUSG4hXutgr8uBZjEyesLLsZ6wV7HjhNSv6Ag+sIU1mBs67q5LrkjeVOL3NSLhjRubdvrYvU+Haw5twRwDpt5tr7NzIFpAKNLZ7R7sYSHjyzMp8LYX6bBekbfagfMVCfGfn0WGIAbBN2s33xPAAAAIBL1fFDQ05YNJjeuhdxU2KYVGBaeQDEBPPEYe9ZVM7kwk4lOUFboMRXbQp3CFTA2gx/pKDrHWazo71qK7oAWc7tx8CzNin9WWvgqO1dF34feYAsUBm/yRiFEWiT6p1lHy096MAPgIR+jmQdf6E3m1xBDLvgqV9k6oA25TLcQYECTQ==',
        type => 'ssh-dss',
        user => 'karagon',
        require => User['karagon'],
    }

    @user { 'ppilli':
        ensure     => present,
        uid        => '510',
        gid        => 'ppilli',
        home       => '/home/ppilli',
        managehome => true,
        groups     => ['ppilli', 'wheel',],
    }

    @ssh_authorized_key { 'ppilli-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABJQAAAIEAnKpU9vs3tpZetpHWjXbPafiG1UOEh2MiNU0BU2ih3R15Wwr8hsbFEGTQH0AvdtCcnZWqyXBpgW9ze/hraNj5+9JVJS9oTSch2Qw5etTXb0qduNvFEM7Pu90rEBFMJrtsD+d/1utIYjFX+q6V5kA9rdFsOoGEvpwH6FDh3zs4x5U=',
        type => 'ssh-rsa',
        user => 'ppilli',
        require => User['ppilli'],
    }

    @user { 'jenkins':
        ensure     => present,
        uid        => '900',
        gid        => 'devops',
        home       => '/home/jenkins',
        managehome => true,
        groups     => ['devops', 'wheel',],
    }

    @ssh_authorized_key { 'jenkins-home-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA75hmsZg08LrfTKIklSOtPEGpk8vuHy5C68+xPd/Wzp08X+serGQNucuFeeVfx8ytM5txPIjyElJGHxn2U2XgMEzoCEY0da/UwvVzfQJK2ON11yn68DPMVsoFqjK+U8+nHHmsJQ6ApFOO/8GldlcieoIV8yQ46msNxMGImk/8GogOSGb+7JNtH1udUl5dUHD9bCMEObdzVwJzgpVu13x+4bPqDDsp+NIX6Tm4ZJB4qaCG3nvWxOL+apxHOwhuRXAqw5EqVyi2BZj5VjPckQ0wJkqm277tlJuUdhjmFZ1wcaqtRLHw8uNqBrBEV81S4F+8cabPcOyVgX8zeP3oE23LSQ==',
        type => 'ssh-rsa',
        user => 'jenkins',
        require => User['jenkins'],
    }

    @user { 'jbush': 
        ensure     => present,
        uid        => '511',
        gid        => 'jbush',
        home       => '/home/jbush',
        managehome => true,
        groups     => ['jbush', 'wheel',],
    }

    @ssh_authorized_key { 'jbush-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1kc3MAAACBANvNMJtQDJJxPEQ8ljYELP7UupXyGragkOfvstm9vfSO7dLD0bGPdRl6MH4SvpmjwmVtbXQcrEAdKtMgdZSeQl6a17rCMUQFzt9QHRWXsIoTwppYse6E4J/wfGKaHtjKeb3t5apwrGV3sfwZoFiwMtcedm9E3LCi/6DhJSwwmIXfAAAAFQD1C0/0U/qbrvLPoainAbdK9T7UwwAAAIBCLuiKDXlL4x1mC1BnyI/oQASUuGR/+tmbAyzbmer+Er83ORa7wzhs2RhXHNcsHQvnfN9eVGZgGLhqddI9r+a0xXLJufb1z3ZIySPlsRE77qZr2is9BA0sMyxbIWIRX/gL5hdQNxRf4qzLc1rfWKkLDQhs2LUiphtY7yY9hj/FMQAAAIEAsVakTqKU7pC98TZvGTVmjc3FoRvjgnDxWI9pF0SSX+fSvE9ZcPsHj4SUBbD6YpNfZsjN1XGobaFYQdRn3izdm6HpsjomKUEb3QITRZ8nayy1kplcAR+IpNjI42GMQzcc3KnonGXopwMg5m7zUK4+mdPgW43zF0H9P3kW1v3bhQI=',
        type => 'ssh-dss',
        user => 'jbush',
        require => User['jbush'],
    }

}
