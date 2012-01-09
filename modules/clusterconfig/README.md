Each Sakai OAE cluster will have its OWN localconfig module. That's where you configure the variables and keep cluster-specific files and templates.

This configuration module is used for the OAE cluster example. To use it you should create a symlink to it named localconfig.

    $ cd modules
    $ ln -s clusterconfig localconfig

THen make sure that ../../sites.pp includes cluster-nodes near the top.
