class oae::params {

    ###########################################################################
    # Basic system stuff
    $user = 'sakaioae'
    $group = 'sakaioae'

    $basedir = '/usr/local/sakaioae'

    file { $basedir:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::group,
        mode   => 750,
    }
}
