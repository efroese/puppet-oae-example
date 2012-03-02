# = Class: oae::solr
#
class oae::solr {
      
    # = Define: oae::solr::backup
    #
    # Set up solr backups
    #
    # == Parameters:
    #
    # $solr_url::  A URL to a solr server ( Example: http://oae-solr0:8080/solr )
    #
    # $user::   The user who will own the backups
    #
    # $group::   The group who will own the backups
    #
    # $backup_dir::   A directory to store the backups
    #
    # == Actions:
    #   Create the backup dir and a cron job.
    #
    # == Sample Usage:
    # 
    #   oae::solr::backup {
    #       solr_url   => "http://oae-solr0:8080/solr",
    #       backup_dir => '/usr/local/sakaioae/solr/backups',
    #       user       => $oae::params::user,
    #       group      => $oae::params::group,
    #   }
    #
    define backup($solr_url, $user, $group, $backup_dir) {
        
        file { $backup_dir:
            ensure => directory,
            owner  => $user,
            group  => $group,
            mode   => 0750,
        }
        
        cron { "oae-solr-backup-${solr_url}-${backup_dir}":
            user => $user,
            command => "curl '${solr_url}/replication?command=backup&location=${backup_dir}'",
            minute  => '0',
            hour    => '1',
            require => File[$backup_dir],
        }
    }
}
