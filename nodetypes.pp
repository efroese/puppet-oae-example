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

    class { 'git': }
    class { 'java': }
    class { 'ntp':
        time_zone =>  '/usr/share/zoneinfo/America/Phoenix',
    }
}

node oaenode inherits basenode {

    include sudo

    # OAE cluster-specific configuration
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

node devopsnode inherits oaenode {

    # non-production nodetype with added devops goodness
	realize(Group['devops'])
	realize(User['jenkins'])
	realize(Ssh_authorized_key['jenkins-home-pub'])
}
