# = Class: solr
#
# This class installs a standalone solr master or slave running in the Jetty servlet container.
#
# == Parameters:
#
# $solr_tarball:: See solr::common
#
# $solr_home_tarball:: See solr::common
#
# $solrconfig::   See solr::common
#
# $master_url::   See solr::common
#
# == Actions:
#   Install a solr server.
#
# == Sample Usage:
# 
#   class { 'solr::jetty':
#     solr_tarball => "http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
#     solrconfig   => 'myconfig/solrconfig.xml.erb',
#   }
#
class solr::jetty(
    $basedir           = '/usr/local/solr',
    $user              = 'root',
    $group             = 'root',
    $solr_tarball      = "http://nodeload.github.com/sakaiproject/solr/tarball/master",
    $solr_home_tarball = "http://dl.dropbox.com/u/24606888/puppet-oae-files/home0.tgz",
    $solrconfig        = 'solr/solrconfig.xml.erb',
    $master_url        = 'set the master url',
    $javagclog         = undef ) {

    # Make sure solr::common is executed BEFORE solr::jetty
    Class['solr::common'] -> Class['solr::jetty']

    # Lift heavy things
    class { 'solr::common':
        basedir           => basedir,
        user              => $user,
        group             => $group,
        solr_tarball      => $solr_git,
        solr_home_tarball => $solr_home_tarball,
        solrconfig        => $solrconfig,
        master_url        => $master_url,
    }

    # Drop the init script
    file { '/etc/init.d/solr':
        ensure => present,
        owner  => $user,
        group  => $group,
        mode   => 0755,
        content => template("solr/solr.erb"),
    }

    # And turn it on
    service { 'solr':
        ensure => running,
        enable => true,
        subscribe => File["${solr_conf_dir}/solrconfig.xml"], 
    }
}
