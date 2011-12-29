class oae::solr($solr_git = 'http://github.com/sakaiproject/solr.git', $role) {

    realize(Group[$oae::params::user])
    realize(User[$oae::params::user])

    # Home for standalone solr servers
    $solr_basedir= "${oae::params::basedir}/solr"

    # A git clone of the sakaiproject/solr
    $solr_bundle = "${solr_basedir}/solr-bundle"

    # Solr installation
    $solr_app    = "${solr_basedir}/solr-app"

    # Solr node config
    $solr_conf   = "${solr_app}/conf"

    file { $basedir:
        ensure => directory,
        owner => $oae::params::user,
        group => $oae::params::user,
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

    exec { 'chown-solr':
        command => "chown -R ${$oae::params::user}:${$oae::params::group} ${solr_basedir}/example",
        unless  => "[ `stat --printf='%U'  ${solr_basedir}/example` == '${$oae::params::user}' ]",
        require => Exec['unpack-solr'],
    }

    exec { 'copy-solr-app':
        command => "cp -a ${solr_basedir}/example ${solr_app}",
        creates => "${solr_app}",
        require => Exec['chown-solr'],
    }

    exec { 'clone-solr':
        command => "git clone ${solr_git} ${solr_bundle}",
        creates => "${solr_bundle}",
        require => File[$basedir],
    }

    file { $solr_conf:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 755,
        require => Exec['copy-solr-app'],
    }

    exec { 'copy-solr-resources':
        command => "cp ${solr_basedir}/solr-bundle/src/main/resources/* ${solr_conf}",
        creates => "${solr_conf}/schema.xml",
        require => [ Exec['clone-solr'], File[$solr_conf], ],
    }

    file { "${oae::solr::solr_conf}/solrconfig.xml":
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => "0644",
        source => $role ? {
            '/master/slave' => "file://${oae::solr::solr_bundle}/src/main/resources/${role}-solrconfig.xml",
            default         => "file://${oae::solr::solr_bundle}/src/main/resources/solrconfig.xml",
        },
        notify => Service['solr'],
        require => Exec['copy-solr-resources'],
    }

    file { '/etc/init.d/solr':
        ensure => present,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 0755,
        content => template("oae/solr.erb"),
    }

    service { 'solr':
        ensure => running,
        require => File["${oae::solr::solr_conf}/solrconfig.xml"],
    }
}
