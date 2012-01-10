# = Class: oae::solr::common
#
# This class installs a standalone solr master or slave for Sakai OAE
#
# == Parameters:
#
# $solr_home_tarball:: A URL to a tarball of the solr home build.
#
# $solrconfig::   A template to render the solrconfig.xml file.
#
# $schema::       A template to render the schema.xml file.
#
# $solr_git::     The url for the solr git repository
#
# $solr_tag::     The tag to checkout (optional)
#
# $master_url::   The master url for solr clustering (necessary for slave configurations)
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
class oae::solr::common (
                $solr_git          = "http://github.com/sakaiproject/solr.git",
                $solr_tag          = "",
                $solr_home_tarball = "http://dl.dropbox.com/u/24606888/puppet-oae-files/home0.tgz",
                $solrconfig        = 'oae/solrconfig.xml.erb', 
                $schema            = 'oae/schema.xml.erb',
                $master_url) {

    # Home for standalone solr servers
    $solr_basedir = "${oae::params::basedir}/solr"

    # Solr installation
    $solr_home    = "${solr_basedir}/home0"

    # Solr node config
    $solr_confdir   = "${solr_home}/conf"
    
    file { $solr_basedir:
        ensure => directory,
        owner => $oae::params::user,
        group => $oae::params::user,
        mode  => 0755,
    }

    exec { 'download-solr-home':
        command => "curl -o ${solr_basedir}/home0.tgz ${solr_home_tarball}",
        creates => "${solr_basedir}/home0.tgz",
    }

    exec { 'unpack-solr-home':
        command => "tar xzvf ${solr_basedir}/home0.tgz -C ${solr_basedir}",
        creates => $solr_home,
        requires => Exec['download-solr-home'],
    }

    exec { 'chown-solr-home':
        command => "chown -R ${oae::params::user}:${oae::params::group} ${solr_basedir}/home0",
        unless  => "[ `stat --printf='%U'  ${solr_basedir}/home0` == '${$oae::params::user}' ]",
        requires => Exec['unpack-solr-home'],
    }

    exec { 'clone-solr':
       command => "git clone ${solr_git} ${solr_basedir}/solr-git",
       creates => "${$solr_basedir}/solr-git",
       require => File[$solr_basedir],
    }

   if $solr_tag != undef and $solr_tag != "" {
       exec { 'switch-solr-tag':
           cwd     => "${solr_basedir}/solr-git",
           command => "git checkout origin/$solr_tag",
       }
   }

   # Copy stopwords.txt and synonmns.txt and the like from the Sakai solr repository
   exec { 'copy-solr-resources':
       command => "cp ${solr_basedir}/solr-git/src/main/resources/*.txt ${solr_confdir}",
       creates => "${solr_confdir}/stopwords.txt",
       require => [ Exec['clone-solr'], File[$solr_confdir], ],
   }

   file { "${solr_confdir}/solrconfig.xml":
       owner   => $oae::params::user,
       group   => $oae::params::user,
       mode    => "0644",
       content => template($solrconfig),
       require => File[$solr_confdir],
   }

   file { "${solr_confdir}/schema.xml":
       owner  => $oae::params::user,
       group  => $oae::params::user,
       mode   => "0644",
       content => template($schema),
       require => File[$solr_confdir],
   }
}