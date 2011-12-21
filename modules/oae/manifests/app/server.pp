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
    $app_jar = "${oae::params::basedir}/sakaioae.jar"

    exec { 'fetch-package':
        command => "curl --silent ${downloaddir}${jarfile} --output ${jar_dest}",
        cwd     => "${oae::params::basedir}/jars/",
        creates => "${jar_dest}",
        require => [ File["${oae::params::basedir}/jars/"], Package['curl'] ],
    }

    file { $app_jar:
        ensure  => link,
        target  => $jar_dest,
        require => Exec['fetch-package'],
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
