###########################################################################
#
# Nodes
#
# make sure that modules/localconfig -> modules/rsmart-config-m1

###########################################################################
#
# OAE app nodes
#
node /rsmart-oae-app[0-1].localdomain/ inherits oaenode {

    $http_name = $localconfig::apache_lb_http_name

    class { 'oae::app::server':
        version_oae    => $localconfig::version_oae,
        downloaddir    => $localconfig::downloaddir,
        jarfile        => $localconfig::jarfile,
        javamemorymax  => $localconfig::javamemorymax,
        javapermsize   => $localconfig::javapermsize,
    }

    class { 'oae::core':
         url    => $localconfig::db_url,
         driver => $localconfig::db_driver,
         user   => $localconfig::db_user,
         pass   => $localconfig::db_password,
    }

    class { 'oae::app::ehcache':
        mcast_address => $localconfig::mcast_address,
        mcast_port    => $localconfig::mcast_port,
    }

    oae::app::server::sling_config { "org/sakaiproject/nakamura/http/usercontent/ServerProtectionServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/http/usercontent",
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => " ${http_name}:8080 = https://${http_name}:443 ", 
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    oae::app::server::sling_config { "org/sakaiproject/nakamura/solr/MultiMasterRemoteSolrClient.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "remoteurl"  => $localconfig::solr_remoteurl,
            "query-urls" => $localconfig::solr_queryurls,
        }
    }

    oae::app::server::sling_config { "org/sakaiproject/nakamura/solr/SolrServerServiceImpl.config":
        dirname => "org/sakaiproject/nakamura/solr",
        config => {
            "solr-impl" => "multiremote",
        }
    }
}

###########################################################################
#
# OAE Solr Nodes
#

node '10.50.10.42.localdomain' inherits oaenode {
    class { 'oae::solr': 
        master_url => "http://10.50.10.42:8983/solr/replication",
        solrconfig => 'localconfig/master-solrconfig.xml.erb',
    }
}

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'ip-10-50-10-44.localdomain' inherits oaenode {
    class { 'oae::preview_processor::init': 
        nakamura_git => $localconfig::nakamura_git,
        nakamura_tag => $localconfig::nakamura_tag,
    }
}

