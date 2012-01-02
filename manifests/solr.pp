# = Class: users
#
# This class installs a solr master or slave for Sakai OAE
#
# == Parameters:
#
# $solr_tarball::   A URL to a tarball of the solr build.
#
# $solrconfig::     A template to render the solrconfig.xml file.
#
# $schema::         A template to render the schema.xml file.
#
# == Actions:
#   Install a solr server.
#
# == Sample Usage:
# 
#   class {'solr':
#     $solr_tarball = "http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
#     $solrconfig   = 'myconfig/solrconfig.xml.erb',
#     $schema       = 'myconfig/schema.xml.erb',
#   }
#

class oae::solr($solr_tarball = "http://source.sakaiproject.org/release/oae/solr/solr-example.tar.gz",
                $solrconfig   = 'oae/solrconfig.xml.erb', 
                $schema       = 'oae/schema.xml.erb') {

    realize(Group[$oae::params::user])
    realize(User[$oae::params::user])

    # Home for standalone solr servers
    $solr_basedir = "${oae::params::basedir}/solr"

    # Solr installation
    $solr_app    = "${solr_basedir}/solr-app"

    # Solr node config
    $solr_conf_dir   = "${solr_app}/conf"

    file { $solr_basedir:
        ensure => directory,
        owner => $oae::params::user,
        group => $oae::params::user,
        mode  => 0755,
    }

    exec { 'download-solr':
        command => "curl -o ${solr_basedir}/solr.tgz  $solr_tarball",
        creates => "${solr_basedir}/solr.tgz",
        require => File[$basedir],
    }

    exec { 'unpack-solr':
        command => "tar xzvf ${solr_basedir}/solr.tgz -C ${solr_basedir}",
        creates => "${solr_basedir}/example",
        require => Exec['download-solr'],
    }

    exec { 'chown-solr':
        command => "chown -R ${$oae::params::user}:${$oae::params::group} ${solr_basedir}/example",
        unless  => "[ `stat --printf='%U'  ${solr_basedir}/example` == '${$oae::params::user}' ]",
        require => Exec['unpack-solr'],
    }

    exec { 'copy-solr-app':
        command => "cp -a ${solr_basedir}/example ${solr_app}",
        creates => "${solr_app}",
        require => Exec['chown-solr'],
    }

    file { $solr_conf_dir:
        ensure => directory,
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => 755,
        require => Exec['copy-solr-app'],
    }
    
    file { "${solr_conf_dir}/solrconfig.xml":
        owner   => $oae::params::user,
        group   => $oae::params::user,
        mode    => "0644",
        content => template($solrconfig),
        require => File[$solr_conf_dir],
        notify  => Service['solr'],
    }

    file { "${solr_conf_dir}/schema.xml":
        owner  => $oae::params::user,
        group  => $oae::params::user,
        mode   => "0644",
        content => template($schema),
        notify => Service['solr'],
        require => File[$solr_conf_dir],
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
        require => File["${solr_conf}/solrconfig.xml"],
        require => File["${solr_conf}/schema.xml"],
    }
}
