#!/bin/bash

puppet apply --modulepath modules site.pp --verbose --debug $@
