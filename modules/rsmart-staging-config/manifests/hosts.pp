class localconfig::hosts {
    # rSmart OAE 1.1 staging cluster 

    host { 'staging-lb0':
        # 50.18.195.239  -> 10.53.9.10      load balancer (apache)
        ensure => present,
        ip => '10.53.9.10',
        host_aliases => 'staging-apache1.rsmart.local',
        comment => 'Apache load balancer'
    }

    host { 'staging-app1':
        ensure => present,
        ip => '10.53.10.16',
        host_aliases => 'staging-app1.rsmart.local',
        comment => 'OAE app server'
    }

    host { 'staging-app2':
        ensure => present,
        ip => '10.53.10.20',
        host_aliases => 'staging-app2.rsmart.local',
        comment => 'OAE app server'
    }

    host { 'staging-cle':
        ensure => present,
        ip => '10.53.10.17',
        host_aliases => 'staging-cle.rsmart.local',
        comment => 'CLE server'
    }

    host { 'staging-dbserv1':
        ensure => present,
        ip => '10.53.10.10',
        host_aliases => 'staging-dbserv1.rsmart.local',
        comment => 'Database master',
    }

    host { 'staging-dbserv2':
        ensure => present,
		ip => '10.53.10.11',
		host_aliases => 'staging-dbserv2.rsmart.local',
        comment => 'Database slave',
    }

    host { 'staging-solr1':
        ensure => present,
        ip => '10.53.10.21',
        host_aliases => 'staging-solr1.rsmart.local',
        comment => 'Solr master',
    }
    host { 'staging-nfs':
        ensure => present,
        ip => '10.53.10.13',
        comment => 'NFS server',
    }
    host { 'staging-preview':
        ensure => present,
		ip => '10.53.10.14',
		host_aliases => 'staging-preview.rsmart.local',
        comment => 'Preview processor',
    }
    host { 'staging-appdyn':
        ensure => present,
        ip => '10.53.10.18',
        host_aliases => 'staging-appdyn.rsmart.local',
        comment => 'AppDynamics Controller/Hyperic',
    }
}
