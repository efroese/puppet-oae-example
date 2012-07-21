class people {

        Class['Localconfig'] -> Class['People']

        class { 'people::groups': }
        class { 'people::users': }

        realize(Group[$localconfig::group])
        realize(User[$localconfig::user])

        realize(Group['branden'])
        realize(User['branden'])
        realize(Ssh_authorized_key['branden'])

        realize(Group['aberg'])
        realize(User['aberg'])
        realize(Ssh_authorized_key['aberg'])

        realize(Group['denbuzze'])
        realize(User['denbuzze'])
        realize(Ssh_authorized_key['denbuzze'])
        
        realize(Group['zach'])
        realize(User['zach'])
        realize(Ssh_authorized_key['zach'])
        
        realize(Group['ctweney'])
        realize(User['ctweney'])
        realize(Ssh_authorized_key['ctweney'])
        
        realize(Group['chall'])
        realize(User['chall'])
        realize(Ssh_authorized_key['chall'])
        
        realize(Group['raydavis'])
        realize(User['raydavis'])
        realize(Ssh_authorized_key['raydavis'])
}
