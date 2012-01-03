class localconfig::hosts {

    host { 'oae':          ip => '192.168.1.40', comment => 'HA Apache virtual IP', ensure => present }
    host { 'oae-lb1':      ip => '192.168.1.41', comment => 'Apache LB primary.', ensure => present }
    host { 'oae-lb2':      ip => '192.168.1.42', comment => 'Apache LB secondary ', ensure => present }

    host { 'oae-app0':     ip => '192.168.1.50', comment => 'OAE app server', ensure => present }
    host { 'oae-app1':     ip => '192.168.1.51', comment => 'OAE app server', ensure => present }

    host { 'oae-solr0':    ip => '192.168.1.70', comment => 'Solr master', ensure => present }
    host { 'oae-solr1':    ip => '192.168.1.71', comment => 'Solr slave', ensure => present }

    host { 'oae-db0':      ip => '192.168.1.250', comment => 'SparseMapContent database server', ensure => present }
    host { 'oae-preview0': ip => '192.168.1.80',  comment => 'OAE preview processor server.', ensure => present }
}
