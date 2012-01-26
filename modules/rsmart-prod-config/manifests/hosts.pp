class localconfig::hosts {
    # rSmart OAE 1.1 production cluster 

    host { 'prod-apache1':
        # 50.18.192.53  -> 10.52.9.20'      load balancer (apache)
        ensure => present,
        ip => '10.52.9.20',
        host_aliases => 'prod-apache1.academic.rsmart.local',
        comment => 'Apache load balancer'
    }

    host { 'prod-app1':
        ensure => present,
        ip => '10.52.11.100',
        host_aliases => 'prod-app1.academic.rsmart.local',
        comment => 'OAE app server'
    }

    host { 'prod-app2':
        ensure => present,
        ip => '10.52.11.101',
        host_aliases => 'prod-app2.academic.rsmart.local',
        comment => 'OAE app server'
    }

	host { 'prod-preview':
    	ensure => present,
        ip => '10.52.9.200',
        host_aliases => 'prod-preview.academic.rsmart.local',
        comment => 'OAE Preview processor',
    }

    host { 'prod-solr1':
        ensure => present,
        ip => '10.52.11.30',
        host_aliases => 'prod-solr1.academic.rsmart.local',
        comment => 'Solr master',
    }

	host { 'prod-dbserv1':
        ensure => present,
        ip => '10.52.11.70',
        host_aliases => 'prod-dbserv1.academic.rsmart.local',
        comment => 'Database master',
    }

    host { 'prod-nfs':
        ensure => present,
        ip => '10.52.11.90',
        host_aliases => 'prod-nfs.academic.rsmart.local',
        comment => 'NFS server',
    }
}