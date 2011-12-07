node basenode {
    include git
    include ntp
}

node 'centos5-oae.localdomain' {
    include preview_processor
}

node 'centos6-oae.localdomain' {
    include preview_processor
}
