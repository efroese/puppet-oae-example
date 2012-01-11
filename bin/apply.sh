#!/bin/bash
#
# apply.sh - Erik Froese <erik@hallwaytech.com>
#
# Run puppet with the correct module path.
#
# For more info pass the --debug or --verbose flags.
#
puppet apply --modulepath modules site.pp $@
