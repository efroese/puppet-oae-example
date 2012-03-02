#
# User and group resources for Kaleidoscope SIS integration
#
class people::kaleidoscope::internal {
    include people::kaleidoscope

    realize(Group['scp_internal'])
    realize(User['scp_internal'])
    realize(Ssh_authorized_key['scp_internal-pub'])
}

class people::kaleidoscope::external {
    include people::kaleidoscope

    realize(Group['kaleidoscope'])
    realize(User['kaleidoscope'])
    realize(Ssh_authorized_key['kaleidoscope-pub'])
}

class people::kaleidoscope {

    include rssh

    @group { 'scp_internal' : gid => '815' }
    @user { 'scp_internal':
        ensure     => present,
        uid        => '815',
        gid        => 'scp_internal',
        home       => '/home/scp_internal',
        managehome => true,
        groups     => ['scp_internal',],
        shell      => '/usr/bin/rssh'
    }
    @ssh_authorized_key { 'scp_internal-pub':
        ensure => present,
        # TODO add real pubkey
        key  => 'TODO need pubkey',
        type => 'ssh-dss',
        user => 'scp_internal',
        require => User['scp_internal'],
    }

    @group { 'kaleidoscope' : gid => '816' }
    @user { 'kaleidoscope':
        ensure     => present,
        uid        => '816',
        gid        => 'kaleidoscope',
        home       => '/home/kaleidoscope',
        managehome => true,
        groups     => ['kaleidoscope',],
        shell      => '/usr/bin/rssh'
    }
    @ssh_authorized_key { 'kaleidoscope-pub':
        ensure => present,
        # TODO add real pubkey
        key  => 'TODO',
        type => 'ssh-dss',
        user => 'kaleidoscope',
        require => User['kaleidoscope'],
    }
}
