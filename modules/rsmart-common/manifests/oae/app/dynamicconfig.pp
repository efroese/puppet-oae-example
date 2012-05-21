#
# OAE Dynamic config 
#
class rsmart-common::oae::app::dynamicconfig($locked = true){

    Class['Localconfig'] -> Class['Rsmart-common::Oae::App::Dynamicconfig']

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.dynamicconfig.file.FileBackedDynamicConfigurationServiceImpl":
        config => {
            'config.master.dir' => $localconfig::dynamic_config_root,
            'config.master.filename' => $localconfig::dynamic_config_masterfile,
            'config.custom.dir' => $localconfig::dynamic_config_customdir,
        },
        locked => $locked,
    }

    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.dynamicconfig.override.ConfigurationOverrideServiceImpl":
        config => {
            'override.dirs' => $localconfig::dynamic_config_jcroverrides,
        },
        locked => $locked,
    }

    file { "${localconfig::dynamic_config_root}":
        ensure => directory
    }

    file { "${localconfig::dynamic_config_customdir}":
        ensure => directory,
        require => File[$localconfig::dynamic_config_root],
    }

    file { "${localconfig::dynamic_config_customdir}/config_custom.json":
        mode => 0644,
        content => template("rsmart-common/config_custom.json.erb"),
        require => File[$localconfig::dynamic_config_customdir],
    }

}