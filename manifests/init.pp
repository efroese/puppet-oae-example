# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# = Class: postgres
#
# Manage postgres roles
#
# == Parameters:
#
# $postgresql_conf_template:: The template for postgresql.conf
#
# $hba_conf_template:: The template for pg_hba.conf
#
# == Actions:
#   Install a Postgres server and service.
#
class postgres (
        $postgresql_conf_template='postgres/postgresql.conf.erb',
        $hba_conf_template = ''
    ){

    if !defined(Class['Postgres::Base']) {
        class { 'postgres::base': }
    }

	package { 'postgresql91-server': ensure => installed }

	$service_name = 'postgresql-9.1'

    service { $service_name:
        ensure => running,
        enable => true,
        hasstatus => true,
        require   =>  Exec['postgres initdb'],
    }

	exec { 'postgres initdb':
		command => "service ${service_name} initdb",
		creates => "/var/lib/pgsql/9.1/data/PG_VERSION",
	}

    file { "/var/lib/pgsql/9.1/data/postgresql.conf":
        owner => 'postgres',
        group => 'postgres',
        mode  => 0600,
        content => template($postgresql_conf_template),
        notify  => Service[$service_name],
        require => [ Exec['postgres initdb'], Package['postgresql91-server'] ],
    }

    if $hba_conf_template != '' {
        file { "/var/lib/pgsql/9.1/data/pg_hba.conf":
            owner => 'postgres',
            group => 'postgres',
            mode  => 0600,
            content => template($hba_conf_template),
            notify  => Service[$service_name],
            require => [ Exec['postgres initdb'], Package['postgresql91-server'] ],
        }
    }
}
