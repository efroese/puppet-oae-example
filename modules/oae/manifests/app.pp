class oae::app( $basedir="/usr/local/sakaioae", 
                $version_oae,
                $downloaddir, $jarfile,
                $javamemorymax, $javapermsize) {

#    Class['oae::core'] -> Class['oae:app']

    $required_pkgs = ['curl', ]
    package { $required_pkgs: ensure => installed }

    realize(Group[$oae::params::user])
    realize(User[$oae::params::user])

    $log_dir  = "/var/log/sakaioae"
    $jar_dir  = "${basedir}/jars"

    $sling_dir  = "${basedir}/sling"
    $config_dir = "${sling_dir}/config"
    $solr_dir   = "${sling_dir}/solr"

    # TODO this needs to become a mount
    $sparse_store_dir = "${basedir}/store"

    $app_dirs = [ $basedir, $jar_dir, $sling_dir, $config_dir, $log_dir, $solr_dir, $sparse_store_dir]
    file { [$app_dirs]:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 0775,
    }

    file {"${basedir}/sling/logs":
        ensure  => link,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        target  => "${log_dir}",
    }

    file { "${basedir}/sling/nakamura.properties":
        ensure => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0644',
        source  => "puppet:///modules/oae/nakamura.properties",
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
            File[ [$app_dirs] ],
        ],
        notify  => Service['sakaioae'],
    }

    file { '/etc/init.d/sakaioae':
        ensure  => present,
        mode    => '0755',
        content => template('oae/sakaioae.sh.erb'),
        notify  => Service['sakaioae'],
    }

    service { 'sakaioae':
        ensure => running,
    }
    
}
