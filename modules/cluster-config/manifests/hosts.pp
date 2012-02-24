class localconfig::hosts {
    
    ##########################################
    # Web Tier
    host { 'oae':
        ip => '192.168.1.40',
        host_aliases => 'oae.localdomain',
        comment => 'HA Apache virtual IP',
        ensure => present
    }

    host { 'oae-lb1':
        ip => '192.168.1.41',
        host_aliases => 'oae-lb1.localdomain',
        comment => 'Apache LB primary.',
        ensure => present
    }

    host { 'oae-lb2':
        ip => '192.168.1.42',
        host_aliases => 'oae-lb2.localdomain',
        comment => 'Apache LB secondary ',
        ensure => present
    }

    ##########################################
    # App Tier
    host { 'oae-app0':
        ip => '192.168.1.50',
        host_aliases => 'oae-app0.localdomain',
        comment => 'OAE app server',
        ensure => present
    }

    host { 'oae-app1':
        ip => '192.168.1.51',
        host_aliases => 'oae-app1.localdomain',
        comment => 'OAE app server',
        ensure => present
    }

    host { 'oae-preview0':
        ip => '192.168.1.80',
        host_aliases => 'oae-preview0.localdomain',
        comment => 'OAE preview processor server.',
        ensure => present
    }

    ##########################################
    # Search Tier
    host { 'oae-solr0':
        ip => '192.168.1.70',
        host_aliases => 'oae-solr0.localdomain',
        comment => 'Solr master',
        ensure => present
    }

    host { 'oae-solr1':
        ip => '192.168.1.71',
        host_aliases => 'oae-solr1.localdomain',
        comment => 'Solr slave',
        ensure => present
    }

    ##########################################
    # Storage Tier
    host { 'oae-db0':
        ip => '192.168.1.250',
        host_aliases => 'oae-db0.localdomain',
        comment => 'SparseMapContent database server',
        ensure => present
    }
}
