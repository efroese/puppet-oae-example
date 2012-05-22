#
# = Class: monitoring::commands
#  Default set of commands for icinga
#
class monitoring::commands::base { 
    icinga::command {
#        check_dummy:
#            command_line => '$USER1$/check_dummy $ARG1$';
        check_ping:
            command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w $ARG1$ -c $ARG2$ -p 5';
        check-host-alive:
            command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 5000,100% -c 5000,100% -p 1';
        check_load:
            command_line => '$USER1$/check_load --warning=$ARG1$,$ARG2$,$ARG3$ --critical=$ARG4$,$ARG5$,$ARG6$';
        check_local_load:
            command_line => '$USER1$/check_load -w $ARG1$ -c $ARG2$';
        check_local_procs:
            command_line => '$USER1$/check_procs -w $ARG1$ -c $ARG2$ -s $ARG3$';
        check_local_users:
            command_line => '$USER1$/check_users -w $ARG1$ -c $ARG2$';
        check_dell_om:
            command_line => '$USER1$/check_dell_omreport.pl';
        check_rsmart_dl:
            command_line => '$USER1$/check_rsmart_download.pl';
        check_local_swap:
            command_line => '$USER1$/check_swap -w $ARG1$ -c $ARG2$';
        check_disk:
            command_line => '$USER1$/check_disk -w $ARG1$ -c $ARG2$ -e -p $ARG3$';
        check_all_disks:
            command_line => '$USER1$/check_disk -w $ARG1$ -c $ARG2$ -e';
        check_ssh:
            command_line => '$USER1$/check_ssh $HOSTADDRESS$';
        check_ssh_port:
            command_line => '$USER1$/check_ssh -p $ARG1$ $HOSTADDRESS$';
        check_ssh_port_host:
            command_line => '$USER1$/check_ssh -p $ARG1$ $ARG2$';
        check_ftp:
            command_line => '$USER1$/check_ftp -H $HOSTADDRESS$ -t 30';
        check_git:
            command_line => '$USER1$/check_tcp -H $ARG1$ -p 9418';
        check_hpjd:
            command_line => '$USER1$/check_hpjd -H $HOSTADDRESS$ -C public';
        check_http:
            command_line => '$USER1$/check_http -H $HOSTADDRESS$ -I $HOSTADDRESS$';
        check_https:
            command_line => '$USER1$/check_http --ssl -H $HOSTADDRESS$ -I $HOSTADDRESS$';
        check_https_cert:
            command_line => '$USER1$/check_http --ssl -C 20 -H $HOSTADDRESS$ -I $HOSTADDRESS$';
        check_http_url:
            command_line => '$USER1$/check_http -H $ARG1$ -u $ARG2$';
        check_https_url:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$';
        check_http_url_regex:
            command_line => '$USER1$/check_http -H $ARG1$ -p $ARG2$ -u $ARG3$ -e $ARG4$';
        check_https_url_regex:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$ -e $ARG3$';
        check_http_response:
            command_line => '$USER1$/check_http -H $HOSTADDRESS$ -f follow -u $ARG1$ -s $ARG2$';
        check_http_port:
            command_line => '$USER1$/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$';
        check_http_port_url_content:
            command_line => '$USER1$/check_http -H $ARG1$ -p $ARG2$ -u $ARG3$ -s $ARG4$';
        check_https_port_url_content:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -p $ARG2$ -u $ARG3$ -s $ARG4$';
        check_http_url_content:
            command_line => '$USER1$/check_http -H $ARG1$ -u $ARG2$ -s $ARG3$';
        check_https_url_content:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$ -s $ARG3$';
        check_http_auth_port_url_content:
            command_line => '$USER1$/check_http -H $ARG1$ -p $ARG2$ -u $ARG3$ -s $ARG4$ -a $ARG5$';
        check_https_auth_port_url_content:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -p $ARG2$ -u $ARG3$ -s $ARG4$ -a $ARG5$';
        check_jabber:
            command_line => '$USER1$/check_jabber -H $ARG1$';
        check_ldap:
            command_line => '$USER1$/check_ldap.pl -H $ARG1$ -l $ARG2$ -x $ARG3$ -p $ARG4$';
        check_ldaps:
            command_line => '$USER1$/check_ldap.pl -H $ARG1$ -l $ARG2$ -x $ARG3$ -p $ARG4$ -s';
        check_mysql:
            command_line => '$USER1$/check_mysql -H $ARG1$ -P $ARG2$ -u $ARG3$ -p $ARG4$';
        check_mysql_db:
            command_line => '$USER1$/check_mysql -H $ARG1$ -P $ARG2$ -u $ARG3$ -p $ARG4$ -d $ARG5$';
        check_nttp:
            command_line => '$USER1$/check_nntp -H $HOSTADDRESS$';
        check_ntp_time:
            command_line => '$USER1$/check_ntp_time -H $ARG1$ -w $ARG2$ -c $ARG3$';
        check_ntp_peer:
            command_line => '$USER1$/check_ntp_peer -H $ARG1$ -w $ARG2$ -c $ARG3$';
        check_pop:
            command_line => '$USER1$/check_pop -H $HOSTADDRESS$';
        check_secure_imap:
            command_line => '$USER1$/check_simap -H $HOSTADDRESS$';
        check_silc:
            command_line => '$USER1$/check_tcp -p 706 -H $ARG1$';
        check_sip:
            command_line => '$USER1$/check_sip -u $ARG1$ -H $HOSTADDRESS$ -w 5';
        check_snmp:
            command_line => '$USER1$/check_snmp -H $HOSTADDRESS$ $ARG1$';
        check_smtp:
            command_line => '$USER1$/check_smtp -H $ARG1$ -t 30';
        check_sobby:
            command_line => '$USER1$/check_tcp -H $ARG1$ -p $ARG2$';
        check_svn_http:
        	command_line => '$USER1$/check_http -H $ARG1$ -S';
        check_tcp:
            command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$';
        check_tcp_specific_host:
            command_line => '$USER1$/check_tcp -H $ARG1$ -p $ARG2$';
        check_telnet:
            command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p 23';
        check_udp:
            command_line => '$USER1$/check_udp -H $HOSTADDRESS$ -p $ARG1$';
        check_udp_specific_host:
        	command_line => '$USER1$/check_udp -H $ARG1$ -p $ARG2$';
        check_virtual_host:
            command_line=> '$USER1$/check_http -H $ARG1$ -f follow -u $ARG2$ -s $ARG3$';
        check_virtual_host_by_port:
        	command_line => '$USER1$/check_http -H $ARG1$ -f follow -u $ARG2$ -s $ARG3$ -p $ARG4$';
        check_virtual_host_by_ssl_port:
            command_line => '$USER1$/check_http -H $ARG1$ -f follow -u $ARG2$ -s $ARG3$ -p $ARG4$ -S';
        check_virtual_host_slow:
            command_line => '$USER1$/check_http -H $ARG1$ -f follow -u $ARG2$ -s $ARG3$ -t 30';
        check_virtual_host_ssl:
            command_line => '$USER1$/check_http -H $ARG1$ -f follow -u $ARG2$ -s $ARG3$ -S';

        check_nrpe:
            command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$';
        check_nrpe_slow:
            command_line => '$USER1$/check_nrpe -H $ARG1$ -c $ARG2$ -t 90';

        # from bind module
        check_dig2:
           command_line => '$USER1$/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$';
        # from mysql module
        check_mysql_health:
           command_line => '$USER1$/check_mysql_health --hostname $ARG1$ --port $ARG2$ --username $ARG3$ --password $ARG4$ --mode $ARG5$ --database $ARG6$';
        check_dns:
             command_line => '$USER1$/check_dns -H www.rsmart.com -s $HOSTADDRESS$';
        # better check_dns
        check_dns2:
          command_line => '$USER1$/check_dns2 -c $ARG1$ A $ARG2$';
        # dnsbl checking
        check_dnsbl:
          command_line => '$USER1$/check_dnsbl -H $ARG1$';
    }

    $mail_cmd_location = $::operatingsystem ? {
        centos => '/bin/mail',
        default => '/usr/bin/mail'
    }

}
