# = Define: postgres::backup
#
# Set up a cron job to peridocially back up and rotate postgres db.
# See http://wiki.postgresql.org/wiki/Automated_Backup_on_Linux for the original work.
#
# = Paramters:
#
# $backup_config_template:: The path to the config template you'd like to use (optional)
#
class postgres::backup::rotated ($backup_dir='/var/lib/pgsql/backups/',
                                $backup_user='postgres',
                                $backup_config_template='postgres/backup.config.erb'){

    $backup_config = "/etc/postgres/backup.config"

    file { $backup_config:
        owner => 'root',
        group => 'root',
        mode  => 0755,
        content  => template($backup_config_template),
    }

    file { "/usr/bin/pg_backup_rotated.sh":
        owner => 'root',
        group => 'root',
        mode  => 0755,
        content  => template('postgres/pg_backup_rotated.sh.erb'),
    }

    cron { "postgres-backup-rotated":
        command => "/usr/bin/pg_backup_rotated.sh",
        user    => 'postgres',
        minute  => 1,
        hour    => 0,
    }
}