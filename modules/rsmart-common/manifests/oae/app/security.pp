#
# OAE Security configurations
#
class rsmart-common::oae::app::security($locked = true){

    Class['Localconfig'] -> Class['Rsmart-common::Oae::App::Security']

    # Separates trusted vs untrusted content.
    oae::app::server::sling_config {
        "org.sakaiproject.nakamura.http.usercontent.ServerProtectionServiceImpl":
        config => {
            'disable.protection.for.dev.mode' => $localconfig::sps_disabled,
            'trusted.hosts'  => [
                "localhost:8080\\ \\=\\ http://localhost:8081",
                "${hostname}:8080\\ \\=\\ http://${hostname}:8081",
                "${localconfig::http_name}\\ \\=\\ https://${localconfig::http_name_untrusted}",
            ],
            'trusted.secret' => $localconfig::serverprotectsec,
        },
        locked => $locked,
    }

    if $localconfig::qos_limit {
        # QoS filter rate-limits the app server so it won't fall over
        oae::app::server::sling_config {
            "org.sakaiproject.nakamura.http.qos.QoSFilter":
            config => { 'qos.default.limit' => $localconfig::qos_limit, },
            locked => $locked,
        }
    }
}