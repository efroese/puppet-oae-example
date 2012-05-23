class postgres::base {

    Class['Postgres::Repos'] -> Class['Postgres::Base']

    if !defined(Class['Postgres::Base']) {
        class { 'postgres::base': }
    }

    if !defined(Class['Postgres::Params']) {
        class { 'postgres::params': }
    }

}