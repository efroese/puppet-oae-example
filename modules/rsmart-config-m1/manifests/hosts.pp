class localconfig::hosts {
    # rSmart OAE 1.1 QA cluster 
    # 50.18.192.33  -> 10.50.9.41      load balancer (apache)
    # 50.18.193.154 -> 10.50.9.40      OAE
    host { 'oae-qa-lb0':    ip => '10.50.9.41',  ensure => installed, comment => 'Apache load balancer' }
    host { 'oae-qa-app0':   ip => '10.50.9.40',  ensure => installed, comment => 'OAE server' }
    host { 'oae-qa-cle':    ip => '10.50.9.55',  ensure => installed, comment => 'CLE server' }
    host { 'oae-qa-db0':    ip => '10.50.10.40', ensure => installed, comment => 'Database master' }
    host { 'oae-qa-db1':    ip => '10.50.10.41', ensure => installed, comment => 'Database slave' }
    host { 'oae-qa-solr0':  ip => '10.50.10.42', ensure => installed, comment => 'Solr master' }
    host { 'oae-qa-nfs0':   ip => '10.50.10.43', ensure => installed, comment => 'NFS server' }
    host { 'oae-qa-pp0':    ip => '10.50.10.44', ensure => installed, comment => 'Preview processor' }
}
