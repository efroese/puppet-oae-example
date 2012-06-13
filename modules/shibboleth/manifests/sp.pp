/*

= Class: shibboleth::sp

Installs shibboleth's service provider, and allow it's apache module get loaded
with apache::module.

== Parameters
$shibboleth2_xml_template:: the template path for your shibboleth2.xml.erb (optional)
$attribute_map_xml_template:: the template path for your attribute-map.xml.erb (optional)
$sp_cert:: the path to your sp-cert.pem (optional)
$sp_key:: the path to your sp-key.pem (optional)

== Requires:
- Class[apache]

== Limitations:
- currently RedHat/CentOS only.

*/
class shibboleth::sp (
    $shibboleth2_xml_template=undef,
    $attribute_map_xml_template=undef,
    $sp_cert=undef,
    $sp_key=undef
    ) {

  $release = $operatingsystem ? {
    /CentOS|RedHat/ => $lsbmajdistrelease,
    /Amazon|Linux/ => '6'
  }

  yumrepo { "security_shibboleth":
    descr    => "Shibboleth-RHEL_${release}",
    baseurl  => "http://download.opensuse.org/repositories/security://shibboleth/RHEL_${release}",
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
    enabled  => 1,
    gpgcheck => 1,
    require  => Exec["download shibboleth repo key"],
  }

  # ensure file is managed in case we want to purge /etc/yum.repos.d/
  # http://projects.puppetlabs.com/issues/3152
  file { "/etc/yum.repos.d/security_shibboleth.repo":
    ensure  => present,
    mode    => 0644,
    owner   => "root",
    require => Yumrepo["security_shibboleth"],
  }

  exec { "download shibboleth repo key":
    command => "curl -s http://download.opensuse.org/repositories/security:/shibboleth/RHEL_${release}/repodata/repomd.xml.key -o /etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
    creates => "/etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
  }

  package { "shibboleth":
    ensure  => "present",
    name    => "shibboleth.${architecture}",
    require => Yumrepo["security_shibboleth"],
  }

  $shibpath = $architecture ? {
    x86_64 => "/usr/lib64/shibboleth/mod_shib_22.so",
    i386   => "/usr/lib/shibboleth/mod_shib_22.so",
  }

  file { "/etc/httpd/mods-available/shib.load":
    ensure  => present,
    content => "# file managed by puppet\nLoadModule mod_shib ${shibpath}\n",
  }

  file { "/etc/httpd/conf.d/shib.conf":
    ensure  => absent,
    require => Package["shibboleth"],
    notify  => Service["apache"],
  }

  if $shibboleth2_xml_template != undef {
    file { "/etc/shibboleth/shibboleth2.xml":
      ensure  => present,
      mode    => 0644,
      require => Package["shibboleth"],
      notify  => Service["apache"],
      content => template($shibboleth2_xml_template),
    }
  }
  if $attribute_map_xml_template != undef {
    file { "/etc/shibboleth/attribute-map.xml":
      ensure  => present,
      mode    => 0644,
      require => Package["shibboleth"],
      notify  => Service["apache"],
      content => template($attribute_map_xml_template),
    }
  }
  
  if $sp_cert_template != undef {
    file { "/etc/shibboleth/sp-cert.pem":
      ensure  => present,
      mode    => 0644,
      require => Package["shibboleth"],
      notify  => Service["apache"],
      content => sp_cert,
    }
  }
  
  if $sp_key_template != undef {
    file { "/etc/shibboleth/sp-key.pem":
      ensure  => present,
      mode    => 0600,
      require => Package["shibboleth"],
      notify  => Service["apache"],
      source  => $sp_key,
    }
  }

# TODO
##
## Used for example logo and style sheet in error templates.
##
#<IfModule mod_alias.c>
#  <Location /shibboleth-sp>
#    Allow from all
#  </Location>
#  Alias /shibboleth-sp/main.css /usr/share/doc/shibboleth/main.css
#  Alias /shibboleth-sp/logo.jpg /usr/share/doc/shibboleth/logo.jpg
#</IfModule>

}
