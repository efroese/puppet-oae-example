class oae {

    # Load the oae::params class before the oae class
    Class['oae::params'] -> Class['oae']

    #
    # Configure a sling service by placing a file in sling/config/part/of/service/pid.config
    #
    # == Parameters 
    #
    # $dirname = The path below sling/config where the config file will be placed.
    # $config  = A hash of configkey => value to configure the service
    #            Supports strings, booleans, and arrays
    #
    define sling_config($dirname, $config){

        $sling_config = "${oae::params::basedir}/sling/config"

        # Create the folders for the config file
        if !defined(Exec["mkdir_${sling_config}/${dirname}"]) {
            exec { "mkdir_${sling_config}/${dirname}":
                command => "mkdir -p ${sling_config}/${dirname}",
                creates => "${sling_config}/${dirname}",
            }
        }

        # Create the folders for the config file
        if !defined(Exec["chown_${sling_config}/${dirname}"]) {
            exec { "chown_${sling_config}/${dirname}":
                command => "chown ${oae::params::user}:${oae::params::group} ${sling_config}/${dirname}",
                require => Exec["mkdir_${sling_config}/${dirname}"],
                unless  => "[ `stat --printf='%U' ${sling_config}/${dirname}` == '${$oae::params::user}' ]"
            }
        }

        # Write the config file and trigger a chown
        file { "${sling_config}/${name}":
            owner => $oae::params::user,
            group => $oae::params::group,
            mode  => 0440,
            content => template("oae/sling_config.erb"),
            require => Exec["mkdir_${sling_config}/${dirname}"],
        }

    }
}
