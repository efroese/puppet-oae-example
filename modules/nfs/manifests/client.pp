class nfs::client {
  case $operatingsystem {
    Debian,Ubuntu:        { include nfs::client::debian}
    RedHat,CentOS,Amazon,Linux: { include nfs::client::redhat}
    default:              { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
}

