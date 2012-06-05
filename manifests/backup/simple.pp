# = Define: postgres::backup
#
# Set up a cron job to peridocially back up and zip a postgres db
#
# == Parameters:
#
# $backup_dir:: Where the backups go
#
# $date_format:: Format to send to date to make a timestamp
#
# $minute::     Minute(s) on the hour the cron job will run
#
# $hour::     Hour(s) the cron job will run
#
define postgres::backup::simple ($backup_dir='/var/lib/pgsql/9.1/backups',
                                $date_format='%Y%m%d-%H%M',
                                $hour='0',
                                $minute='1') {

    $pg_dump = '/usr/pgsql-9.1/bin/pg_dump'

    cron { "backup-postgres-${name}":
        command => $date_format ? {
            /''/    => "${pg_dump} ${name} | gzip > ${backup_dir}/${name}.sql.gz",
            default => "${pg_dump} ${name} | gzip > ${backup_dir}/${name}.`date +'${date_format}'`.sql.gz",
        },
        user    => 'postgres',
        minute  => $minute,
        hour    => $hour,
    }
}
