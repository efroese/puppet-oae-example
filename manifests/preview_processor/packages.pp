class oae::preview_processor::packages {

    case $operatingsystem {
        CentOS,Redhat: {
            include 'oae::preview_processor::redhat'
        }
        Amazon: {
            include 'oae::preview_processor::amazon'
        }
    }
}