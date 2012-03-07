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

    file { "/root/scripts/oipp_csv_copy.sh":
        owner => root,
        group => root,
        mode => 0640,
        content => template('oipp/oipp_csv_copy.sh.erb'),
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

class oipp::test {

    class { 'people::oipp-sis::destination': }
}
