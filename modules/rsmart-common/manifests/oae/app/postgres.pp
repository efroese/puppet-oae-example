#
# OAE Postgres Configuration
#
class rsmart-common::oae::app::postgres ($locked = true) {
 
    Class['Localconfig'] -> Class['Rsmart-common::Oae::App::Postgres']

    # Connect OAE to the DB
    class { 'postgres::repos': stage => init }
    class { 'postgres::client': }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-driver'      => $localconfig::db_driver,
            'jdbc-url'         => $localconfig::db_url,
            'username'         => $localconfig::db_user,
            'password'         => $localconfig::db_password,
            'long-string-size' => 16384,
            'store-base-dir'   => $localconfig::storedir,
        },
        locked => $locked,
    }
}