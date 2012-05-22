#
# Postgres DB and authentication setup for OAE
#
class rsmart-common::postgres::oaedb {

    Class['Localconfig'] -> Class['Rsmart-common::Postgres::Oaedb']

    postgres::database { $localconfig::oae_db:
        ensure => present,
    }

    postgres::role { $localconfig::oae_db_user:
        ensure   => present,
        password => $localconfig::oae_db_password,
        require  => Postgres::Database[$localconfig::oae_db],
    }

    postgres::clientauth { "host-${localconfig::oae_db}-${localconfig::oae_db_user}-all-md5":
       type => 'host',
       db   => $localconfig::oae_db,
       user => $localconfig::oae_db_user,
       address => "all",
       method  => 'md5',
    }

}
