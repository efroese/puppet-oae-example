class munin::repos {
    
  $release = $operatingsystem ? {
      /CentOS|RedHat/ => $lsbmajdistrelease,
      /Amazon|Linux/ => '6'
  }

	yumrepo { "dag":
    name     =>  "dag",
    baseurl  => "http://apt.sw.be/redhat/el${release}/en/${architecture}/dag",
    enabled  => '1',
    gpgcheck => '0',
  }
  
  file { "/etc/yum.repos.d/dag.repo":
    ensure  => present,
    mode    => 0644,
    owner   => "root",
    require => Yumrepo["dag"]
  }
}