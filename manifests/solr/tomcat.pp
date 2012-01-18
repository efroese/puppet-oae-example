# = Class: oae::solr::tomcat
#
# Install solr as a webapp in a tomcat container.
#
# == Parameters:
#
# $solr_git::     See oae::solr::common
#
# $solr_tag::     See oae::solr::common
#
# $solr_home_tarball:: A URL to a tarball of the solr home build.
#
# $solrconfig::   See oae::solr::common
#
# $schema::       See oae::solr::common
#
# $master_url::   See oae::solr::common
#
# $tomcat_user::  The user tomcat runs as.
#
# $tomcat_user::  The group tomcat runs as.
#
# $webapp_url::   The url where the solr webapp is (optional)
#
# $solr_context_template:: A template used to render the tomcat context xml file (optional)
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
class oae::solr::tomcat (
                    $solr_git          = "http://github.com/sakaiproject/solr.git",
                    $solr_tag          = "",
                    $solr_home_tarball = "http://dl.dropbox.com/u/24606888/puppet-oae-files/home0.tgz",
                    $solrconfig        = 'oae/solrconfig.xml.erb',
                    $schema            = 'oae/schema.xml.erb',
                    $master_url        = 'set the master url',
                    $tomcat_user,
                    $tomcat_group,
                    $webapp_url            = 'http://dl.dropbox.com/u/24606888/puppet-oae-files/apache-solr-4.0-SNAPSHOT.war',
                    $solr_context_template = 'oae/solr-context.xml.erb'){

    Class['Tomcat6'] -> Class['oae::solr::tomcat']

    class { 'oae::solr::common':
       solr_git => $solr_git,
       solr_tag => $solr_tag,
       solr_home_tarball => $solr_home_tarball,
       solrconfig => $solrconfig,
       schema => $schema,
       master_url => $master_url,
    }

    exec { 'download-war':
        cwd => "${oae::params::basedir}/solr/",
        command => "curl -o solr.war http://dl.dropbox.com/u/24606888/puppet-oae-files/apache-solr-4.0-SNAPSHOT.war",
        creates => "${oae::params::basedir}/solr/solr.war",
    }

    file { "${oae::params::basedir}/tomcat/conf/Catalina/localhost/solr.xml":
        owner => $tomcat_user,
        group => $tomcat_group,
        mode  => 0644,
        content => template($solr_context_template),
        require => Exec['download-war'],
    }
}