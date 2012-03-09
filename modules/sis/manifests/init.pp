#
# = Class sis
# Base class for SIS integrations
#
#
class sis {
    
    $basedir = "${localconfig::homedir}/sis/"
    
    file { $basedir:
        ensure => directory,
    }
}