class oipp {
    
}

class oipp::sis {

    class { 'people::oipp-sis::internal': }
    class { 'people::oipp-sis::external': }

    host { 'oipp-test':
	    ensure => present,
	    ip => '10.51.9.112',
	    alias=> 'oipp-test',
    }

    file { "/root/scripts":
        owner => root,
        group => root,
        mode => 0770,
        ensure => directory,
    }

    file { "/root/scripts/oipp_csv_copy.sh":
        owner => root,
        group => root,
        mode => 0750,
        content => template('oipp/oipp_csv_copy.sh.erb'),
        require => [ File["/root/scripts"], ],
    }

    cron { 'transport_sis':
        command => "/root/scripts/oipp_csv_copy.sh",
        user => root,
        ensure => present,
        minute => '2',
        require => [
            File["/root/scripts/oipp_csv_copy.sh"],
        ],
    }

}

class oipp::test (
    $cle_csv,
    $oae_csv,
    $sis_log = "/var/log/sakaioae/sis.log",
    $sis_error_archive = "archive/",
    $use_scp = false,
    $csv_schools,) {

    class { 'people::oipp-sis::external': }
    class { 'people::oipp-sis::destination': }

    file { "/root/scripts":
        owner => root,
        group => root,
        mode => 0770,
        ensure => directory,
    }

    file { "/root/scripts/oipp_csv_copy.sh":
        owner => root,
        group => root,
        mode => 0750,
        content => template('oipp/oipp_csv_copy_test.sh.erb'),
        require => [ File["/root/scripts"], ],
    }

    cron { 'transport_sis':
        command => "/root/scripts/oipp_csv_copy.sh",
        user => root,
        ensure => present,
        minute => '2',
        require => [
            File["/root/scripts/oipp_csv_copy.sh"],
        ],
    }

    # add root's key from oipp-apache1 to OIPP users on test to emulate file xfer
    ssh_authorized_key { 'ucb_sis-test-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => 'ucb_sis',
        require => User['ucb_sis'],
    }
    ssh_authorized_key { 'ucd_sis-test-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => 'ucd_sis',
        require => User['ucd_sis'],
    }
    ssh_authorized_key { 'ucm_sis-test-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => 'ucm_sis',
        require => User['ucm_sis'],
    }
    ssh_authorized_key { 'ucla_sis-test-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => 'ucla_sis',
        require => User['ucla_sis'],
    }
    ssh_authorized_key { 'ucsc_sis-test-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => 'ucsc_sis',
        require => User['ucsc_sis'],
    }
}
