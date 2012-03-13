# = Class: oae::solr
#
# This class installs a standalone solr master or slave for Sakai OAE
#
# == Parameters:
#
# $solr_tarball:: See oae::solr::common
#
# $solr_home_tarball:: See oae::solr::common
#
# $solrconfig::   See oae::solr::common
#
# $schema::       See oae::solr::common
#
# $master_url::   See oae::solr::common
#
# == Actions:
#   Install a solr server.
#
# == Sample Usage:
# 
#   class { 'oae::solr::jetty':
#     solr_tarball => "http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
#     solrconfig   => 'myconfig/solrconfig.xml.erb',
#     schema       => 'myconfig/schema.xml.erb',
#   }
#
class oae::solr::jetty(
                    $solr_tarball      = "http://nodeload.github.com/sakaiproject/solr/tarball/master",
                    $solr_home_tarball = "http://dl.dropbox.com/u/24606888/puppet-oae-files/home0.tgz",
                    $solrconfig        = 'oae/solrconfig.xml.erb',
                    $schema            = 'oae/schema.xml.erb',
                    $master_url        = 'set the master url' ) {

    class { 'oae::solr::common':
        solr_tarball      => $solr_git,
        solr_home_tarball => $solr_home_tarball,
        solrconfig => $solrconfig,
        schema => $schema,
        master_url => $master_url,
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
        enable => true,
        subscribe => [ 
            File["${solr_conf_dir}/solrconfig.xml"], 
            File["${solr_conf_dir}/schema.xml"], 
        ],
        
    }
}

