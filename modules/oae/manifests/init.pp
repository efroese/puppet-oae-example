class oae {

    Class['aoe'] -> Class['oae::params']

    define sling_config($dirname, $pid, $config){

        $sling_config = "${oae::params::basedir}/sling/config"

        if !defined(Exec["mkdir_${sling_config}/${dirname}"]) {
            exec { "mkdir_${sling_config}/${dirname}":
                command => "mkdir -p ${sling_config}/${dirname}",
                require => Class['oae-app'],
            }
        }

        if !defined(Exec["chown_${sling_config}/${dirname}"]) {
            exec { "chown_${sling_config}/${dirname}":
                command => "chown -R ${oae::params::user}:${oae::params::group} ${sling_config}/${dirname}",
                require => Class['oae-app'],
            }
        }

        file { "${sling_config}/${name}":
            owner => $oae::params::user,
            group => $oae::params::group,
            mode  => 0440,
            content => template("oae/sling_config.erb"),
            require => Exec["mkdir_${sling_config}/${dirname}"],
        }

    }
}
