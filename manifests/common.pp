# = Class: solr::common
#
# This class installs a standalone solr master or slave
#
# == Parameters:
#
# $user:: The user that will own solr files
# 
# $group:: The group solr will own solr files
#
# $solr_tarball:: The url for the solr tarball.
#
# $solr_home_tarball:: A URL to a tarball of the solr home skeleton.
#
# $solrconfig::   A template to render the solrconfig.xml file.
#
# $master_url::   The master url for solr clustering (necessary for slave configurations)
#
# == Actions:
#   Install a solr home directory and configuration files.
#
# == Sample Usage:
# 
#   class { 'solr::jetty':
#     solr_tarball => "http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
#     solrconfig   => 'localconfig/solrconfig.xml.erb',
#   }
#
class solr::common (
    $basedir           = '/usr/local/solr',
    $user              = 'root',
    $group             = 'root',
    $solr_tarball      = 'http://nodeload.github.com/sakaiproject/solr/tarball/master',
    $solr_home_tarball = "http://dl.dropbox.com/u/24606888/puppet-oae-files/home0.tgz",
    $solrconfig        = 'solr/solrconfig.xml.erb', 
    $master_url        = 'set the master url') {

    # Solr installation
    $solr_home    = "${basedir}/home0"

    # Solr node config
    $solr_confdir   = "${solr_home}/conf"
    
    # /usr/local/solr
    file { $basedir:
        ensure => directory,
        owner => $user,
        group => $group,
        mode  => 0755,
    }

    # /usr/local/solr/home0
    archive { 'home0':
        ensure   => present,
        url      => $solr_home_tarball,
        target   => $basedir,
        checksum => false,
        src_target => $basedir,
        extension => 'tgz',
        allow_insecure => true,
        timeout        => '0',
        require    => File[$basedir],
    }

    # /usr/local/solr/home0/conf
    file { $solr_confdir:
        ensure => directory,
        owner => $user,
        group => $group,
        mode  => 0755,
        require => Archive['home0'],
    }

    exec { 'chown-solr-home':
        command => "chown -R ${user}:${group} ${basedir}/home0",
        unless  => "[ `stat --printf='%U'  ${basedir}/home0` == '${user}' ]",
        require =>  Archive['home0'],
    }

    # /usr/local/solr/solr-source
    archive { 'solr-source':
        ensure         => present,
        url            => $solr_tarball,
        checksum       => false,
        target         => $basedir,
        src_target     => $basedir,
        allow_insecure => true,
        timeout        => '0',
        require        => File[$basedir],
        notify         => Exec['mv-solr-source'],
    }

    # The expanded folder name will be ${organization}-${repository}-${revision}
    exec { 'mv-solr-source':
        command => "mv ${basedir}/`tar tf ${basedir}/solr-source.tar.gz 2>/dev/null | head -1` ${basedir}/solr-source",
        refreshonly => true,
    }

    # /usr/local/solr/home0/conf/{stopwords,synonyms,protwords,...}.txt
    exec { 'copy-solr-resources':
        command => "cp ${basedir}/solr-source/src/main/resources/*.txt ${solr_confdir}",
        creates => "${solr_confdir}/stopwords.txt",
        require => [ Exec['mv-solr-source'], File[$solr_confdir], ],
    }

   # /usr/local/solr/home0/conf/schema.xml
   file { "${solr_confdir}/schema.xml":
       source => "${basedir}/solr-source/src/main/resources/schema.xml",
       require => [ Exec['mv-solr-source'], File[$solr_confdir], ],
   }

   # /usr/local/solr/home0/conf/solrconfig.xml
   file { "${solr_confdir}/solrconfig.xml":
       owner   => $user,
       group   => $group,
       mode    => "0644",
       content => template($solrconfig),
       require => File[$solr_confdir],
   }
}
