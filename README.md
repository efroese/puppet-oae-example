A puppet module to help install Sakai CLE servers.

This module requires http://github.com/efroese/puppet-tomcat6

Example:


    node 'cle1.localdomain' {
        class { 'tomcat6':
            parentdir => "/usr/local/sakaicle",
            tomcat_version => '5.5.33',
            tomcat_major_version => '5',
            tomcat_user  => 'tomcat',
            tomcat_group => 'tomcat',
            tomcat_conf_template => 'localconfig/cle-server.xml.erb',
        }

        class { 'cle':
            cle_tarball_url => 'http://this.is.where/my/cle/tarball.tbz,
            user            => 'tomcat',
            basedir         => "/usr/local/sakaicle/sakaicle",
            tomcat_home     => "/usr/local/sakaicle/sakaicle/tomcat",
            server_id       => 'cle1,
            sakai_properties_template    => 'localconfig/sakai.properties.erb',
            local_properties_template    => 'localconfig/local.properties.erb',
        }
    }