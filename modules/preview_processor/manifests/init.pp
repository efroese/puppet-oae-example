class preview_processor {

    $processor_user = "sakai"
    realize(Group[$processor_user])
    realize(User[$processor_user])

    $ruby_bin="/usr/bin/ruby"
    $basedir="/home/$processor_user"
    $ppath = ""

    # Present in the base CentOS repositories
    $common_packages = ['cpp', 'gcc', 'fontconfig-devel', 'poppler-utils', 'rubygems']
    package { $common_packages: ensure => installed }

    # From rpmforge
    $docsplit_packages = ['pdftk']

    file { "$basedir/bin":
        ensure => directory,
        owner  => $processor_user,
        group  => $processor_user,
        mode   => 750,
    }

    # CentOS 5, RHEL 5
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '5') {
        # CentOS needs updated ImageMagick and Ruby packages
        $centos5_pkgs = ['curl-devel',]
        package { $centos5_pkgs: ensure => installed }
	$docsplit_packages = [ $docsplit_packages, 'tesseract']
        $ppath ="/opt/local/bin"

        package { "https://github.com/efroese/rpms/blob/master/RPMS/x86_64/ruby1.9.2p0-1.9.2p0-1.x86_64.rpm":
             ensure => installed,
             provider => 'rpm',
        }

        package { "https://github.com/efroese/rpms/raw/master/RPMS/x86_64/ImageMagick-6.4.9-10.x86_64.rpm":
             ensure => installed,
             provider => 'rpm',
        }
        
        package { "https://github.com/efroese/rpms/raw/master/RPMS/x86_64/ImageMagick-devel-6.4.9-10.x86_64.rpm":
             ensure => installed,
             provider => 'rpm',
        }
		
    } 

    # CentOS 6, RHEL 6, Fedora
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '6') {
        # Fedora can use the base packages.
        $centos6_pkgs = ['cronie', 'curlpp-devel', 'ImageMagick', 'ImageMagick-devel', 'ruby-devel']
        package { $centos6_pkgs: ensure => installed }
    }

    package { $docsplit_packages: ensure => installed }

    ###########################################################################
    # Drop the script for the cron job
    file { "$basedir/bin/run_preview_processor.sh":
        source => 'puppet:///modules/preview_processor/run_preview_processor.sh',
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    cron { 'run_preview_processor':
        command => "PATH=$ppath:$PATH $ppath $basedir/bin/run_preview_processor.sh",
        user => $processor_user,
        ensure => present,
        minute => '*',
    }
}
