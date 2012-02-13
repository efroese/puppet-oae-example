class people {
    class { 'people::groups': }
    class { 'people::users': }
    
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
}