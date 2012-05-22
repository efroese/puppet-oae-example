
class rsmart-common::nagios::commands {

    nagios_command { 'check_nrpe':
        command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$';
    }
}
