# = Class: oae::solr::common
#
# This class installs a standalone solr master or slave for Sakai OAE
#
# == Parameters:
#
# $solr_tarball:: The url for the solr tarball.
#
# $solr_home_tarball:: A URL to a tarball of the solr home skeleton.
#
# $solrconfig::   A template to render the solrconfig.xml file.
#
# $schema::       A template to render the schema.xml file.
#
# $master_url::   The master url for solr clustering (necessary for slave configurations)
#
# == Actions:
#   Install a solr home directory and configuration files.
#
# == Sample Usage:
# 
#   class { 'oae::solr::jetty':
#     solr_tarball => "http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
#     solrconfig   => 'localconfig/solrconfig.xml.erb',
#     schema       => 'localconfig/schema.xml.erb',
#   }
#
class oae::solr::common (
                $solr_tarball      = 'http://nodeload.github.com/sakaiproject/solr/tarball/master',
                $solr_home_tarball = "http://dl.dropbox.com/u/24606888/puppet-oae-files/home0.tgz",
                $solrconfig        = 'oae/solrconfig.xml.erb', 
                $schema            = 'oae/schema.xml.erb',
                $master_url        = 'set the master url') {

    # Home for standalone solr servers
    $solr_basedir = "${oae::params::basedir}/solr"

    # Solr installation
    $solr_home    = "${solr_basedir}/home0"

    # Solr node config
    $solr_confdir   = "${solr_home}/conf"
    
    # /usr/local/sakaioae/solr
    file { $solr_basedir:
        ensure => directory,
        owner => $oae::params::user,
        group => $oae::params::user,
        mode  => 0755,
    }

    # /usr/local/sakaioae/solr/home0
    archive { 'home0':
        ensure   => present,
        url      => $solr_home_tarball,
        target   => $solr_basedir,
        checksum => false,
        src_target => $solr_basedir,
        extension => 'tgz',
        require    => File[$solr_basedir],
    }

    # /usr/local/sakaioae/solr/home0/conf
    file { $solr_confdir:
        ensure => directory,
        owner => $oae::params::user,
        group => $oae::params::user,
        mode  => 0755,
        require => Archive['home0'],
    }

    exec { 'chown-solr-home':
        command => "chown -R ${oae::params::user}:${oae::params::group} ${solr_basedir}/home0",
        unless  => "[ `stat --printf='%U'  ${solr_basedir}/home0` == '${$oae::params::user}' ]",
        require =>  Archive['home0'],
    }

    # /usr/local/sakaioae/solr/solr-source
    archive { 'solr-source':
        ensure     => present,
        url        => $solr_tarball,
        target     => $solr_basedir,
        checksum   => false,
        src_target => $solr_basedir,
        require    => File[$solr_basedir],
    }

    # The expanded folder name will be ${organization}-${repository}-${revision}
    exec { 'mv-solr-source':
        command => "mv `tar tf ${solr_basedir}/solr-source.tar.gz | head -1` solr-source",
        cwd     => $solr_basedir,
        require => Archive['solr-source'],
    }

    # /usr/local/sakaioae/solr/home0/conf/{stopwords,synonyms,protwords,...}.txt
    exec { 'copy-solr-resources':
        command => "cp ${solr_basedir}/solr-source/src/main/resources/*.txt ${solr_confdir}",
        creates => "${solr_confdir}/stopwords.txt",
        require => [ Exec['mv-solr-source'], File[$solr_confdir], ],
    }

   # /usr/local/sakaioae/solr/home0/conf/schema.xml
   exec { 'copy-solr-schema':
       command => "cp ${solr_basedir}/solr-source/src/main/resources/schema.xml ${solr_confdir}",
       creates => "${solr_confdir}/schema.xml",
       require => [ Exec['mv-solr-source'], File[$solr_confdir], ],
   }

   # /usr/local/sakaioae/solr/home0/conf/solrconfig.xml
   file { "${solr_confdir}/solrconfig.xml":
       owner   => $oae::params::user,
       group   => $oae::params::user,
       mode    => "0644",
       content => template($solrconfig),
       require => File[$solr_confdir],
   }
}
