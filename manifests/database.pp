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

# = Class: postgres::database
#
# Manage postgres databases
#
# == Parameters:
#
# $ensure:: create or drop the database
#
# $owner:: The owner of the database (optional)
#
# == Actions:
#   Create or drop a postgres database
#
define postgres::database($ensure, $create_options = "", $owner = false) {
    $ownerstring = $owner ? {
        false => "",
        default => "WITH OWNER = ${owner}"
    }

    case $ensure {
        present: {
            exec { "Create $name postgres db":
                command => "/usr/bin/psql -c \"CREATE DATABASE ${name} ${ownerstring} ${create_options}\"",
                user => "postgres",
                unless => "/usr/bin/psql -l | grep '${name}  *|'",
            }
        }
        absent:  {
            exec { "Remove $name postgres db":
                command => "/usr/bin/psql -c \"DROP DATABASE ${name}\"",
                onlyif => "/usr/bin/psql -l | grep '${name}  *|'",
                user => "postgres",
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for postgres::database"
        }
    }
}
