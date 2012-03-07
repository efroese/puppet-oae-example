class oipp {
    
}

class oipp::sis {

    Class['rsmart-oipp-prod-config::init'] -> Class ['Oipp::Sis']

    class { 'people::oipp-sis':
    }

    @ssh_authorized_key { "root-rsmart-pub":
        ensure => present,
	key => 'AAAAB3NzaC1yc2EAAAABIwAAAgEAr1DlzFukqnTX7AxDOmej1InLft96X65KdVrU7EPGBKsfA4RYH9b7NYzmgg9lqHNcixoyLS6mgdxt0j7ZX2YzY0CgUeuAo/bNOtn8HNAc0qvFnx4qeR+DFK/9MPBDECy2qOqDJFNvaAWilAewtAXMtpORJRtonzpJwRyDAmW8umnqcvLlORcX4ls3cUc0O8Nxh1YrrCqkeZKfI6Wj//3Ve5R3QPsgX+2GRkvh+7I3XuGE72iYdnVXDPWRIT5Hc0Cf/Effw/Xyr14ujRRr07rGawP6YrMgPzOTf9OPaRCshCcXH79a95qxiaVP5P9Op0ZJjHAtE+E6y5FB2yqeyfCoXMFOzUfnmSXZW81iNg/rGeF1zmkcZIkEOb3RNukg5LWg47UYEFFeqwW+zWNfpOo6aJmABFvS5yg/vJxV5HeyCAcNS+pS+zBVK9oRakMXoleTSr/dPi07JThN3DghxJ5R9e4qbX2oYkE6OLHQpp+F76plz5+Kidt5wJOQHsVO6A3mWwg988ySbqRTAnaIeeSjjTpG1Bu8AkFbcAgvxVhKzm89BbHr9NWtAxo+zWFp/6dLL44QCV0juxY1nQC9RDqTkfMVxjF5TsN8sXBfTMO7irrW9hH9GL/Y+EzhspEUpPqBCBBhEnc+QDhr4NMmZjXign8ef9SXohNvtfOkRLCl4E0=',
        type => 'ssh-rsa',
        user => root,
    }

    realize (Ssh_authorized_key['root-rsmart-pub'])

    file {"/root/.ssh/id_rsa":
	owner => root,
	group => root,
	mode => 500,
	source => 'puppet:///modules/oipp-sis/id_rsa.rsmart',
    }

    file { "/root/scripts/oipp_csv_copy.sh":
        owner => root,
        group => root,
        mode => 0640,
        content => template('localconfig/oipp_csv_copy.sh.erb'),
    }

    cron { 'transport_sis':
        command => "/root/scripts/oipp_csv_copy.sh",
        user => root,
        ensure => present,
        hour => '0',
        minute => '2',
        require => [
            File["/root/scripts/oipp_csv_copy.sh"],
        ],
    }

}
