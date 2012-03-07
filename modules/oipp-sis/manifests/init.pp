class oipp {
    
}

class oipp::sis {

    Class['rsmart-oipp-prod-config::init'] -> Class ['Oipp::Sis']

    class { 'people::oipp-sis':
    }

    @ssh_authorized_key { "root-rsmart-pub":
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAvtlsHmqHw1PEP4GGc8wsnCSwhTlYe3dnmawsqG35WNxY4mSBu9YrQkBANJllV4JM5zmLLI45WhztsRX8aGzR7Mg+3yIMtM1l+8GhtD9qRZhJT38RBibva0KyvYMqDICqTPIE42KecBeF5LVloXlu8syhknwDg5+BlcALGb0QcyXgYPnvG3uqzzSBL1Gtnzx1aSsJk52Aclx5RbEdGRalakiz2AS0PaD18ZV2V9q5AEdlOdlbmHM9BsMfkXv/ECwMJWAZUJQVDyPZUsw1xv0zjY67buk0bsjCwo6SG353kbZyF3V+4e7RmCWvoCZKqlRM1m1mmPTTzejyryt85wYH7Q==',
        type => 'ssh-rsa',
        user => root,
    }

    realize (Ssh_authorized_key['root-rsmart-pub'])

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
