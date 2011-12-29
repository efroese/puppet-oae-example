class oae {

    # Load the oae::params class before the oae class
    Class['oae::params'] -> Class['oae']

    define sling_config($dirname, $config){

        $sling_config = "${oae::params::basedir}/sling/config"

        if !defined(Exec["mkdir_${sling_config}/${dirname}"]) {
            exec { "mkdir_${sling_config}/${dirname}":
                command => "mkdir -p ${sling_config}/${dirname}",
                creates => "${sling_config}/${dirname}",
            }
        }

        if !defined(Exec["chown_${sling_config}/${dirname}"]) {
            exec { "chown_${sling_config}/${dirname}":
                command => "chown -R ${oae::params::user}:${oae::params::group} ${sling_config}/${dirname}",
                require => Exec["mkdir_${sling_config}/${dirname}"],
                unless  => "[ `stat --printf='%U' ${sling_config}/${dirname}` == '${$oae::params::user}' ]"
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
