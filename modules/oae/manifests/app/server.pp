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

    exec { 'fetch-package':
        command => "curl --silent ${downloaddir}${jarfile} --output ${oae::params::basedir}/jars/${jarfile}",
        cwd     => "${oae::params::basedir}/jars/",
        unless  => "stat ${oae::params::basedir}/jars/${jarfile}",
        require => [ File["${oae::params::basedir}/jars/"], Package['curl'] ],
    }

    exec { 'link-package':
        command => "/bin/ln -s ${oae::params::basedir}/jars/${jarfile} ${oae::params::basedir}/sakaioae.jar",
        onlyif  => "stat ${oae::params::basedir}/jars/${jarfile}",
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
