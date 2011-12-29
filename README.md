## Description
This is a set of puppet scripts to stand up an OAE cluster.

The OAE module itself is available at https://github.com/efroese/puppet.oae.git.

The required modules are included as git submodules.

Most of them are from http://github.com/camptocamp.
I've forked some of them into http://github.com/efroese 

## Usage
    git clone git://github.com/efroese/puppet-oae-example.git
    cd puppet-oae-example
    git submodule update --init
    puppet apply --modulepath modules site.pp --verbose
