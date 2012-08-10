# Configuration for Sakai OAE
#
# = Class oae::params
# Common variables used across the OAE configuration.
#
# == Parameters:
# $user:: the user sakai will run as
#
# $group:: the group sakai will run as
#
# $basedir:: where all of the sakai oae artifacts will live
#
class oae::params(  $user='sakaioae',
                    $group='sakaioae',
                    $basedir='/usr/local/sakaioae') {

    realize(Group[$group])
    realize(User[$user])

    file { $basedir:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => 755,
    }

    $logs = '/var/log/sakaioae'

    file { $logs:
        ensure => directory,
        owner  => root,
        group  => $group,
        mode   => 775,
    }
}
