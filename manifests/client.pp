class postgres::client {
    Class['Postgres::Repos'] -> Class['Postgres::Client']

    package { 'postgresql91': ensure => installed }
}