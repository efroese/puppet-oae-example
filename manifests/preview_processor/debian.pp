class oae::preview_processor::debian {

    $packagelist = [
        'graphicsmagick', 'pdftk', 'poppler-utils', 'tesseract-ocr',
        'rubygems', 'libjson-ruby', 'librmagick-ruby',
        'openoffice.org', 'openoffice.org-java-common'
    ]

    package { $packagelist: ensure => installed }

    cron { 'run_preview_processor':
        command => "${oae::preview_processor::basedir}/bin/run_preview_processor.sh",
        user => $oae::params::user,
        ensure => present,
        minute => '*',
    }
}
