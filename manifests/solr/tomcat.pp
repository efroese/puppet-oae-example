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