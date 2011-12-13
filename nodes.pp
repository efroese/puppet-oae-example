node basenode {
    include users
    include git
    include ntp
    include java

    if $operatingsystem == 'CentOS' {
        include centos
    }

}

node 'centos5-oae.localdomain' inherits basenode {
    include preview_processor
}

node 'centos6-oae.localdomain' inherits basenode {
    include preview_processor
}

node 'centos6-oae-app.localdomain' inherits basenode {

    $downloaddir = 'http://source.sakaiproject.org/maven2-snapshots/org/sakaiproject/nakamura/org.sakaiproject.nakamura.app/1.1-SNAPSHOT/'
    $jarfile = 'org.sakaiproject.nakamura.app-1.1-SNAPSHOT.jar'

    $javamemorymax = '1000'
    $javapermsize = '512'

    $version_nakcore = '1.2-SNAPSHOT'
    $sparseurl  = "jdbc:mysql://localhost:3306/nakamura"
    $sparsedriver = "com.mysql.jdbc.Driver"
    $sparseuser = 'nakamura'
    $sparsepass = 'ironchef'

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
    $ipaddress = '192.168.1.60'

    $install_http_admin = false

    include oae_app
}
