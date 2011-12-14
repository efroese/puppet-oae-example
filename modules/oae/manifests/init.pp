class oae {

    Class['aoe'] -> Class['oae::params']

    define sling_config($dirname, $pid, $config){

        if ! defined(File["${oae::params::basedir}/sling/config/$dirname"]) {
            file { "${oae::params::basedir}/sling/config/$dirname":
                ensure => directory,
                owner => $oae::params::user,
                group => $oae::params::group,
                mode  => 0770,
                require => Class['oae-app'],
            }
        }

        file { "${oae::params::basedir}/sling/config/${name}":
            owner => $oae::params::user,
            group => $oae::params::group,
            mode  => 0440,
            content => template("oae/sling_config.erb"),
            require => Class['oae-app'],
        }
    }
}
