#
# = Class: People
# Users and groups
#
# Reserved UIDs and GIDs
# 500 -> 600 - Humans from rSmart
# 600 -> 999 - rSmart services, robots, puppets
# 1000 -> infiniti - Others
#
class people {

    Class['Localconfig'] -> Class['People']

    class { 'people::groups': }
    class { 'people::users': }

    realize($localconfig::user)
    realize($localconfig::group)

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
