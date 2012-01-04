import 'manifests/*'
import 'nodetypes'
import 'nodes'

# Set the default path for exec resources
Exec { path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin' }

# set up a run stage that executes before main
stage { 'init': before => Stage['main'] }