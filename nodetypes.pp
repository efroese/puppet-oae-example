###########################################################################
#
# Node Type Definitions
#
node basenode {

    if $operatingsystem == 'CentOS' {
        class { 'centos': stage => init }
        if $virtual == "virtualbox" {
            class { 'centos_minimal': stage => init }
        }
    }

    class { 'git': }
    class { 'java': }   
    class { 'ntp':
        time_zone =>  '/usr/share/zoneinfo/America/Phoenix',
    }
}

node oaenode inherits basenode {

    # OAE cluster-specific configuration
    class { 'localconfig': }
    class { 'localconfig::hosts': }
    class { 'localconfig::users': }

    # OAE module configuration
    class { 'oae::params':
        user    => $localconfig::user,
        group   => $localconfig::group,
        basedir => $localconfig::basedir,
    }
}