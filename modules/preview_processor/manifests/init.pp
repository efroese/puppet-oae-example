class preview_processor($oae_user="sakaioae", $basedir="/usr/local/sakaioae") {

    realize(Group[$oae_user])
    realize(User[$oae_user])

    $common_packages = ['cpp', 'gcc', 'fontconfig-devel', 'poppler-utils', 'pdftk', 'rubygems', 'tk']
    package { $common_packages: ensure => installed }

    file { "$basedir/bin":
        ensure => directory,
        owner  => $oae_user,
        group  => $oae_user,
        mode   => 750,
    }

    define upgrade_local_rpm() {
        file { "/tmp/$name":
            source => "puppet:///modules/preview_processor/$name.rpm",
            ensure => present,
            owner => root,
            group => root,
        }

        package { $name:
             name   => $name, 
             source => "/tmp/$name.rpm",
             ensure => latest,
             provider => 'rpm',
        }
    }

    # CentOS 5, RHEL 5
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '5') {
        # CentOS needs updated ImageMagick and Ruby packages
        $centos5_pkgs = ['curl-devel', 'tesseract', 'bzip2-devel', 'ghostscript-devel', 'jasper-devel',
			'lcms-devel', 'libX11-devel', 'libXext-devel', 'libXt-devel', 'libjpeg-devel', 
			'libtiff-devel', 'djvulibre', 'librsvg2', 'libwmf',]
        package { $centos5_pkgs: ensure => installed }

	$pkgs = ['ruby1.9.2p0-1.9.2p0-1.x86_64', 'ImageMagick-6.4.9-10.x86_64', 'ImageMagick-devel-6.4.9-10.x86_64']
        upgrade_local_rpm { $pkgs: }

        file { "/etc/ld.so.conf.d/optlocal.conf":
            owner => root, 
            group => root, 
            mode  => 750,
            content => '/opt/local/lib64',
            notify => Exec['ldconfig-ruby19'],
	}
        exec { 'ldconfig-ruby19':
            command => "/sbin/ldconfig",
        } 

        cron { 'run_preview_processor':
            command => "PATH=/opt/local/bin:$PATH $basedir/bin/run_preview_processor.sh",
            user => $oae_user,
            ensure => present,
            minute => '*',
        }
    } 

    # CentOS 6, RHEL 6
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '6') {
        $centos6_pkgs = ['cronie', 'curlpp-devel', 'ImageMagick', 'ImageMagick-devel', 'ruby-devel']
        package { $centos6_pkgs: ensure => installed }

       cron { 'run_preview_processor':
            command => "$basedir/bin/run_preview_processor.sh",
            user => $oae_user,
            ensure => present,
            minute => '*',
        }
    }

    ###########################################################################
    # Drop the script for the cron job
    file { "$basedir/bin/run_preview_processor.sh":
        source => 'puppet:///modules/preview_processor/run_preview_processor.sh',
        owner  => root,
        group  => root,
        mode   => 755,
    }
}
