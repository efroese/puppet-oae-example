# = Class: cle
#
# Configure a CLE tomcat instance.
# To actually install CLE into tomcat you should create a tarball that unpacks cleanly
# over your tomcat instance and use the tomcat::overlay define.
#
# == Requires:
#
# Module['tomcat6']
#
# == Parameters:
#
# $basedir:: Everything gets installed below this directory.
#
# $user:: The user CLE will run as. It will also own the CLE files.
#
# $server_id:: The CLE server_id
#
# $db_url:: The CLE database url.
#
# $db_user:: The database user CLE will run connect as.
#
# $db_password:: The database password CLE will run connect with.
#
# $configuration_xml_template:: Template used to render sakai/sakai-configuration.xml
#
# $sakai_properties_template:: The path to the template used to render sakai/sakai.properties (optional)
#
# $local_properties_template:: The path to the template used to render sakai/local.properties (optional)
#
# $instance_properties_template:: The path to the template used to render sakai/instance.properties (optional)
#
# $linktool_salt:: The salt for the sakai rutgers linktool
#
# $linktool_privkey:: The private key for the sakai rutgers linktool
#
# == Example Usage:
#
# class { 'cle':
#     cle_tarball_url => 'http://my.org/sakai/cle/releases/2-8-x.tbz,
#     user => 'sakaicle',
# }
#
# class { 'cle':
#     user => 'sakaicle',
#     server_id => 'cle0',
#     db_url    => 'jdbc:mysql://loclahost:3306/cle?someparam=1
#     db_user   => 'cle',
#     db_passwrd => 'SeeEllEeee',
# }
#
class cle (
    $basedir                      = "/usr/local/sakaicle",
    $tomcat_home                  = "/usr/local/sakaicle/tomcat",
    $user                         = "sakaioae",
    $server_id                    = 'cle1',
    $db_url                       = 'configure the cle::db_url',
    $db_user                      = 'configure the cle::db_user',
    $db_password                  = 'configure the cle::db_password',
    $configuration_xml_template   = undef,
    $sakai_properties_template    = undef,
    $local_properties_template    = undef,
    $instance_properties_template = undef,
    $linktool_salt                = undef,
    $linktool_privkey             = undef
    ){

    if !defined(File[$basedir]) {
        file { $basedir:
            ensure => directory,
            owner  => $user,
        }
    }

    # /usr/local/sakaicle/sakai/
    $sakaidir = "${basedir}/sakai"
    file { $sakaidir:
        ensure => directory,
        owner  => $user,
    }

    file { '/etc/profile.d/sakaicle.sh':
        mode => 0755,
        content => "export CLE_HOME=${basedir}",
    }

    # /usr/local/sakaicle/tomcat/sakai -> /usr/local/sakaicle/sakai
    file { "${tomcat_home}/sakai":
        ensure  => link,
        target  => $sakaidir,
    }

    if $configuration_xml_template != undef {
        file { "${sakaidir}/sakai-configuration.xml":
            owner => $user,
            group => $user,
            mode  => 0644,
            content => template($configuration_xml_template),
            require => File[$sakaidir],
            notify  => Service['tomcat'],
        }
    }

    file { "${sakaidir}/sakai.properties":
        owner => $user,
        group => $user,
        mode  => 0644,
        content => template($sakai_properties_template),
        require => File[$sakaidir],
        notify  => Service['tomcat'],
    }

    if $local_properties_template != undef {
        file { "${sakaidir}/local.properties":
            owner => $user,
            group => $user,
            mode  => 0644,
            content => $local_properties_template ? {
                undef   => '# managed by puppet. \$local_properties_template not specified',
                default => template($local_properties_template),
            },
            require => File[$sakaidir],
            notify  => Service['tomcat'],
        }
    }

    if $instance_properties_template != undef {
        file { "${sakaidir}/instance.properties":
            owner => $user,
            group => $user,
            mode  => 0644,
            content => $instance_properties_template ? {
                undef   => '# managed by puppet. \$instance_properties_template not specified',
                default => template($instance_properties_template),
            },
            require => File[$sakaidir],
            notify  => Service['tomcat'],
        }
    }

    if $linktool_privkey != undef {
        file { "${sakaidir}/sakai.rutgers.linktool.privkey":
            owner => $user,
            group => $user,
            mode  => 0644,
            content => $linktool_privkey,
            require => File[$sakaidir],
            notify  => Service['tomcat'],
        }
    }

    if $linktool_salt != undef {
        file { "${sakaidir}/sakai.rutgers.linktool.salt":
            owner => $user,
            group => $user,
            mode  => 0644,
            content => $linktool_salt,
            require => File[$sakaidir],
            notify  => Service['tomcat'],
        }
    }
}