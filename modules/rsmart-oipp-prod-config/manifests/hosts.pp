class localconfig::hosts {
    # rSmart OIPP OAE 1.1 production cluster 

    host { 'oipp-prod-apache1':
        ensure => present,
        ip => '10.51.9.20',
        host_aliases => 'oipp-prod-apache1.academic.rsmart.local',
        comment => 'Apache load balancer'
    }

    host { 'oipp-prod-app1':
        ensure => present,
        ip => '10.51.11.100',
        host_aliases => 'oipp-prod-app1.academic.rsmart.local',
        comment => 'OAE app server'
    }

    host { 'oipp-prod-app2':
        ensure => present,
        ip => '10.51.11.101',
        host_aliases => 'oipp-prod-app2.academic.rsmart.local',
        comment => 'OAE app server'
    }

	host { 'oipp-prod-preview':
    	ensure => present,
        ip => '10.51.11.200',
        host_aliases => 'oipp-prod-preview.academic.rsmart.local',
        comment => 'OAE Preview processor',
    }

    host { 'oipp-prod-solr1':
        ensure => present,
        ip => '10.51.11.30',
        host_aliases => 'oipp-prod-solr1.academic.rsmart.local',
        comment => 'Solr master',
    }

	host { 'oipp-prod-dbserv1':
        ensure => present,
        ip => '10.51.11.70',
        host_aliases => 'oipp-prod-dbserv1.academic.rsmart.local',
        comment => 'Database master',
    }

    host { 'oipp-prod-nfs':
        ensure => present,
        ip => '10.51.11.90',
        host_aliases => 'oipp-prod-nfs.academic.rsmart.local',
        comment => 'NFS server',
    }

    host { 'oipp-test':
        ensure => present,
        ip => '10.51.9.112',
        alias=> 'oipp-test',
    }
}