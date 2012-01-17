class oae::solr::tomcat (
                    $tomcat_user,
                    $tomcat_group,
                    $webapp_url            = 'http://dl.dropbox.com/u/24606888/puppet-oae-files/apache-solr-4.0-SNAPSHOT.war',
                    $solr_context_template = 'oae/solr-context.xml.erb'
                    ){
    Class['tomcat6'] -> Class['oae::solr::commmon'] -> Class['oae::solr::tomcat']

    exec { 'download-war':
        cwd => "${oae::params::basedir}/solr/",
        command => "curl -o solr.war http://dl.dropbox.com/u/24606888/puppet-oae-files/apache-solr-4.0-SNAPSHOT.war",
        creates => "${oae::params::basedir}/solr/solr.war",
    }

    file { "${oae::params::basedir}/solr/tomcat/conf/Catalina/localhost/solr.xml":
        owner => $tomcat_user,
        group => $tomcat_group,
        mode  => 0644,
        content => template($solr_context_template),
    }
}