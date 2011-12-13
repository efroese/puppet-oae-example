class oae-app(  $oae_user="sakaioae", $basedir="/usr/local/sakaioae", 
                $version_oae, $version_sparse,
                $downloaddir, $jarfile,
                $javamemorymax, $javapermsize) {
   
    $required_pkgs = ['curl', ]
    package { $required_pkgs: ensure => installed }

    realize(Group[$oae_user])
    realize(User[$oae_user])

    $logdir  = "/var/log/sakaioae"
    $etcdir = "/etc/sakaioae"

    $solrdir = "$basedir/sling/solr"
    $sparse_store_dir = "$basedir/store"

    $app_dirs = [ $basedir, "${basedir}/jars", "${basedir}/sling"]

    file { [$app_dirs, $logdir, $etcdir, $solrdir, $sparse_store_dir]:
        ensure => directory,
        owner  => $oae_user,
        group  => $oae_user,
        mode   => 0775,
    }

    file {"${basedir}/sling/logs":
        ensure  => link,
        owner   => $oae_user,
        group   => $oae_user,
        target  => "${logdir}",
    }

    file { "${basedir}/sling/nakamura.properties":
        ensure => present,
        owner   => $oae_user,
        group   => $oae_user,
        mode    => '0644',
        source  => "puppet:///modules/oae-app/nakamura.properties",
    }

    $confdir = "${basedir}/sling/config"

    # Create the configuration directory heirarchy for sling:
    $confdirs = [
        "${confdir}/",
        "${confdir}/org/",
        "${confdir}/org/sakaiproject/",
        "${confdir}/org/sakaiproject/nakamura/",
        "${confdir}/org/sakaiproject/nakamura/auth/",
        "${confdir}/org/sakaiproject/nakamura/http/",
        "${confdir}/org/sakaiproject/nakamura/lite/",
        "${confdir}/org/sakaiproject/nakamura/auth/trusted/",
        "${confdir}/org/sakaiproject/nakamura/http/usercontent/",
        "${confdir}/org/sakaiproject/nakamura/lite/storage/",
        "${confdir}/org/sakaiproject/nakamura/lite/storage/jdbc/",
        "${confdir}/org/sakaiproject/nakamura/proxy/",
    ]

    file { $confdirs:
        ensure  => directory,
        owner   => $oae_user,
        group   => $oae_user,
        mode    => '0755';
    }

    file { "${confdir}/org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config":
        owner   => $oae_user,
        group   => $oae_user,
        mode    => '0440',
        content => template('oae-app/config/org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config.erb');
    }

    file { "${confdir}/org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config":
        owner   => $oae_user,
        group   => $oae_user,
        mode    => '0440',
        content => template('oae-app/config/org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config.erb');
    }

    exec { 'fetch-package':
        command => "curl --silent ${downloaddir}${jarfile} --output ${basedir}/jars/${jarfile}",
        cwd     => "${basedir}/jars/",
        unless  => "stat ${basedir}/jars/${jarfile}",
        require => [ File["${basedir}/jars/"], Package['curl'] ],
    }

    exec { 'link-package':
        command => "/bin/ln -s ${basedir}/jars/${jarfile} ${basedir}/sakaioae.jar",
        onlyif  => "stat ${basedir}/jars/${jarfile} ${basedir}/sling/sling.properties ${basedir}/sling/config.tar.gz",
        unless  => '/usr/bin/stat ${basedir}/sakaioae.jar',
        require => [
            File["${basedir}/sling/nakamura.properties"],
            File["/etc/init.d/sakaioae"],
            File["${basedir}/sling/config/org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config"],
            File["${basedir}/sling/config/org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config"],
            File["${basedir}/store"],
            File["${basedir}/sling/solr"],
            File["/var/log/sakaioae/"],
            File["${basedir}/sling/logs/"]
        ],
        notify  => Service['sakaioae'],
    }

    file { '/etc/init.d/sakaioae':
        ensure  => present,
        mode    => '0755',
        content => template('oae-app/sakaioae.sh.erb'),
        notify  => Service['sakaioae'],
    }

    service { 'sakaioae':
        ensure => running,
    }
    
}
