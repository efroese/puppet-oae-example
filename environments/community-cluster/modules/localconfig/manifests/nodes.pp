###########################################################################
#
# Nodes
#
# This is an example of how to set up a Sakai OAE Cluster with puppet.
#
# The example cluster consists of the following:
#
#
# App tier - 2 OAE application nodes
# Appservers (ELB in front):
# DNS(ELB) -> OAE-AppServers-365563856.us-west-1.elb.amazonaws.com
# App1 DNS for ssh(not sticky, don't use for config) -> ec2-50-18-147-148.us-west-1.compute.amazonaws.com
# App2 DNS for ssh(not sticky, don't use for config) -> ec2-204-236-168-81.us-west-1.compute.amazonaws.com
# SSH Port 22
#
# Preview (ELB in front): 
# DNS(ELB) -> OAE-Preview-2008250595.us-west-1.elb.amazonaws.com
# SSH Port 2022
#
# Search tier - 1 solr master
# SOLR (ELB in front):
# DNS(ELB) -> OAE-SOLR-426995740.us-west-1.elb.amazonaws.com
# SSH Port 2022
#
# Storage tier - One Postgres database node.
# Postgres (ELB in front):
# DNS(ELB) -> OAE-Postgres-566174176.us-west-1.elb.amazonaws.com
# SSH Port 2022

###########################################################################
#
# OAE app nodes
#
node /oae-app[0-1].localdomain/ inherits oaenode {

    class { 'oae::app::server':
        downloadurl    => 'http://source.sakaiproject.org/maven2/org/sakaiproject/nakamura/org.sakaiproject.nakamura.app/1.3.0/org.sakaiproject.nakamura.app-1.3.0.jar',
        javamemorymax  => $localconfig::javamemorymax,
        javamemorymin  => $localconfig::javamemorymin,
        javapermsize   => $localconfig::javapermsize,
    }
    
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool":
        config => {
            'jdbc-url'    => $localconfig::db_url,
            'jdbc-driver' => $localconfig::db_driver,
            'username'    => $localconfig::db_user,
            'password'    => $localconfig::db_password,
        }
    }

    ## Server protection service
    # Separates trusted vs untusted content.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
        config => {
            'disable.protection.for.dev.mode' => false,
            'trusted.hosts'  => [
                "localhost\\ \\=\\ https://localhost:8081",
                "${localconfig::http_name}\\ \\=\\ https://${localconfig::http_name}:8443",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        }
    }

    ## Solr
    # Specify the client type
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.solr.SolrServerServiceImpl":
        config => { "solr-impl" => "remote", },
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
    }

    ## Clustering
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.cluster.ClusterTrackingServiceImpl":
        config => {
            'secure-host-url' => "http://${ipaddress}:8081",
        }
    }

    # Clustered Cache
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.memory.CacheManagerServiceImpl":
        config => {
            'bind-address' => $ipaddress,
        }
    }

    # TODO - Make this dynamic using exported resources
    class { 'oae::app::ehcache':
        peers       => [ $localconfig::app_server1, $localconfig::app_server2, ],
        tcp_address => $ipaddress,
        remote_object_port => $localconfig::ehcache_remote_object_port,
    }
    
}

###########################################################################
#
# OAE Solr Nodes
#

node solrnode inherits oaenode {

    class { 'tomcat6':
        parentdir => "${localconfig::basedir}",
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
        require      => File[$oae::params::basedir],
    }

}

node 'oae-solr0.localdomain' inherits solrnode {

    class { 'solr::tomcat':
        user         => $localconfig::user,
        group        => $localconfig::group,
        tomcat_user  => $localconfig::user,
        tomcat_group => $localconfig::group,
        tomcat_home  => "${localconfig::basedir}/tomcat",
        solr_tarball => 'http://nodeload.github.com/sakaiproject/solr/tarball/org.sakaiproject.nakamura.solr-1.4.2',
        require      => Class['Tomcat6'],
    }

}

# node /oae-solr[1-3].localdomain/ inherits solrnode {
# 
#     class { 'solr::tomcat':
#         master_url   => "${localconfig::solr_remoteurl}/replication",
#         tomcat_home  => "${localconfig::basedir}/tomcat",
#         tomcat_user  => $localconfig::user,
#         tomcat_group => $localconfig::group, 
#     }
# }

###########################################################################
#
# OAE Content Preview Processor Node
#
node 'oae-preview.localdomain' inherits oaenode {
    class { 'oae::preview_processor::init':
        upload_url   => "https://${localconfig::http_name}/",
    }
}

###########################################################################
#
# Postgres Database Server
#
node 'oae-db0.localdomain' inherits oaenode {

    class { 'postgres::repos': stage => init }
    class { 'postgres': }

    postgres::database { $localconfig::db:
        ensure => present,
        require => Class['Postgres'],
    }

    postgres::role { $localconfig::db_user:
        ensure   => present,
        password => $localconfig::db_password,
        require  => Postgres::Database[$localconfig::db],
    }

    postgres::clientauth { "host-${localconfig::db}-${localconfig::db_user}-all-md5":
       type => 'host',
       db   => $localconfig::db,
       user => $localconfig::db_user,
       address => "$ipaddress/24",
       method  => 'md5',
    }

    postgres::backup::simple { $localconfig::db: }
}