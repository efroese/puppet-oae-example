#
# Common configs for central/distributed servers
#
node icinganode inherits basenode {

    class { 'apache::ssl': }
    apache::vhost-ssl { "${::fqdn}:443": }

    # Collect exported host resources
    Host <<| |>>

    class { 'augeas': }
    class { 'mysql::server':
        mysql_password => "battery",
    }

    ###########################################################################
    # Used by ido2db from icinga-idoutils
    $icinga_pw = 'thethingthatshouldnotbe'
    mysql::database { 'icinga':
        ensure  => present,
        require => Class['Mysql::Server'],
    }

    mysql::rights { 'icinga-clients':
        ensure   => present,
        database => 'icinga',
        user     => 'icinga',
        password => $icinga_pw,
        host     => 'localhost',
        require  => Mysql::Database['icinga'],
    }
}

node 'icinga01.rsmart.com' inherits icinganode {

    ###########################################################################
    # This is the db where the exported resources are stored
    mysql::database { 'puppet':
        ensure  => present,
        require => Class['Mysql::Server'],
    }
    
    mysql::rights { 'puppet-clients': 
        ensure   => present,
        database => 'puppet',
        user     => 'puppetclient',
        password => 'damageinc',
        host     => '%',
        require  => Mysql::Database['puppet'],
    }

    mysql::rights { 'puppet-clients-localhost':
        ensure   => present,
        database => 'puppet',
        user     => 'puppetclient',
        password => 'damageinc',
        host     => 'localhost',
        require  => Mysql::Database['puppet'],
    }

    ###########################################################################
    # Icinga central server
    class { 'icinga::server':
        ensure => present,
        db_pass => 'thethingthatshouldnotbe',
        icinga_cfg_template => 'localconfig/icinga-central.cfg.erb',
        active_services => false,
        passive_services => true,
        require => Mysql::Rights['icinga-clients'],
    }

    class { 'icinga::nsca::receiver':
        ensure => present,
    }

    # Common rsmart icinga objects
    class { 'monitoring::commands': }
    class { 'monitoring::contacts': }
    class { 'monitoring::contactgroups': }
    class { 'monitoring::hostgroups': }
    class { 'monitoring::timeperiods': }

    ###########################################################################
    # Icinga Web Interface
    mysql::database { 'icinga_web':
        ensure  => present,
        require => Class['Mysql::Server'],
    }

    mysql::rights { 'icinga_web-clients':
        ensure   => present,
        database => 'icinga_web',
        user     => 'icinga_web',
        password => 'icinga_web',
        host     => 'localhost',
        require  => Mysql::Database['icinga_web'],
    }

    # /icinga-web/
    # Not yet configured
    class { 'icinga::newweb':
        db_pass => 'icinga_web',
    }

    ###########################################################################
    # Munin graphs
    $munin_do_cgi_graphing = true
    class { 'munin::client': }
    class { 'munin::host':
        require => Class['Munin::Client'],
    }

    file { '/etc/nagios':
        ensure => directory,
    }

    # accept connections from localhost and icinga01.rsmart.com
    class { 'nrpe': }
    nrpe::config { 'nrpe.cfg':
        allowed_hosts => "127.0.0.1,icinga01.rsmart.com",
        require => File['/etc/nagios'],
    }
    class { 'icinga::client': }

    # I haven't figured out how to do a clean central/distributed/target
    # class so I'm going to just be simple about monitoring the central server from
    # the first distributed server.
    icinga::host { $::fqdn:
        hostgroups => 'monitoring-servers',
        contact_groups => 'acad_support',
        tags => [
            "icinga_host_icinga01.rsmart.com",
            "icinga_host_icinga02.rsmart.com",
        ],
    }

    icinga::service { "${::fqdn}_ping" :
        service_description => "PING",
        check_command => "check_ping!125.0,20%!500.0,60%",
        dependent_service_description => "",
        icinga_tags => "icinga_active_icinga02.rsmart.com",
    }

    icinga::nsca_service { "${::fqdn}_ping":
        service_description => "PING",
        icinga_tags => "icinga_passive_icinga01.rsmart.com",
    }
}

node 'icinga02.rsmart.com' inherits icinganode {

    $munin_do_cgi_graphing = true
    class { 'munin::host':
        require => Class['Munin::Client'],
    }

    ###########################################################################
    # Icinga distributed server
    class { 'icinga::server':
        ensure => present,
        db_pass => 'thethingthatshouldnotbe',
        icinga_cfg_template => 'localconfig/icinga-distributed.cfg.erb',
        active_services  => true,
        passive_services => false,
        require => Mysql::Rights['icinga-clients'],
    }

    ###########################################################################
    # Send check results to icinga01
    class { 'icinga::nsca::sender':
        ensure => present,
        nsca_receiver => 'icinga01.rsmart.com',
    }

    ###########################################################################
    # Tell the distributed server to monitor itself and pass the resulkts back
    # to the central server
    class { 'monitoring::target':
        local_monitoring_server => 'icinga02.rsmart.com',
        central_monitoring_server => 'icinga01.rsmart.com',
        hostgroups => 'monitoring-servers',
        contact_groups => 'acad_support',
    }
}

node 'monza.rsmart.com' inherits basenode {
    class { 'monitoring::target':
        local_monitoring_server => 'icinga02.rsmart.com',
        central_monitoring_server => 'icinga01.rsmart.com',
        hostgroups => 'cle-servers',
        contact_groups => 'acad_support',
    }
}

node 'gremlin.rsmart.com' inherits basenode {
    class { 'monitoring::target':
        local_monitoring_server => 'icinga02.rsmart.com',
        central_monitoring_server => 'icinga01.rsmart.com',
        hostgroups => 'postgres-servers',
        contact_groups => 'acad_support',
    }
}