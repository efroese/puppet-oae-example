node basenode {
    include git
    include ntp
    include users

    if $operatingsystem == 'CentOS' {
	include centos
    }

}

node 'centos5-oae.localdomain' inherits basenode {
    include preview_processor
}

node 'centos6-oae.localdomain' inherits basenode {
    include preview_processor
}
