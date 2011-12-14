class oae-solr::master {

    file { "${oae-solr::solr_basedir}/conf/solrconfig.xml":
        ensure => present,
        owner  => $oae-solr::oae_user,
        group  => $oae-solr::oae_user,
        mode   => 0644,
        source => "file://${oae-solr::solr_bundle}/src/main/resources/slave-solrconfig.xml",
        notify => Service['solr'],
    }

}
