# = Class: oae::preview_processor::debian
#
# Debian packages for the preview processor.
#
# Parameters:
class oae::preview_processor::debian {

    $packagelist = [
        'graphicsmagick',
        'pdftk',
        'poppler-utils',
        'tesseract-ocr',
        'rubygems',
        'libjson-ruby',
        'librmagick-ruby',
        'openoffice.org',
        'openoffice.org-java-common'
    ]

    package { $packagelist: ensure => installed }

}
