class oae-solr($oae_user='sakaioae', $basedir='/usr/local/sakaioae', $oae_version) {

    file { $basedir:
        ensure => directory,
        owner => $oae_user,
        group => $oae_user,
        mode  => 0755,
    }

    exec { 'download-solr':
        command => "curl -o ${basedir}/solr.tgz  http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
        creates => "${basedir}/solr.tgz",
    }

    exec { 'unpack-solr':
        command => "tar xzvf ${basedir}/solr.tgz -C ${basedir}",
        creates => "${basedir}/example",
        require => Exec['download-solr'],
    }
}
