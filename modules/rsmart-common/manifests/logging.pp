class rsmart-common::logging ( $locked = true ) {

    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config.search-logger-uuid':
        config => {
            'service.factoryPid' => 'org.apache.sling.commons.log.LogManager.factory.config',
            'org.apache.sling.commons.log.level' => 'info',
            'org.apache.sling.commons.log.file'  => 'logs/search.log',
            'org.apache.sling.commons.log.names' => [ 'org.sakaiproject.nakamura.search',
                                                      'org.sakaiproject.nakamura.solr',
                                                      'org.sakaiproject.nakamura.activity.search',],
        },
        locked => $locked,
    }

    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config.storage-logger-uuid':
        config => {
            'service.factoryPid' => 'org.apache.sling.commons.log.LogManager.factory.config',
            'org.apache.sling.commons.log.names' => [ 'org.sakaiproject.nakamura.lite.storage.jdbc', ],
            'org.apache.sling.commons.log.level' => 'info',
            'org.apache.sling.commons.log.file'  => 'logs/storage.log',
        },
        locked => $locked,
    }

    oae::app::server::sling_config {
        'org.apache.sling.commons.log.LogManager.factory.config.content-logger-uuid':
        config => {
            'service.factoryPid' => 'org.apache.sling.commons.log.LogManager.factory.config',
            'org.apache.sling.commons.log.level' => 'info',
            'org.apache.sling.commons.log.file'  => 'logs/content.log',
            'org.apache.sling.commons.log.names' => [ 'org.sakaiproject.nakamura.files',
                                                      'org.sakaiproject.nakamura.version',
                                                      'org.sakaiproject.nakamura.message',
                                                      'org.sakaiproject.nakamura.api.resource.lite',],
        },
        locked => $locked,
    }
}
