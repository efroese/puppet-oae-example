###########################################################################
#
# Node Type Definitions
#
node basenode {

    if $operatingsystem =~ /Redhat|CentOS/ {
        if $virtual == "virtualbox" {
            class { 'centos_minimal': stage => init }
        }
    }

    if $operatingsystem =~ /Amazon|Linux/ {
        class { 'centos': stage => init }
    }

    package { 'git' : ensure => installed }
    package { 'java-1.6.0-openjdk': ensure => installed }
    package { 'bash-completion': ensure => installed }

    class { 'ntp':
        time_zone =>  '/usr/share/zoneinfo/America/Phoenix',
    }
}

node oaenode inherits basenode {

    # The localconfig module is found in $environment/modules
    class { 'localconfig': }
    class { 'localconfig::hosts': }

    class { 'people': }

    # OAE module configuration
    class { 'oae::params':
        user    => $localconfig::user,
        group   => $localconfig::group,
        basedir => $localconfig::basedir,
    }
}
