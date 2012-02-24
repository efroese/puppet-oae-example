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

    realize(Group['hyperic'])
    realize(User['hyperic'])

    realize(Group['efroese'])
    realize(User['efroese'])

    realize(Group['lspeelmon'])
    realize(User['lspeelmon'])

    realize(Group['dgillman'])
    realize(User['dgillman'])

    realize(Group['cramaker'])
    realize(User['cramaker'])
    
    realize(Group['dthomson'])
    realize(User['dthomson'])

    realize(Group['kcampos'])
    realize(User['kcampos'])

    realize(Group['mdesimone'])
    realize(User['mdesimone'])
}
