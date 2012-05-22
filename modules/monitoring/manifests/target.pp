#
# = Class: monitoring::target
# Common monotoring resources for icinga/munin clients.
#
# == Parameters:
# $local_monitoring_server:: The icinga/munin server this node reports to.
#
# $central_monitoring_server:: A central monitoring server the NSCA checks are sent to.
#
class monitoring::target(
    $local_monitoring_server,
    $central_monitoring_server,
    $hostgroups = "",
    $contact_groups = "") {

    if ! defined(Package['nagios-plugins-all']) {
        package { 'nagios-plugins-all': ensure => installed }
    }

    file { '/etc/nagios':
        ensure => directory,
    }
    
    Host <<| title == $local_monitoring_server |>>
    Host <<| title == $central_monitoring_server |>>

    # install and configure NRPE
    class { 'nrpe': }
    # accept connections from localhost and 192.168.1.160
    nrpe::config { 'nrpe.cfg':
        allowed_hosts => "127.0.0.1,${local_monitoring_server}",
        require => File['/etc/nagios'],
    }

    class { 'icinga::client': }

    # Tell icinga about this host
    icinga::host { $::fqdn:
        tags => [ "icinga_host_${local_monitoring_server}",
            "icinga_host_${central_monitoring_server}"
        ],
        hostgroups => $hostgroups,
        contact_groups => $contact_groups,
    }

    icinga::service { "${fqdn}_ping" :
        service_description => "PING",
        check_command => "check_ping!125.0,20%!500.0,60%",
        dependent_service_description => "",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${fqdn}_ping":
        service_description => "PING",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

    icinga::service { "${fqdn}_ssh" :
        service_description => "SSH",
        check_command => "check_ssh",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${fqdn}_ssh":
        service_description => "SSH",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

    icinga::nrpe_service { "${fqdn}_nrpe_swap" :
        command_name => "check_swap",
        command_line => "${icinga::params::nagiosplugins}/check_swap -w 3% -c 1%",
        service_description => "SWAP",
        notification_options => "w,c,u",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }

    icinga::nsca_service { "${fqdn}_nrpe_swap":
        service_description => "SWAP",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

    icinga::nrpe_service { "${fqdn}_nrpe_disk" :
        command_name => "check_disk",
        command_line => "${icinga::params::nagiosplugins}/check_disk -l -X devfs -X linprocfs -X devpts -X tmpfs -X usbfs -X procfs -X proc -X sysfs -X iso9660 -X debugfs -X binfmt_misc -X udf -X devtmpfs -X securityfs -X fusectl -w 20% -c 10% -W 20% -K10%",
        service_description => "DISK",
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }
    
    icinga::nsca_service { "${fqdn}_nrpe_disk":
        service_description => "DISK",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

    $pc = $processorcount ? {
        "" => 1,
        default => $processorcount,
    }

    icinga::nrpe_service {"${fqdn}_check_load" :
        service_description => "LOAD",
        command_name => "check_load",
        command_line =>
            inline_template("<%= scope.lookupvar('icinga::params::nagiosplugins') %>/check_load -w <%= Integer(pc) * 3 %>,<%= Integer(pc) * 2 %>,<%= Integer(pc) * 2 %> -c <%= Integer(pc) * 5 %>,<%= Integer(pc) * 4 %>,<%= Integer(pc) * 3 %>"),
        notification_options => "w,c,u",
        ensure => $ensure,
        icinga_tags => "icinga_active_${local_monitoring_server}",
    }
    
    icinga::nsca_service { "${fqdn}_nrpe_load":
        service_description => "CPU",
        icinga_tags => "icinga_passive_${central_monitoring_server}",
    }

    class { 'munin::client':
        munin_allow => [ '127.0.0.1', $local_monitoring_server ],
        host => $ipaddress,
    }
}
