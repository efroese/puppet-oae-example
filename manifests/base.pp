#
# = Class postgres::base
# Common class for postgres and postgres::client
#
class postgres::base {

    Class['Postgres::Repos'] -> Class['Postgres::Base']
    Class['Postgres::Params'] -> Class['Postgres::Base']

    class { 'postgres::params': }

    package { 'postgresql91': ensure => installed }

}