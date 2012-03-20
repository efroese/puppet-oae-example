#
# = Class appdynamics
#
# == Parameters
# $basedir:: The app folder
#
# $tomcat_setenv_template:: Environment setup script to include
#
# == Usage
#
# class { 'appdynamics': 
#     basedir => $oae::params::basedir,
# }
#

class appdynamics(
    $basedir,
    $setenv_template='appdynamics/appdynamics.setenv.sh.erb'){

    Class['Oae::app::server'] -> Class['Appdynamics']

    file { "${basedir}/bin/appdynamics.setenv.sh":
        mode    => 0755,
        content => template($setenv_template),
    }
}