#!/bin/bash
#
# apply.sh - Erik Froese <erik@hallwaytech.com>
#
# Run puppet with the correct module path. Pass the --environment envname params.
#
# For more info pass the --debug or --verbose flags.
#

# Look up modules in:
# 1. environments/$environment/modules/
# 2. modules/
puppet apply --modulepath environments/\$environment/modules:modules site.pp $@
