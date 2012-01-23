define postgres::clientauth (
    $type,
    $db,
    $user,
    $address,
    $method,
    $option=""
    ) {

    if $option == "" {
        $config_line = "${type} ${db} ${user} ${address} ${method}"
    }
    else {
        $config_line = "${type} ${db} ${user} ${address} ${method} ${option}"
    }

    $hba_conf = '/var/lib/pgsql/data/pg_hba.conf'

    exec { "append-${config_line}-to-${hba_conf}":
        command => "echo ${config_line} >> ${hba_conf}",
        unless  => "grep '${config_line}' ${hba_conf}",
        notify  => Service['postgresql'],
    }
}