#
# User and group resources for OIPP SIS integration
#

class people::oipp-sis::destination {

    #add the pub key to the oae user's authorized_keys on destination machines

    ssh_authorized_key { "root-rsmart-pub":
        ensure => present,
	    key => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => $oae::params::user,
    }
}

class people::oipp-sis::internal {

    #add the priv key to the root user on source machine

    file {"/root/.ssh/id_rsa":
	    owner => root,
	    group => root,
	    mode => 500,
	    source => 'puppet:///modules/oipp/id_rsa.rsmart',
    }

}

class people::oipp-sis::external {

    class { 'rssh': }

    ###########################################################################
    # UCD

    group { 'ucd_sis' : gid => '801' }
    user { 'ucd_sis':
        ensure     => present,
        uid        => '801',
        gid        => 'ucd_sis',
        home       => '/home/ucd_sis',
        managehome => true,
        groups     => ['ucd_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }

    #########################
    # ACAD-1015
    # These are keys for Adam Hochman & Kirk Alexander who are the lead functional & technical people on the client side. 
    ssh_authorized_key { 'ucd_sis-pub-to-ucd':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user  => 'ucd_sis',
        require => User['ucd_sis'],
    }

    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu1':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucd_sis',
        require => User['ucd_sis'],
    }
    ssh_authorized_key { 'ucb-sis1':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucd_sis',
        require => User['ucd_sis'],
    }

    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu-pub-ucd':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user  => 'ucd_sis',
        require => User['ucd_sis'],
    }

    ###########################################################################
    # UCB

    group { 'ucb_sis' : gid => '802' }
    user { 'ucb_sis':
        ensure     => present,
        uid        => '802',
        gid        => 'ucb_sis',
        home       => '/home/ucb_sis',
        managehome => true,
        groups     => ['ucb_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'ucb_sis-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucb_sis',
        require => User['ucb_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucb_sis',
        require => User['ucb_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub2':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'ucb_sis',
        require => User['ucb_sis'],
    }

    #########################
    # ACAD-1015
    # These are keys for Adam Hochman & Kirk Alexander who are the lead functional & technical people on the client side. 
    ssh_authorized_key { 'ucd_sis-pub-to-ucb':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user  => 'ucb_sis',
        require => User['ucb_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu-pub-ucb':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user  => 'ucb_sis',
        require => User['ucb_sis'],
    }

    ###########################################################################
    # UCM
    group { 'ucm_sis' : gid => '803' }
    user { 'ucm_sis':
        ensure     => present,
        uid        => '803',
        gid        => 'ucm_sis',
        home       => '/home/ucm_sis',
        managehome => true,
        groups     => ['ucm_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'ucm_sis-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAtaSgc1yR3TWkJYGMZ9GCeraNbhMIw8dFnS2rKjQ4FOr9dOm7XgNGIQytRt+Mel+JqJSp60OZZM08bK5HHw001At3dNgR7N5M+hN+bhPr7pXgXZfEikMpYqHoZk08d1AiTmATpEPPooiCPeFvWFsTrtPP6IORnJ5hVLOHyAjZ23F1BYOco6zGnj4pd25aMYVnJ3kC+sFrvXk5gK0FzrgQlMdPusqRNulsOUWU1gEa7iO9AxXEXc2xPEzpFHwSlfPNwVvH57y7qhQ8XQ7Gb7GckdjESYABPn2sOroUzwaaeAElnkICYpvDyvUhQ6bhXbmiGWnU+Wd6cjNaKtRVELf+Ww==',
        type => 'ssh-rsa',
        user => 'ucm_sis',
        require => User['ucm_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu3':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucm_sis',
        require => User['ucm_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub3':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'ucm_sis',
        require => User['ucm_sis'],
    }
    ssh_authorized_key { 'ucb_sis-pub3':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucm_sis',
        require => User['ucm_sis'],
    }

    ###########################################################################
    # UCLA
    group { 'ucla_sis': gid => '804' }
    user { 'ucla_sis':
        ensure     => present,
        uid        => '804',
        gid        => 'ucla_sis',
        home       => '/home/ucla_sis',
        managehome => true,
        groups     => ['ucla_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'ucla_sis-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABJQAAAQBpmGDSwo88AS1cfftJpROeayvF1zYyvyjoVt1ApcHid3W/Yu+s1FVV0qQgZ05VKiXN/cUz1SLaZxcPUxorWIUrb9wHBNVCfEsbYrUgcie9gWVyQ7qAX9+zYFcWh1CxVC9Djg3QMhxD0YvrDFyMiFLv1iJ3Gw7WR2fqofvBaMRnA3r9d76CN0DsuT2Ghsv1pu1Z4mj4ny6NEuKYGkAVEevwoI75l6XMYAoh51YfQHJBzQG4zHJEGrX32CjsrZmHaa4jyYuS/hD4Z7hl7j2PqqRMDTnYIEM8f22a9rG0rqCM3fSwcyl1kRlF9m5YPHN/vVArvq+E1YCRGm4RawaAhIA3',
        type => 'ssh-rsa',
        user => 'ucla_sis',
        require => User['ucla_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu4':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucla_sis',
        require => User['ucla_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub4':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'ucla_sis',
        require => User['ucla_sis'],
    }
    ssh_authorized_key { 'ucb_sis-pub4':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucla_sis',
        require => User['ucla_sis'],
    }

    group { 'ucsc_sis' : gid => '805' }
    user { 'ucsc_sis':
        ensure     => present,
        uid        => '805',
        gid        => 'ucsc_sis',
        home       => '/home/ucsc_sis',
        managehome => true,
        groups     => ['ucsc_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'ucsc_sis-pub':
        ensure => present,
        # TODO supply a vaid key
        key  => 'TODO',
        type => 'ssh-dss',
        user => 'ucsc_sis',
        require => User['ucsc_sis'],
    }

    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu5':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucsc_sis',
        require => User['ucsc_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub5':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'ucsc_sis',
        require => User['ucsc_sis'],
    }
    ssh_authorized_key { 'ucb_sis-pub5':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucsc_sis',
        require => User['ucsc_sis'],
    }

    group { 'uci_sis' : gid => '806' }
    user { 'uci_sis':
        ensure     => present,
        uid        => '806',
        gid        => 'uci_sis',
        home       => '/home/uci_sis',
        managehome => true,
        groups     => ['uci_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'uci_sis-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABJQAAAIBKFElQsm7hCTS60q66Yac0TO3pCQeccpky0ZiYkpJhuaENJGT3Hvq9rVcHAcI+67/4AT2tVoN78ozUFVbENtuAZEtkS+jZzUThNz3mF/hRWTMZkSFphZeWsP44DuGbKLJRD+D5i35qOPU0wUg+kYn0nZPhmKRzRuSQlhBA/JpY0Q==',
        type => 'ssh-rsa',
        user => 'uci_sis',
        require => User['uci_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu6':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'uci_sis',
        require => User['uci_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub6':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'uci_sis',
        require => User['uci_sis'],
    }
    ssh_authorized_key { 'ucb_sis-pub6':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'uci_sis',
        require => User['uci_sis'],
    }

    group { 'ucr_sis' : gid => '807' }
    user { 'ucr_sis':
        ensure     => present,
        uid        => '807',
        gid        => 'ucr_sis',
        home       => '/home/ucr_sis',
        managehome => true,
        groups     => ['ucr_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'ucr_sis-pub':
        ensure => present,
        # TODO supply a vaid key
        key  => 'TODO',
        type => 'ssh-dss',
        user => 'ucr_sis',
        require => User['ucr_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu7':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucr_sis',
        require => User['ucr_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub7':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'ucr_sis',
        require => User['ucr_sis'],
    }
    ssh_authorized_key { 'ucb_sis-pub7':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucr_sis',
        require => User['ucr_sis'],
    }

    group { 'ucoe_sis' : gid => '808' }
    user { 'ucoe_sis':
        ensure     => present,
        uid        => '808',
        gid        => 'ucoe_sis',
        home       => '/home/ucoe_sis',
        managehome => true,
        groups     => ['ucoe_sis','rsshusers',],
        shell      => '/usr/bin/rssh'
    }
    ssh_authorized_key { 'ucoe_sis-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABJQAAAIBKFElQsm7hCTS60q66Yac0TO3pCQeccpky0ZiYkpJhuaENJGT3Hvq9rVcHAcI+67/4AT2tVoN78ozUFVbENtuAZEtkS+jZzUThNz3mF/hRWTMZkSFphZeWsP44DuGbKLJRD+D5i35qOPU0wUg+kYn0nZPhmKRzRuSQlhBA/JpY0Q==',
        type => 'ssh-rsa',
        user => 'ucoe_sis',
        require => User['ucoe_sis'],
    }
    ssh_authorized_key { 'adam@dhcp-169-229-212-58.lips.berkeley.edu8':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAvUF2WeggJNwsiC2js7MSXxo73ClbGZr0abYsKgHdDZ0xEo9e3Slma/hO8InAMVaYg4sqbm8BUYdEf/2GMLURwvcShq2Hyg+C+o6pKNtoOBFosDQ/bXKf/n5yonR4+gUedGtp9iKzwUED1QtkkDLjqsR8SI56TZgv5olZAE6WYX3CNDCyXGfZdjf/vSdmz7BQTBTgfze0aofpCJaSSyLmipRco6/zUatY/L+jYz2AXZEWN5er55P3JdD8jUUeBtGFugqb48NMClfvfu0oGKsUMhQCyLlPfRjartfWJtId8kZQ1IyHZQ6F7nlt4FycaiY3cFRnElBgbNxq81Xxwali3iMxTN4PMSfDXML497Vn1Ts8QVhVXgasIEchyPgEmn2zjUl87gX9ZOo2Fj1Dxr/GvWePV/rRV8uZT446QLcDx4WspsCTdIq+XxB+2yqMQKRGzXVcGSsDOpx+Ki+j2eCpeBzAqQpK7qDEUK0fkJTBSsi3qd1tPm0Y3dE6iFUyEcRoI3LZ+8BUrzutIpKJWW58cOy1jnToB3h3ZcJ7Q73iCbKO3BJgX5i2/6valRvFi1Ulof2qkXbFXnWQt/VgZ+3lhqrynkEWsanumavXsyDeVgcY0uYVa09QLRfJbK5IdkJYwmyKJtoI3FXUUH/bz1zeN4+YEeAVjBic0hFqAlTx/oE=',
        type => 'ssh-rsa',
        user => 'ucoe_sis',
        require => User['ucoe_sis'],
    }
    ssh_authorized_key { 'ucd_sis-pub8':
        ensure => present,
        key  => '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',
        type => 'ssh-dss',
        user => 'ucoe_sis',
        require => User['ucoe_sis'],
    }
    ssh_authorized_key { 'ucb_sis-pub8':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA2csHLkNxmwiljOm8cHxOedcp9mL9WFG5GDjhgdlFopN6kGsBMCRLtNKe8V3eXo8iAf/+y95e5YiTX+dy53Uh2EYcQr3ISaZH9NaOQs92cCvsibpWnwPdwMG73uUMjmmLa/zq0QgIbJMY2N1sJ5yyKoPmtbSp9gXDGuffaYWuWT+vRDyp2eWLWJKmDeyW4arGrkSNBwo+5F9z46sAMHz0P+VDZ7VubkPLCKDD88i4mk7KE+e4GoMmfmV4qZFn98mfmSEucl9nTYoO8duWHPdMXVDNW48Aia2JaNwOxjFYwKVQuT6ZTSHfCni4y0MNK8xRkirh2WDhGbPs2PeDloZe3w==',
        type => 'ssh-rsa',
        user => 'ucoe_sis',
        require => User['ucoe_sis'],
    }

}
