#
# = Class postgres::base
# Common class for postgres and postgres::client
#
class postgres::base {

    Class['Postgres::Repos'] -> Class['Postgres::Base']

    package { 'postgresql91': ensure => installed }
}