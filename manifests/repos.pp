class postgres::repos {
    
    $release = $operatingsystem ? {
        /CentOS|RedHat/ => $lsbmajdistrelease,
        /Amazon/ => '6'
    }

	yumrepo { "PostgreSQL 9.1 6 - ${architecture}":
        name     =>  "PostgreSQL 9.1 RHEL - ${release} - ${architecture}",
        baseurl  => "http://yum.postgresql.org/9.1/redhat/rhel-${release}-${architecture}",
        enabled  => '1',
        gpgcheck => '0',
    }
}