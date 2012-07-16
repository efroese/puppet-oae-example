class oae::preview_processor::packages {

    case $operatingsystem {
        CentOS,Redhat: {
            package { 'tk': ensure => installed }
            include 'oae::preview_processor::redhat'
        }
        Amazon: {
            include 'oae::preview_processor::redhat'
            include 'oae::preview_processor::amazon'
        }
    }
}