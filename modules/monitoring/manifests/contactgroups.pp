#
# = Class: monitoring::contactgroups
# rSmart contact groups
#
class monitoring::contactgroups {

    icinga::contactgroup { 'network_operations':
        contactgroup_alias => 'Network Support',
        members => 'mike,dthomson,cramaker,karagon,mflitsch,gpeterson',
	}

    icinga::contactgroup { 'acad_support':
        contactgroup_alias => 'Academic Support',
        members => 'mike,dthomson,cramaker,karagon,acad.status,gpeterson,lspeelmon,efroese',
    }

    icinga::contactgroup { 'client_support':
        contactgroup_alias => 'Client Services',
        members => 'mike,dthomson,cramaker,karagon,mdigiacomo,skamali,stieke,mflitsch,aburian,cbrokaw,ihagan,gvesper,gpeterson',
	}

    icinga::contactgroup { 'level3':
        contactgroup_alias => 'RSN and XenDesk Notification',
        members => 'rsn',
	}

    icinga::contactgroup { 'others':
        contactgroup_alias => 'Other People',
        members => 'dthomson',
	}

    icinga::contactgroup { 'kfs_support':
        contactgroup_alias => 'KFS Notifcations',
        members => 'dthomson,cramaker,jcrodriguez,mflitsch,cbrokaw,djung,gpeterson',
	}

    icinga::contactgroup { 'kc_support':
        contactgroup_alias => 'KC Notifcations',
        members => 'dthomson,cramaker,jcrodriguez,mflitsch,cbrokaw,djung,gpeterson',
    }

    icinga::contactgroup { 'tem_support':
        contactgroup_alias => 'TEM Notifcations',
        members => 'dthomson,cramaker,jcrodriguez,mflitsch,mbrown,wonstine,lprzybylski,cbrokaw,djung,gpeterson',
    }

    icinga::contactgroup { 'sgu_ldap':
        contactgroup_alias => 'SGU LDAP',
        members => 'dthomson,cramaker,mflitsch,karagon,mdigiacomo,aburian,stieke,dnotify,abest,sharford,ihagan,gvesper,gpeterson',
    }


    icinga::contactgroup { 'dev_test_support':
        contactgroup_alias => 'Dev/Test Notifications',
        members => 'dthomson,cramaker,mike,mflitsch,cbrokaw,gpeterson',
	}

    icinga::contactgroup { 'ucd_support':
        contactgroup_alias => 'UCDavis Oracle Notifications',
        members => 'ppilli',
    }

    icinga::contactgroup { 'ucd_back_support':
        contactgroup_alias => 'UCDavis Backup Oracle Notifications',
        members => 'mpankow',
	}

    icinga::contactgroup { 'dba':
        contactgroup_alias => 'Database Administrators',
        members => 'ppilli',
	}

    icinga::contactgroup { 'train_academic':
        contactgroup_alias => 'Train-Academic Notifications',
        members => 'lspeelmon',
    }
}