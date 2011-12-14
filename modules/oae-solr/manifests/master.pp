class oae-solr::master {

    file { "${oae-solr::solr_conf}/solrconfig.xml":
        owner  => $oae-solr::oae_user,
        group  => $oae-solr::oae_user,
        mode   => "0644",
        source => "file://${oae-solr::solr_bundle}/src/main/resources/master-solrconfig.xml",
        notify => Service['solr'],
    }

}
