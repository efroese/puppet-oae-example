import 'manifests/*'
import 'nodetypes'

#
# Dynamically import the nodes list based on the active configuration.
# Activate the correct configuration by making a symlink in the modules directory to the right config module.
# 
import 'localconfig/manifests/nodes.pp'

# Set the default path for exec resources
Exec { path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin' }

#
# Set up a run stage that executes before main
# This is useful for creating yum repositories, users, important base system packages...
#
# Usage:
#     class { 'someclass': stage => 'init', other_arg => 'other_val' }
#
stage { 'init': before => Stage['main'] }
