#!/bin/bash
#
# apply.sh - Erik Froese <erik@hallwaytech.com>
#
# Run puppet with the correct module path.
#
# For more info pass the --debug or --verbose flags.
#
export RUBYOPT=rubygems
PUPPET=/usr/lib/ruby/gems/1.8/gems/puppet-2.7.9/bin/puppet
$PUPPET apply --modulepath modules site.pp $@
