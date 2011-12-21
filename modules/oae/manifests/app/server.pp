class oae::app::server($version_oae,
                $downloaddir, $jarfile,
                $javamemorymax, $javapermsize) {

    include oae::app::setup
    
    Class['oae::app::setup'] -> Class['oae::app::server']

    file { "${oae::params::basedir}/sling/nakamura.properties":
        ensure => present,
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => '0644',
        source  => "puppet:///modules/oae/nakamura.properties",
    }

    $jar_dest = "${oae::params::basedir}/jars/${jarfile}"

    exec { 'fetch-package':
        command => "curl --silent ${downloaddir}${jarfile} --output ${jar_dest}",
        cwd     => "${oae::params::basedir}/jars/",
        creates => "${jar_dest}",
        require => [ File["${oae::params::basedir}/jars/"], Package['curl'] ],
    }

    exec { 'link-package':
        command => "/bin/ln -s ${oae::params::basedir}/jars/${jarfile} ${oae::params::basedir}/sakaioae.jar",
        creates => $jar_dest,
        unless  => '/usr/bin/stat ${oae::params::basedir}/sakaioae.jar',
        require => [
            File["${oae::params::basedir}/sling/nakamura.properties"],
            File["/etc/init.d/sakaioae"],
            File[ $oae::app::setup::app_dirs ],
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
