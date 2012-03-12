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
        mode => 0750,
        content => template('oipp/oipp_csv_copy.sh.erb'),
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

class oipp::test {

    class { 'people::oipp-sis::external': }
    class { 'people::oipp-sis::destination': }

    file { "/root/scripts/oipp_csv_copy_test.sh":
        owner => root,
        group => root,
        mode => 0750,
        content => template('oipp/oipp_csv_copy_test.sh.erb'),
    }

    cron { 'transport_sis':
        command => "/root/scripts/oipp_csv_copy_test.sh",
        user => root,
        ensure => present,
        minute => '2',
        require => [
            File["/root/scripts/oipp_csv_copy_test.sh"],
        ],
    }
}
