class people {

        Class['Localconfig'] -> Class['People']

        class { 'people::groups': }
        class { 'people::users': }

        realize(Group[$localconfig::group])
        realize(User[$localconfig::user])

        realize(Group['branden'])
        realize(User['branden'])
        realize(Ssh_authorized_key['branden-public'])

        realize(Group['aberg'])
        realize(User['aberg'])
        realize(Ssh_authorized_key['aberg-public'])

        realize(Group['denbuzze'])
        realize(User['denbuzze'])
        realize(Ssh_authorized_key['denbuzze-public'])
        
        realize(Group['zach'])
        realize(User['zach'])
        realize(Ssh_authorized_key['zach-public'])
        
        realize(Group['ctweney'])
        realize(User['ctweney'])
        realize(Ssh_authorized_key['ctweney-public'])
        
        realize(Group['chall'])
        realize(User['chall'])
        realize(Ssh_authorized_key['chall-public'])
        
        realize(Group['raydavis'])
        realize(User['raydavis'])
        realize(Ssh_authorized_key['raydavis-public'])
}
