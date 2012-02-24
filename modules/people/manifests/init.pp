class people {

        Class['Localconfig'] -> Class['People']

        class { 'people::groups': }
        class { 'people::users': }

        realize(Group[$localconfig::group])
        realize(User[$localconfig::user])
}
