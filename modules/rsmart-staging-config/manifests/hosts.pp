class localconfig::hosts {
    # rSmart OAE 1.1 dev cluster 
    # 50.18.192.33  -> 10.50.9.41      load balancer (apache)
    # 50.18.193.154 -> 10.50.9.40      OAE
    host { 'dev-lb0':    ip => '10.50.9.41',  ensure => present, comment => 'Apache load balancer' }
    host { 'dev-app0':   ip => '10.50.9.40',  ensure => present, comment => 'OAE server' }
    host { 'dev-cle':    ip => '10.50.9.55',  ensure => present, comment => 'CLE server' }
    host { 'dev-db0':    ip => '10.50.10.40', ensure => present, comment => 'Database master' }
    host { 'dev-db1':    ip => '10.50.10.41', ensure => present, comment => 'Database slave' }
    host { 'dev-solr0':  ip => '10.50.10.42', ensure => present, comment => 'Solr master' }
    host { 'dev-nfs0':   ip => '10.50.10.43', ensure => present, comment => 'NFS server' }
    host { 'dev-pp0':    ip => '10.50.10.44', ensure => present, comment => 'Preview processor' }
}
