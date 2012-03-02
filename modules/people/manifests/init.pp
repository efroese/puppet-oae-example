class people ($sakai_user='sakaioae', $sakai_group='sakaioae', $uid='8080', $gid='8080'){
    class { 'people::groups':
        sakai_group => $sakai_group,
        gid => $gid,
    }

    class { 'people::users':
        sakai_user => $sakai_user,
        uid => $uid,
        gid => $gid,
    }

    realize(Group['rsmartian'])
    realize(User['rsmartian'])

    file { "/home/rsmartian/.bash_profile":
        owner => rsmartian,
        group => rsmartian,
        mode  => 0644,
        content => template('people/rsmartian-bash_profile.sh.erb'),
        require => User['rsmartian']
    }

    realize(Group['hyperic'])
    realize(User['hyperic'])

    realize(Group['efroese'])
    realize(User['efroese'])
    realize(Ssh_authorized_key['efroese-home-pub'])

    realize(Group['lspeelmon'])
    realize(User['lspeelmon'])
    realize(Ssh_authorized_key['lspeelmon-pub'])

    realize(Group['dgillman'])
    realize(User['dgillman'])
    realize(Ssh_authorized_key['dgillman-pub'])

    realize(Group['cramaker'])
    realize(User['cramaker'])
    realize(Ssh_authorized_key['cramaker-pub'])
    
    realize(Group['dthomson'])
    realize(User['dthomson'])
    realize(Ssh_authorized_key['dthomson-home-pub'])

    realize(Group['kcampos'])
    realize(User['kcampos'])
    realize(Ssh_authorized_key['kcampos-home-pub'])

    realize(Group['mdesimone'])
    realize(User['mdesimone'])
    realize(Ssh_authorized_key['mdesimone-home-pub'])
}
