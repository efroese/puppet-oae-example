################################################################################
# Class: wget
#
# This class will install wget - a tool used to download content from the web.
#
################################################################################
class wget {
	package { "wget": ensure => installed }
}

################################################################################
# Definition: wget::fetch
#
# This class will download files from the internet.  You may define a web proxy
# using $http_proxy if necessary.
#
################################################################################
define wget::fetch($source,$destination,$timeout="0") {

	# using "unless" with test instead of "creates" to re-attempt download
	# on empty files.
	# wget creates an empty file when a download fails, and then it wouldn't try
	# again to download the file
	if $http_proxy {
		$environment = [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy" ]
	}
	else {
		$environment = []
	}
	exec { "wget-$name":
		command => "wget --output-document=$destination $source",
		timeout => $timeout,
		unless => "test -s $destination",
		environment => $environment,
		path => "/usr/bin:/usr/sbin:/bin",
		require => Package[wget],
	}
}

################################################################################
# Definition: wget::authfetch
#
# This class will download files from the internet.  You may define a web proxy
# using $http_proxy if necessary. Username must be provided. And the user's
# password must be stored in the password variable within the .wgetrc file.
#
################################################################################
define wget::authfetch($source,$destination,$user,$password="",$timeout="0") {
	if $http_proxy {
		$environment = [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy", "WGETRC=/tmp/wgetrc-$name" ]
	}
	else {
		$environment = [ "WGETRC=/tmp/wgetrc-$name" ]
	}
	file { "/tmp/wgetrc-$name":
		owner => root,
		mode => 600,
		content => "password=$password",
	} ->
	exec { "wget-$name":
		command => "wget --user=$user --output-document=$destination $source",
		timeout => $timeout,
		unless => "test -s $destination",
		environment => $environment,
		path => "/usr/bin:/usr/sbin:/bin",
		require => Package[wget],
	}
}

