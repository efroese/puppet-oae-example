#
# Common hostgroups
#
class monitoring::hostgroups {

    icinga::hostgroup { 'monitoring-servers':
        hostgroup_alias => 'Monitoring Servers',
    }

    icinga::hostgroup { 'cle-servers':
        hostgroup_alias => 'CLE Servers',
    }

    icinga::hostgroup { 'postgres-servers':
        hostgroup_alias => 'PostgreSQL Servers',
    }

    icinga::hostgroup { 'io-servers':
        hostgroup_alias => 'Servers at the IO datacenter',
    }

    icinga::hostgroup { 'ec2-servers':
        hostgroup_alias => 'Servers in Amazon EC2',
    }
}
