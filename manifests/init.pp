################################################################################
# Class: wget
#
# This class will install wget - a tool used to download content from the web.
#
################################################################################
class wget {
	package { "wget": ensure => latest }
}

################################################################################
# Definition: wget::fetch
#
# This class will download files from the internet.  You may define a web proxy
# using $http_proxy if necessary.
#
################################################################################
define wget::fetch($source,$destination) {

	# using "unless" with /usr/bin/test instead of "creates" to re-attempt download
	# on empty files.
	# wget creates an empty file when a download fails, and then it wouldn't try
	# again to download the file
	if $http_proxy {
		exec { "wget-$name":
			command => "/usr/bin/wget --output-document=$destination $source",
			unless => "/usr/bin/test -s $destination",
			environment => [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy" ],
		}
	} else {
		exec { "wget-$name":
			command => "/usr/bin/wget --output-document=$destination $source",
			unless => "/usr/bin/test -s $destination",
		}
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
define wget::authfetch($source,$destination,$user,$timeout="0") {
	if $http_proxy {
		exec { "wget-$name":
			command => "/usr/bin/wget --user=$user --output-document=$destination $source",
			timeout => "$timeout",
			unless => "/usr/bin/test -s $destination",
			environment => [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy" ],
		}
	} else {
		exec { "wget-$name":
			command => "/usr/bin/wget --user=$user --output-document=$destination $source",
			timeout => "$timeout",
			unless => "/usr/bin/test -s $destination",
		}
	}
}

