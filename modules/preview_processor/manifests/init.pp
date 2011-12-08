class preview_processor {

    $processor_user = "sakai"
    realize(Group[$processor_user])
    realize(User[$processor_user])

    $ruby_bin="/usr/bin/ruby"
    $basedir="/home/$processor_user"
    $ppath = ""

    # Present in the base CentOS repositories
    $common_packages = ['cpp', 'gcc', 'fontconfig-devel', 'java-1.6.0-openjdk', 'poppler-utils', 'rubygems']
    package { $common_packages: ensure => installed }

    # From rpmforge
    $docsplit_packages = ['pdftk']

    # CentOS 5, RHEL 5
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '5') {
        # CentOS needs updated ImageMagick and Ruby packages
        $centos_packages = ['ImageMagick-6.4.9-10', 'ImageMagick-devel-6.4.9-10', 
                            'ruby1.9.2p0-1.9.2p0-1',
                            'curl-devel',]
        package { $centos_packages: ensure => installed }
	$docsplit_packages = [ $docsplit_packages, 'tesseract']
        $ppath ="/opt/local/bin:\$PATH"
    }

    # CentOS 6, RHEL 6, Fedora
    if ($operatingsystem == 'CentOS' or $operatingsystem == 'RedHat') and ($lsbmajdistrelease == '6') {
        # Fedora can use the base packages.
        $fedora_packages = ['cronie', 'curlpp-devel', 'ImageMagick', 'ImageMagick-devel', 'ruby-devel']
        package { $fedora_packages: ensure => installed }
    }

    package { $docsplit_packages: ensure => installed }

    ###########################################################################
    # Drop the script for the cron job
    file { '/usr/local/share/preview_processor/run_preview_processor.sh':
        source => 'puppet:///modules/preview_processor/run_preview_processor.sh',
        owner  => root,
        group  => root,
        mode   => 755,
    }
    
    cron { 'run_preview_processor':
        command => "$ppath /usr/local/share/preview_processor/run_preview_processor.sh",
        user => $processor_user,
        ensure => present,
	minute => '*',
    }
}
