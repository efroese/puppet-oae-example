/*

== Class: shibboleth::administration

Creates a "shibboleth-admin" group and use sudo to allows members of this group
to:
- restart shibd service.

Requires:
- definition sudo::directive from module camptocamp/puppet-sudo

Warning: will overwrite /etc/sudoers !

*/
class shibboleth::administration {

  group { "shibboleth-admin":
    ensure => present,
  }

  sudo::directive { "shibboleth-administration":
    ensure  => present,
    content => "# file managed by puppet (${name})
User_Alias SHIBBOLETH_ADMIN = %shibboleth-admin
Cmnd_Alias SHIBBOLETH_ADMIN = /etc/init.d/shibd
SHIBBOLETH_ADMIN ALL=(root) SHIBBOLETH_ADMIN
",
    require => Group["shibboleth-admin"],
  }

}
