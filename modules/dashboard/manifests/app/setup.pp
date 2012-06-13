# = Class: dashboard::app::server
#
# This class sets up the directories necessary for a Dashbaord install
#
# == Paramters:
#
# $store_dir:: Where content bodies get stored.
#   A link is created due to a race condition with bringing up OSGi services
#   that causes sparse to temporarily come up with its default configuration.
#
# == Actions:
#   Create a few directories and links.
#
# == Sample Usage:
#
#   You don't use this class directly. The dashboard::app::server class includes it.
#
class dashboard::app::setup($user,
                            $group,
                            $basedir,
                            $config_dir,
                            $bin_dir){
		
    package { 'curl': ensure => installed }
    
    realize(Group[$group])
    realize(User[$user])
    
    file { [ $config_dir, $bin_dir ]:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => 0775,
    }

    file { '/etc/profile.d/dashboard.sh':
        mode    => 0755,
        content => "export DASHBOARD_HOME=${basedir}",
    }

}
