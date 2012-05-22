#
# = Class: monitoring::commands::notify
# Define icinga commands to monitor VMWare ESX 3 hosts
#
class monitoring::commands::esx {

    # Commands for ESX(i) Datacenter
    # 'check_esx3_dc_vm' command definition
    icinga::command {'check_esx3_dc_vm':
	    command_line => '$USER1$/check_esx3 -D $ARG1$ -u $ARG2$ -p $ARG3$ -l $ARG4$ -s "$ARG5$" -N "$ARG6$" -w "$ARG7$" -c "$ARG8$"',
	}

    # 'check_esx3_dc_host' command definition
    icinga::command { 'check_esx3_dc_host':
	    command_line => '$USER1$/check_esx3 -D $ARG1$ -u $ARG2$ -p $ARG3$ -l $ARG4$ -s "$ARG5$" -H "$ARG6$" -w "$ARG7$" -c "$ARG8$"',
	}

    # Commands for ESX(i) Hosts
    # 'check_esx3_host_cpu_usage' command definition
    icinga::command { 'check_esx3_host_cpu_usage':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l cpu -s usage -w $ARG3$ -c $ARG4$',
	}

    # 'check_esx3_host_mem_usage' command definition
    icinga::command { 'check_esx3_host_mem_usage':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l mem -s usage -w $ARG3$ -c $ARG4$',
	}

    # 'check_esx3_host_swap_usage' command definition
    icinga::command { 'check_esx3_host_swap_usage':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l mem -s swap -w $ARG3$ -c $ARG4$',
	}

    # 'check_esx3_host_net_usage' command definition
    icinga::command { 'check_esx3_host_net_usage':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l net -s usage -w $ARG3$ -c $ARG4$',
	}

    # 'check_esx3_host_vmfs' command definition
    icinga::command { 'check_esx3_host_vmfs':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l vmfs -s $ARG3$ -w $ARG4$ -c $ARG5$',
	}

    # 'check_esx3_host_runtime_status' command definition
    icinga::command { 'check_esx3_host_runtime_status':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l runtime -s status',
	}

    # 'check_esx3_host_runtime_issues' command definition
    icinga::command { 'check_esx3_host_runtime_issues':
	    command_line => '$USER1$/check_esx3 -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -l runtime -s issues',
	}

    # Commands for virtual hosts

    # 'check_esx3_vm_cpu_usage' command definition
    icinga::command { 'check_esx3_vm_cpu_usage':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l cpu -s usage -w $ARG5$ -c $ARG6$',
	}

    # 'check_esx3_vm_mem_usage' command definition
    icinga::command { 'check_esx3_vm_mem_usage':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l mem -s usage -w $ARG5$ -c $ARG6$',
	}

    # 'check_esx3_vm_swap_usage' command definition
    icinga::command { 'check_esx3_vm_swap_usage':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l mem -s swap -w $ARG5$ -c $ARG6$',
	}
    # 'check_esx3_vm_net_usage' command definition
    icinga::command { 'check_esx3_vm_net_usage':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l net -s usage -w $ARG5$ -c $ARG6$',
	}

    # 'check_esx3_vm_runtime_cpu' command definition
    icinga::command { 'check_esx3_vm_runtime_cpu':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l runtime -s cpu -w $ARG5$ -c $ARG6$',
	}

    # 'check_esx3_vm_runtime_mem' command definition
    icinga::command { 'check_esx3_vm_runtime_mem':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l runtime -s mem -w $ARG5$ -c $ARG6$',
	}

    # 'check_esx3_vm_runtime_status' command definition
    icinga::command { 'check_esx3_vm_runtime_status':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l runtime -s status',
	}

    # 'check_esx3_vm_runtime_state' command definition
    icinga::command { 'check_esx3_vm_runtime_state':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l runtime -s state',
	}

    # 'check_esx3_vm_runtime_issues' command definition
    icinga::command { 'check_esx3_vm_runtime_issues':
	    command_line => '$USER1$/check_esx3 -H $ARG1$ -u $ARG2$ -p $ARG3$ -N $ARG4$ -l runtime -s issues',
	}
}
