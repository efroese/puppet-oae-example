class oae::params {

    $user = 'sakaioae'
    $group = 'sakaioae'

    $basedir = '/usr/local/sakaioae'

    $virtual_ip         = '192.168.1.40'
    $virtual_ip_netmask = '255.255.255.0'
    $http_hosts         = ['centos5-oae-lb1.localdomain', 'centos5-oae-lb2.localdomain']

    ##############################################
    # SparseMapContent (Core)
    $sparseurl  = "jdbc:mysql://192.168.1.250:3306/nakamura?autoReconnectForPools\\=true"
    $sparsedriver = "com.mysql.jdbc.Driver"
    $sparseuser = 'nakamura'
    $sparsepass = 'ironchef'

    ##############################################
    # ServerProctectionService
    $serverprotectsec = 'thisisasecret'
    $http_name = 'centos5-oae.localdomain'
}
