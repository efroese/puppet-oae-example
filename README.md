## Description

Puppet is a system configuration tool that enables dev/ops to create reusable system configuration scripts. This module is meant as a full-blown example of a puppet configuration for one or more machines.

There are two examples available. 
### Standlone
A standalone OAE server that also runs a MySQL database. This is similar to the OAE "bug bash" servers. See nodes-standalone.pp.

#### Usage
    git clone git://github.com/efroese/puppet-oae-example.git
    cd puppet-oae-example
    git submodule update --init
    # Edit site.pp to make sure nodes-standalone is imported.
    puppet apply --modulepath modules site.pp --verbose

### Cluster
A cluster of OAE machines. See nodes-cluster.pp for the cluster description.

#### Usage
    git clone git://github.com/efroese/puppet-oae-example.git
    cd puppet-oae-example
    git submodule update --init
    cd modules
    ln -s clusterconfig localconfig
    cd ..
    # Edit site.pp to make sure nodes-cluster is imported.
    puppet apply --modulepath modules site.pp --verbose

### Required Puppet Modules 
The OAE module itself is available at https://github.com/efroese/puppet-oae.git.
The required modules are included as git submodules in the modules/ directory.
Most of the modules are from http://github.com/camptocamp. I've forked some of them into http://github.com/efroese 
