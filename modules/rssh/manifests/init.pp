class rssh() {
    
    package { 'rssh': ensure => installed }

    file { "/etc/rssh.conf":
        owner   => root,
        group   => root,
        mode    => 0440,
        source  => 'puppet:///modules/rssh/rssh.conf'
    }
}
