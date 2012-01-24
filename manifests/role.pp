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

# = Class: postgres::role
#
# Manage postgres roles
#
# == Parameters:
#
# $ensure::
#
# $password::   The password for the role
#
# $superuser::  Is this user a superuser?
#
# $createdb::   Can this user create databases.
#
# $createrole:: Can this user create roles.
#
# $login::      Can this role log in
#
# $inherit::    Role inherits privileges of roles it is a member of
#
# $encrypt::    Encrypt stored password
#
# == Actions:
#   Install or remove a Postgres role.
#
define postgres::role(  $ensure,
                        $password='',
                        $superuser=false,
                        $createdb=false,
                        $createrole=false,
                        $login=false,
                        $inherit=false,
                        $connection_limit=false,
                        $encrypt=false
                        ) {
    $passtext = $password ? {
        false   => "",
        default => "LOGIN PASSWORD '${password}'"
    }

    $superuser_opt = $superuser ? {
        false   => "--no-superuser",
        default => "--superuser"
    }

    $createdb_opt = $superuser ? {
        false   => "--no-createdb",
        default => "--createdb"
    }

    $createrole_opt = $createrole ? {
        false   => "--no-createrole",
        default => "--createrole"
    }

    $login_opt = $login ? {
        false   => "--no-login",
        default => "--login"
    }

    $inherit_opt = $inherit ? {
        false   => "--no-inherit",
        default => "--inherit"
    }

    $connection_limit_opt = $connection_limit ? {
        false   => "",
        default => "--connection_limit ${connection_limit}",
    }

    $encrypt_opt = $encrypt ? {
        false   => "-N",
        default => "-E",
    }

    case $ensure {
        present: {
            # The createuser command always prompts for the password.
            exec { "Create $name postgres role":
                command => "/usr/bin/createuser ${superuser_opt} ${createdb_opt} ${createrole_opt} ${inherit_opt} ${connection_limit_opt} ${encrypt_opt} ${name}",
                user    => 'postgres',
                unless  => "/usr/bin/psql -c '\\du' | grep '^  *${name}  *|'",
                notify  => Exec["pg-set-password-${name}"],
            }

            exec { "pg-set-password-${name}":
                command     => "/usr/bin/psql -c \"ALTER ROLE ${name} WITH PASSWORD '${password}' \"",
                user        => 'postgres',
                refreshonly => true,
            }
        }
        absent:  {
            exec { "Remove $name postgres role":
                command => "/usr/bin/dropuser ${name}",
                user    => "postgres",
                onlyif  => "/usr/bin/psql -c '\\du' | grep '${name}  *|'"
            }
        }
        default: {
            fail "Invalid 'ensure' value '${ensure}' for postgres::role"
        }
    }
}
