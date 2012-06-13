#
# OAE email integration configuration
#
class rsmart-common::oae::app::email ($locked = true){
 
    Class['Localconfig'] -> Class['Rsmart-common::Oae::App::Email']

    oae::app::server::sling_config {
        'org.sakaiproject.nakamura.email.outgoing.LiteOutgoingEmailMessageListener':
        config => {
            'sakai.email.replyAsAddress' => $localconfig::reply_as_address,
            'sakai.email.replyAsName'    => $localconfig::reply_as_name,
        }
    }
}