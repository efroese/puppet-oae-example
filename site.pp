import 'manifests/*'
import 'nodetypes'

# Standalone OAE server example
# import 'nodes-standlone'

# OAE cluster example
import 'nodes-cluster'

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
