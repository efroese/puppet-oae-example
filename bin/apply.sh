#!/bin/bash
#
# apply.sh - Erik Froese <erik@hallwaytech.com>
#
# This is a convenience script to call puppet on a node with no puppet master.
# The puppet-oae-example project is intended to work in an environment with no
# puppetmaster server. It hasn't been tested with a puppet master.
# 
# In order to enable a specific configuration use the --environment parameter.
# Available environments are listed in the puppet-oae-example/environments/ folder.
#
# If you want to automatically specify the environment put the name in
# puppet-oae-example/.environment
#
# For more info pass the --debug or --verbose flags.
#

. /etc/profile.d/puppet.sh

ENV_FILE=`pwd`/.environment
ENV_ARG=""

echo $@ | grep -q environment
if [[ $? -eq 1 && -f $ENV_FILE ]]; then
    echo "environment = `cat ${ENV_FILE}`"
    ENV_ARG="--environment `cat ${ENV_FILE}`"
fi

# Look up modules in:
# 1. environments/$environment/modules/
# 2. modules/
puppet apply --modulepath environments/\$environment/modules:modules site.pp $ENV_ARG $@
