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

    realize(Group[$localconfig::group])
    realize(User[$localconfig::user])
    realize(Ssh_authorized_key["${localconfig::user}-rsmartian-deploy-pub"])

    realize(Group['rsmartian'])
    realize(User['rsmartian'])
	  realize(Ssh_authorized_key['rsmartian-deploy-pub'])

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
    realize(Ssh_authorized_key['kcampos-ops-pub'])

    realize(Group['mdesimone'])
    realize(User['mdesimone'])
    realize(Ssh_authorized_key['mdesimone-home-pub'])

    realize(Group['jbush'])
    realize(User['jbush'])
    realize(Ssh_authorized_key['jbush-pub'])
	
	  realize(Group['karagon'])
	  realize(User['karagon'])
	  realize(Ssh_authorized_key['karagon-laptop-pub'])
	  realize(Ssh_authorized_key['karagon-mbp-pub'])

    realize(Group['skamali'])
    realize(User['skamali'])
    realize(Ssh_authorized_key['skamali-pub'])

    realize(Group['ppilli'])
    realize(User['ppilli'])
    realize(Ssh_authorized_key['ppilli-home-pub'])

}
