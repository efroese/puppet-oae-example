class postgres::client {

    Class['Postgres::Repos'] -> Class['Postgres::Client']

    if !defined(Class['Postgres::Base']) {
        class { 'postgres::base': }
    }
}