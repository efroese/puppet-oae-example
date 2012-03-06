## Description

Puppet is a system configuration tool that enables dev/ops to create reusable system configuration scripts. This module is meant as a full-blown example of a puppet configuration for one or more machines.

There are three examples available. 
### Standlone
A full OAE installation on one machine. Apache, OAE, Postgres, and the preview processor.
See environments/standalone-demo/modules/localconfig

#### Usage
    git clone git://github.com/efroese/puppet-oae-example.git
    cd puppet-oae-example
    ./bin/pull.sh
    ./bin/apply.sh --environment standalone-demo --verbose

### Cluster
A cluster of OAE machines.
See environments/cluster-demo/modules/localconfig

#### Usage
    git clone git://github.com/efroese/puppet-oae-example.git
    cd puppet-oae-example
    cd puppet-oae-example
    ./bin/pull.sh
    ./bin/apply.sh --environment cluster-demo --verbose

#### BugBash
A standalone OAE server that also runs a MySQL database. This is similar to the OAE "bug bash" servers.
See environments/bugbash/modules/localconfig

#### Usage
    git clone git://github.com/efroese/puppet-oae-example.git
    cd puppet-oae-example
    cd puppet-oae-example
    ./bin/pull.sh
    ./bin/apply.sh --environment bugbash --verbose

### Required Puppet Modules 
The OAE module itself is available at https://github.com/efroese/puppet-oae.git.
The required modules are included as git submodules in the modules/ directory.
Most of the modules are from http://github.com/camptocamp. I've forked some of them into http://github.com/efroese 
