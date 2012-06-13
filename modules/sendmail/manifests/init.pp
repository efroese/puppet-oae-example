#
# = Class: sendmail
# Install sendmail and configure it. Recofniguration triggers restart.
#
# == Parameters:
#
# $sendmail_mc_template:: A template to generate the sendmail.mc file.
#
# $submit_mc_template:: A template to generate the submit.mc file.
#
# $access_template:: A template to generate the access file.
#
# $mailertable_template:: A template to generate the mailertable file.
#
# $virtusertable_template:: A template to generate the virtusertable file.
#
# $local_host_names_template:: A template to generate the local-host-names file.
#
class sendmail (
    $sendmail_mc_template      = undef,
    $submit_mc_template        = undef,
    $access_template           = undef,
    $mailertable_template      = undef,
    $virtusertable_template    = undef,
    $local_host_names_template = undef
    ){

    package { [ 'sendmail', 'sendmail-cf', ] : ensure => installed }

    if $sendmail_mc_template != undef {
        file { "/etc/mail/sendmail.mc":
            mode    => 644,
            content => template($sendmail_mc_template),
            notify  => Exec['sendmail-make-config'],
        }
    }

    if $submit_mc_template != undef {
        file { "/etc/mail/submit.mc":
            mode    => 644,
            content => template($submit_mc_template),
            notify  => Exec['sendmail-make-config'],
        }
    }

    if $access_template != undef {
        file { "/etc/mail/access":
            mode    => 644,
            content => template($access_template),
            notify  => Exec['sendmail-make-config'],
        }
    }

    if $mailertable_template != undef {
        file { "/etc/mail/mailertable":
            mode    => 644,
            content => template($mailertable_template),
            notify  => Exec['sendmail-make-config'],
        }
    }

    if $virtusertable_template != undef {
        file { "/etc/mail/virtusertable":
            mode    => 644,
            content => template($virtusertable_template),
            notify  => Exec['sendmail-make-config'],
        }
    }

    if $local_host_names_template != undef {
        file { "/etc/mail/local-host-names":
            mode    => 644,
            content => template($local_host_names_template),
            notify  => Exec['sendmail-make-config'],
        }
    }

    exec { 'sendmail-make-config':
        command     => "make -C /etc/mail",
        refreshonly => true,
        notify      => Service['sendmail'],
    }

    service { 'sendmail':
        ensure => running,
        hasstatus => true,
        enable => true,
    }
}
