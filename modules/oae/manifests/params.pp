class oae::params {

    $user = 'sakaioae'
    $group = 'sakaioae'

    $basedir = '/usr/local/sakaioae'

    # SparseMapContent (Core)
    $sparseurl  = "jdbc:mysql://192.168.1.250:3306/nakamura?autoReconnectForPools\\=true"
    $sparsedriver = "com.mysql.jdbc.Driver"
    $sparseuser = 'nakamura'
    $sparsepass = 'ironchef'

    # ServerProctectionService
    # is the version of the server protection jar
    $version_http = '1.1'
    $serverprotectsec = 'thisisasecret'
    # is the content node url as seen by jetty (protocol will be as proxied to - probably http);
    $httpd_name_content = 'centos5-oae-app.localdomain'
    # is the external protocol of the content node url
    $http_content = 'http'
    # is the app node url (minus the protocol)
    $httpd_name = 'centos5-oae-app.localdomain'
    # is the app node ip address
    $ipaddress = '192.168.1.50'

    $install_http_admin = false
}
