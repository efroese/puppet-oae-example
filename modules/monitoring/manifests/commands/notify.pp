#
# = Class: monitoring::commands::notify
# Define icinga commands to notify users of host and service events.
#
class monitoring::commands::notify { 
    icinga::command {
        notify-host-by-email:
            command_line => "/usr/bin/printf \"%b\" \"***** Nagios *****\\n\\nNotification Type: \$NOTIFICATIONTYPE\$\\nHost: \\$HOSTNAME\\$\\nState: \$HOSTSTATE\$\\nAddress: \$HOSTADDRESS\$\\nInfo: \$HOSTOUTPUT\$\\n\\nDate/Time: \$LONGDATETIME\$\\n\" | ${mail_cmd_location} -s \"** \$NOTIFICATIONTYPE\$ Host Alert: \$HOSTNAME\$ is \$HOSTSTATE\$ **\" \$CONTACTEMAIL\$";
  	    notify-service-by-email:
          	command_line => "/usr/bin/printf \"%b\" \"***** Nagios *****\\n\\nNotification Type: \$NOTIFICATIONTYPE\$\\n\\nService: \$SERVICEDESC\$\\nHost: \$HOSTALIAS\$\\nAddress: \$HOSTADDRESS\$\\nState: \$SERVICESTATE\$\\n\\nDate/Time: \$LONGDATETIME\$\\n\\nAdditional Info:\\n\\n\$SERVICEOUTPUT\$\" | ${mail_cmd_location} -s \"** \$NOTIFICATIONTYPE\$ Service Alert: \$HOSTALIAS\$/\$SERVICEDESC\$ is \$SERVICESTATE\$ **\" \$CONTACTEMAIL\$";
        notify-host-by-epager:
            command_line => '/usr/bin/printf "%b" "Host \'$HOSTALIAS$\' is $HOSTSTATE$\nInfo: $HOSTOUTPUT$\nTime: $LONGDATETIME$" | /bin/mail -s "$NOTIFICATIONTYPE$ alert - Host $HOSTNAME$ is $HOSTSTATE$" $CONTACTPAGER$';
        notify-service-by-epager:
            command_line => '/usr/bin/printf "%b" "Service: $SERVICEDESC$\nHost: $HOSTNAME$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\nInfo: $SERVICEOUTPUT$\nDate: $LONGDATETIME$" | /bin/mail -s "$NOTIFICATIONTYPE$: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$" $CONTACTPAGER$';
	}
}