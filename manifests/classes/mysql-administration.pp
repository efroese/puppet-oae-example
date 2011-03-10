class mysql::administration {

# TODO:
# - permissions to edit my.cnf once augeas bug is corrected (see
#   modules/cognac/manifests/classes/mysql-slave.pp)
# - .my.cnf for people in %mysql-admin

  group { "mysql-admin":
    ensure => present,
  }

  common::concatfilepart { "sudoers.mysql":
    ensure => present,
    file => "/etc/sudoers",
    content => template("mysql/sudoers.mysql.erb"),
    require => Group["mysql-admin"],
  }

}
