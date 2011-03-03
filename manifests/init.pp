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
	if $http_proxy {
		exec { "wget-$name":
			command => "/usr/bin/wget --output-document=$destination $source",
			creates => "$destination",
			environment => [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy" ],
		}
        } else {
		exec { "wget-$name":
			command => "/usr/bin/wget --output-document=$destination $source",
			creates => "$destination",
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
			creates => "$destination",
			environment => [ "HTTP_PROXY=$http_proxy", "http_proxy=$http_proxy" ],
		}
  } else {
		exec { "wget-$name":
			command => "/usr/bin/wget --user=$user --output-document=$destination $source",
      timeout => "$timeout",
			creates => "$destination",
		}
	}
}

