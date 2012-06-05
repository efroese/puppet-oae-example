class postgres::params {
    
    $bin_dir = '/usr/pgsql-9.1/bin/'
    
    $psql    = "${bin_dir}/psql"
    $pg_dump = "${bin_dir}/pg_dump"
    
    $createuser = "${bin_dir}/createuser"
    $dropuser = "${bin_dir}/dropuser"
}