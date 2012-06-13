class nfs::server {
  case $operatingsystem {
    Debian,Ubuntu:        { include nfs::server::debian }
    RedHat,CentOS,Amazon: { include nfs::server::redhat }
    default:              { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
}
