class oae-solr($oae_user = 'sakaioae', $basedir = '/usr/local/sakaioae', $oae_version,
        $solr_git = 'http://github.com/sakaiproject/solr.git') {

    realize(Group[$oae_user])
    realize(User[$oae_user])

    # Home for standalone solr servers
    $solr_basedir= "${basedir}/solr"

    # A git clone of the sakaiproject/solr
    $solr_bundle = "${solr_basedir}/solr-bundle"

    # Solr installation
    $solr_app    = "${solr_basedir}/solr-app"

    # Solr node config
    $solr_conf   = "${solr_app}/conf"

    file { $basedir:
        ensure => directory,
        owner => $oae_user,
        group => $oae_user,
        mode  => 0755,
    }

    exec { 'download-solr':
        command => "curl -o ${solr_basedir}/solr.tgz  http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
        creates => "${solr_basedir}/solr.tgz",
        require => File[$basedir],
    }

    exec { 'unpack-solr':
        command => "tar xzvf ${solr_basedir}/solr.tgz -C ${solr_basedir}",
        creates => "${solr_basedir}/example",
        require => Exec['download-solr'],
    }

    exec { 'copy-solr-app':
        command => "cp -a ${solr_basedir}/example ${solr_app}",
        creates => "${solr_app}",
        require => Exec['unpack-solr'],
    }

    exec { 'clone-solr':
        command => "git clone ${solr_git} ${solr_bundle}",
        creates => "${solr_bundle}",
        require => File[$basedir],
    }

    file { $solr_conf:
        ensure => directory,
        owner  => $oae_user,
        group  => $oae_user,
        mode   => 755,
        require => Exec['copy-solr-app'],
    }

    exec { 'copy-solr-resources':
        command => "cp ${solr_basedir}/solr-bundle/src/main/resources/* ${solr_conf}",
        creates => "${solr_bundle}/schema.xml",
        require => [ Exec['clone-solr'], File[$solr_conf], ],
    }

    file { '/etc/init.d/solr':
        ensure => present,
        owner  => $oae_user,
        group  => $oae_user,
        mode   => 0755,
        content => template("oae-solr/solr.erb"),
    }

    service { 'solr':
        ensure => running,
    }
}
