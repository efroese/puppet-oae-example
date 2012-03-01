#!/bin/bash

# pull.sh
#
# Update the git repository and its submodules.
# 
# Erik Froese <erik@hallwaytech.com>
#
git pull
git submodule sync
git submodule update --init
