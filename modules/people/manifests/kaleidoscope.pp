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
        groups     => ['scp_internal','rsshusers'],
        shell      => '/usr/bin/rssh'
    }
    @ssh_authorized_key { 'scp_internal-pub':
        ensure => present,
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAzf5fTjX14VZ3cukhr7Fx/adRx2btms0/FQHcqtLywg05sHG8Kao5zCL/oprXQ+moKipBDeEujmJ2WDpbweaWBPaADNRSHm0Qly5sMGTz2erK7e/lRxGpx7GVcqVT/eoVMq7CZSp+i4mr0rp9H/nyxpEP1Dpltb5PtEup0ECV7oNxnfJgF6Rr8lwXp6mOUq3mw78Hkbil6bdtG1NHq2L6+x5j7nIt8OVd2Mtb0CVZ7hdaAojNDy2BWCq5OrLbuheYRakUOWZfIFAWyN7jDvOWAM1Bu0pQ2QgpyodS2v0g+t8HYABQVO7By55+uYqAbJOwwDqYIfJq5KqNhGy3DnIacw==',
        type => 'ssh-rsa',
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
        groups     => ['kaleidoscope','rsshusers'],
        shell      => '/usr/bin/rssh'
    }
    @ssh_authorized_key { 'kaleidoscope-pub':
        ensure => present,
	# TODO add real pubkey
        key  => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAzf5fTjX14VZ3cukhr7Fx/adRx2btms0/FQHcqtLywg05sHG8Kao5zCL/oprXQ+moKipBDeEujmJ2WDpbweaWBPaADNRSHm0Qly5sMGTz2erK7e/lRxGpx7GVcqVT/eoVMq7CZSp+i4mr0rp9H/nyxpEP1Dpltb5PtEup0ECV7oNxnfJgF6Rr8lwXp6mOUq3mw78Hkbil6bdtG1NHq2L6+x5j7nIt8OVd2Mtb0CVZ7hdaAojNDy2BWCq5OrLbuheYRakUOWZfIFAWyN7jDvOWAM1Bu0pQ2QgpyodS2v0g+t8HYABQVO7By55+uYqAbJOwwDqYIfJq5KqNhGy3DnIacw==',
        type => 'ssh-rsa',
        user => 'kaleidoscope',
        require => User['kaleidoscope'],
    }
}
