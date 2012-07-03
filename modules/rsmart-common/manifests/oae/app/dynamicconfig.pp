#
# OAE Dynamic config 
#
class rsmart-common::oae::app::dynamicconfig(
    $locked = true,
    $config_js = 'rsmart-common/config.js.erb'){

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

    file { "${localconfig::dynamic_config_customdir}/config.js":
        mode => 0644,
        content => template($config_js),
        require => File[$localconfig::dynamic_config_customdir],
    }

}