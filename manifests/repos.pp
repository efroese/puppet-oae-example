class postgres::repos {
    
    $release = $operatingsystem ? {
        CentOS,RedHat => $lsbmajdistrelease,
        Amazon,Linux => '6'
    }

	yumrepo { "postgresql-9.1-RHEL-${release}-${architecture}":
        name     =>  "postgresql-9.1-RHEL-${release}-${architecture}",
        baseurl  => "http://yum.postgresql.org/9.1/redhat/rhel-${release}-${architecture}",
        enabled  => '1',
        gpgcheck => '0',
    }
}
