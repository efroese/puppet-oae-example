/*

==Class: mysql::server

Parameters:
 $mysql_user:: The mysql user
 $mysql_password:: The mysql root pw
 $mysql_exists

   If set, copies the content of the default mysql data location. This is
   necessary on Debian systems because the package installation script
   creates a special user used by the init scripts.

*/
class mysql::server (
    $mysql_user = 'root',
    $mysql_password = undef
    ) {

  include mysql::params

  user { "mysql":
    ensure => present,
    require => Package["mysql-server"],
  }

  package { "mysql-server":
    ensure => installed,
  }

  package { "pwgen":
    ensure => installed,
  }

  file { "${mysql::params::data_dir}":
    ensure  => directory,
    owner   => "mysql",
    group   => "mysql",
    seltype => "mysqld_db_t",
    require => Package["mysql-server"],
  }

  if( "${mysql::params::data_dir}" != "/var/lib/mysql" ) {
    File["${mysql::params::data_dir}"]{
      source  => "/var/lib/mysql",
      recurse => true,
      replace => false,
    }
  }

  # The amazon package doesn't create this
  file { '/etc/mysql':
    ensure => directory,
    require => Package['mysql-server']
  }

  file { "/etc/mysql/my.cnf":
    ensure => present,
    path => $mysql::params::mycnf,
    owner => root,
    group => root,
    mode => 644,
    seltype => "mysqld_etc_t",
    require => [Package["mysql-server"], File['/etc/mysql'] ]
  }

  file { "/usr/share/augeas/lenses/contrib/mysql.aug":
    ensure => present,
    owner => root,
    group => root,
    source => "puppet:///modules/mysql/mysql.aug",
  }

  augeas { "my.cnf/mysqld":
    context => "${mysql::params::mycnfctx}/mysqld/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      "set pid-file /var/run/mysqld/mysqld.pid",
      "set old_passwords 0",
      "set character-set-server utf8",
      "set log-warnings 1",
      "set datadir ${mysql::params::data_dir}",
      $operatingsystem ? {
        /RedHat|Fedora|CentOS|Amazon/ => "set log-error /var/log/mysqld.log",
        default => "set log-error /var/log/mysql.err",
      },
      $operatingsystem ? {
        /RedHat|Fedora|CentOS|Amazon/ => "set log-slow-queries /var/log/mysql-slow-queries.log",
        default => "set log-slow-queries /var/log/mysql/mysql-slow.log",
      },
      #"ins log-slow-admin-statements after log-slow-queries", # BUG: not implemented in puppet yet
      $operatingsystem ? {
        /RedHat|Fedora|CentOS|Amazon/ => "set socket /var/lib/mysql/mysql.sock",
        default => "set socket /var/run/mysqld/mysqld.sock",
      }
    ],
    require => [ File["/etc/mysql/my.cnf"], File["${mysql::params::data_dir}"] ],
    notify => Service["mysql"],
  }

  # by default, replication is disabled
  augeas { "my.cnf/replication":
    context => "${mysql::params::mycnfctx}/mysqld/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      "rm log-bin",
      "rm server-id",
      "rm master-host",
      "rm master-user",
      "rm master-password",
      "rm report-host"
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  augeas { "my.cnf/mysqld_safe":
    context => "${mysql::params::mycnfctx}/mysqld_safe/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      "set pid-file /var/run/mysqld/mysqld.pid",
      $operatingsystem ? {
        /RedHat|Fedora|CentOS|Amazon/ => "set socket /var/lib/mysql/mysql.sock",
        default => "set socket /var/run/mysqld/mysqld.sock",
      }
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  # force use of system defaults
  augeas { "my.cnf/performance":
    context => "${mysql::params::mycnfctx}/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
     "rm mysqld/key_buffer",
     "rm mysqld/max_allowed_packet",
     "rm mysqld/table_cache",
     "rm mysqld/sort_buffer_size",
     "rm mysqld/read_buffer_size",
     "rm mysqld/read_rnd_buffer_size",
     "rm mysqld/net_buffer_length",
     "rm mysqld/myisam_sort_buffer_size",
     "rm mysqld/thread_cache_size",
     "rm mysqld/query_cache_size",
     "rm mysqld/thread_concurrency",
     "rm mysqld/thread_stack",
     "rm mysqldump/max_allowed_packet",
     "rm isamchk/key_buffer",
     "rm isamchk/sort_buffer_size",
     "rm isamchk/read_buffer",
     "rm isamchk/write_buffer",
     "rm myisamchk/key_buffer",
     "rm myisamchk/sort_buffer_size",
     "rm myisamchk/read_buffer",
     "rm myisamchk/write_buffer"
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  augeas { "my.cnf/client":
    context => "${mysql::params::mycnfctx}/client/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      $operatingsystem ? {
        /RedHat|Fedora|CentOS|Amazon/ => "set socket /var/lib/mysql/mysql.sock",
        default => "set socket /var/run/mysqld/mysqld.sock",
      }
    ],
    require => File["/etc/mysql/my.cnf"],
  }

  service { "mysql":
    ensure      => running,
    enable      => true,
    name        => $operatingsystem ? {
      /RedHat|Fedora|CentOS|Amazon/ => "mysqld",
      default => "mysql",
    },
    require   => Package["mysql-server"],
  }

  if $mysql_user {} else { $mysql_user = "root" }

  if $mysql_password {

    $mysql_pw = $mysql_password

    if $mysql_exists == "true" {
      mysql_user { "${mysql_user}@localhost":
        ensure => present,
        password_hash => mysql_password($mysql_password),
        require => Exec["Generate my.cnf"],
      }
    }

    file { "/root/.my.cnf":
      ensure => present,
      owner => root,
      group => root,
      mode  => 600,
      content => template("mysql/my.cnf.erb"),
      require => Exec["Initialize MySQL server root password"],
    }

  } else {

    $mysql_pw = generate("/usr/bin/pwgen", 8, 1)

    file { "/root/.my.cnf":
      owner => root,
      group => root,
      mode  => 600,
      require => Exec["Initialize MySQL server root password"],
    }

  }

  exec { "Initialize MySQL server root password":
    unless      => "test -f /root/.my.cnf",
    command     => "mysqladmin -u${mysql_user} password ${mysql_pw}",
    notify      => Exec["Generate my.cnf"],
    require     => [Package["mysql-server"], Service["mysql"]]
  }

  exec { "Generate my.cnf":
    command     => "/bin/echo -e \"[mysql]\nuser=${mysql_user}\npassword=${mysql_pw}\n[mysqladmin]\nuser=${mysql_user}\npassword=${mysql_pw}\n[mysqldump]\nuser=${mysql_user}\npassword=${mysql_pw}\n[mysqlshow]\nuser=${mysql_user}\npassword=${mysql_pw}\n\" > /root/.my.cnf",
    refreshonly => true,
    creates     => "/root/.my.cnf",
  }

  $logfile_group = $mysql::params::logfile_group

  file { "/etc/logrotate.d/mysql-server":
    ensure => present,
    content => $operatingsystem ? {
      /RedHat|Fedora|CentOS|Amazon/ => template('mysql/logrotate.redhat.erb'),
                    /Debian/ => template('mysql/logrotate.debian.erb'),
      default => undef,
    }
  }

  file { "mysql-slow-queries.log":
    ensure  => present,
    owner   => mysql,
    group   => $operatingsystem ? {
      /RedHat|Fedora|CentOS|Amazon/ => adm,
      default => mysql,
    },
    mode    => 640,
    seltype => mysqld_log_t,
    path    => $operatingsystem ? {
      /RedHat|Fedora|CentOS|Amazon/ => "/var/log/mysql-slow-queries.log",
      default => "/var/log/mysql/mysql-slow-queries.log",
    };
  }

}
