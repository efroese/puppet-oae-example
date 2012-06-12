#
# OAE CLE integration configuration
#
class rsmart-common::oae::app::cle ($locked = true){
 
    Class['Localconfig'] -> Class['Rsmart-common::Oae::App::Cle']

    ###########################################################################
    # CLE integration
    if ($localconfig::basiclti_secret) and ($localconfig::basiclti_key) {
        oae::app::server::sling_config {
            "org.sakaiproject.nakamura.basiclti.CLEVirtualToolDataProvider":
            config => {
                'sakai.cle.basiclti.secret' => $localconfig::basiclti_secret,
                'sakai.cle.server.url'      => "https://${localconfig::http_name}",
                'sakai.cle.basiclti.key'    => $localconfig::basiclti_key,
                'sakai.cle.basiclti.tool.list' => $localconfig::basiclti_tool_list,
            },
            locked => $locked,
        }
    }
}