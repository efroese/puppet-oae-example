define postgres::clientauth (
    $type,
    $db,
    $user,
    $address,
    $method,
    $option
    ) {

    $config_line = "${type} ${db} ${user} ${address} ${method} ${option}"
    $hba_conf    = '/var/lib/pgsql/data/pg_hba.conf'

    exec { "Append host line to pg_hba.conf":
        command => "echo ${config_line} >> ${hba_conf}",
        unless  => "grep ${config_line} ${hba_conf}"
    }
}