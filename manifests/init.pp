class tomcat (  $parentdir      = '/usr/local',
                $tomcat_version = '6.0.35',
                $mirror         = 'http://archive.apache.org/dist/tomcat',
                $tomcat_users_template = 'tomcat/tomcat-users.xml.erb',
                $tomcat_user='root',
                $tomcat_group='root',
                $admin_user = 'tomcat',
                $admin_password = 'tomcat'
             ) {
                    
    $tomcat_url  = "${mirror}/tomcat-6/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"
    notice($tomcat_url)
    $tomcat_name = "localhost"
    $basedir     = "${parentdir}/tomcat"
    $javahome    = "/usr/lib/jvm/java"

    exec { "download-apache-tomcat-${tomcat_version}":
        command => "mkdir -p ${parentdir} && curl -o ${parentdir}/apache-tomcat-${tomcat_version}.tar.gz ${tomcat_url}",
        creates => "${parentdir}/apache-tomcat-${tomcat_version}.tar.gz",
    }

    exec { "unpack-apache-tomcat-${tomcat_version}":
        command => "tar xzf ${parentdir}/apache-tomcat-${tomcat_version}.tar.gz -C ${parentdir}",
        creates => "${parentdir}/apache-tomcat-${tomcat_version}",
    }

    exec { "chown-apache-tomcat-${tomcat_version}":
        command => "chown -R ${tomcat_user}:${tomcat_group} ${parentdir}/apache-tomcat-${tomcat_version}",
        unless  => "[ stat -c %U ${parentdir}/apache-tomcat-${tomcat_version} == ${tomcat_user}]",
    }

    file { $basedir: 
        ensure => link,
        target => "${parentdir}/apache-tomcat-${tomcat_version}",
        require => Exec["unpack-apache-tomcat-${tomcat_version}"],
    }

    file { "/etc/init.d/tomcat": 
        ensure => present,
        owner  => root,
        group  => root,
        mode   => 0755,
        content => template('tomcat/tomcat.init.erb'),
    }

    file { "${basedir}/conf/tomcat-users.xml": 
        ensure => present,
        owner  => root,
        group  => root,
        mode   => 0644,
        content => template($tomcat_users_template),
        require => Exec["unpack-apache-tomcat-${tomcat_version}"],
    }

    service { 'tomcat':
        ensure => running,
        require => File["${basedir}/conf/tomcat-users.xml"]
    }
}
