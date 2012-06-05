class postgres::client {

    Class['Postgres::Base'] -> Class['Postgres::Client']

    if !defined(Class['Postgres::Base']) {
        class { 'postgres::base': }
    }

}