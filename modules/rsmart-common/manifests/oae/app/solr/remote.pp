#
# Configure OAE to use a single remote solr instance
#
class rsmart-common::oae::app::solr::remote ($locked = true){
    
    Class['Localconfig'] -> Class['Rsmart-common::Oae::App::Solr::Remote']
    
    # Specify the client type
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.SolrServerServiceImpl":
        config => { "solr-impl" => "remote", },
        locked => $locked,
    }

    # Configure the client with the master/slave(s)] info
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.RemoteSolrClient":
        config => {
            "remoteurl"  => $localconfig::solr_remoteurl,
            "socket.timeout" => 10000,
            "connection.timeout" => 3000,
            "max.total.connections" => 500,
            "max.connections.per.host" => 500,
        },
        locked => $locked,
    }
}