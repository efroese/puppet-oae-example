class monitoring::contacts {

    icinga::contactgroup { 'academic-contacts':
        contactgroup_alias => 'Academic contacts',
        members =>  'efroese',
    }

    icinga::contact { 'efroese':
        contact_alias => 'Erik Froese',
        email => 'erik@hallwaytech.com',
    }

    # 'rsn' contact definition
    icinga::contact { 'rsn':
        contact_alias => 'RSN Emailer',
        email         => 'support@rsmart.com',
        service_notification_options => 'c',
        host_notification_options    => 'd',
    }

    # 'acad.status' contact definition
    icinga::contact { 'acad.status':
        contact_alias => 'acad.status Emailer',
        email         => 'acad.status@rsmart.com',
        service_notification_options => 'c',
        host_notification_options    => 'd',
    }

    # 'zendesk' contact definition
    icinga::contact { 'zendesk':
        contact_alias => 'ZenDesk Emailer',
        email         => 'support@rsmart.zendesk.com',
        service_notification_options => 'c',
        host_notification_options    => 'd',
    }

    icinga::contact { 'aapotts':
        contact_alias => 'Anthony Potts',
        email         => 'tony@rsmart.com',
        pager         => '023698930@tmomail.com',
    }

    icinga::contact { 'mike':
        contact_alias => 'Mike DeSimone',
        email         => 'mike@rsmart.com',
        service_notification_commands => 'notify-service-by-email,notify-service-by-epager',        
# page only 16-31st of month
#        pager => 'mikedes@textfree.us',
    }

    icinga::contact { 'mflitsch':
        contact_alias => 'Mike Flitsch',
        email => 'mflitsch@rsmart.com',
    }

    icinga::contact { 'chris':
        contact_alias => 'Chris Coppola',
        email => 'chris@rsmart.com',
        pager => '6023698931@tmomail.com',
    }

    icinga::contact { 'gpeterson':
        contact_alias => 'George Peterson',
        service_notification_commands => 'notify-service-by-epager',
        host_notification_commands    => 'notify-host-by-epager',
        email => 'gpeterson@rsmart.com'
    }

    icinga::contact { 'lspeelmon':
        contact_alias => 'Lance Speelmon',
        email => 'lspeelmon@rsmart.com',
    }

    icinga::contact { 'karagon':
        contact_alias => 'Kenneth Aragon',
        email => 'karagon@rsmart.com'
    }

    icinga::contact { 'mdigiacomo':
        contact_alias => 'Mark DiGiacomo',
        email => 'mdigiacomo@rsmart.com',
    }

    icinga::contact { 'gvesper':
        contact_alias => 'Greg Vesper',
        email => 'gvesper@rsmart.com',
    }

    icinga::contact { 'dthomson':
        contact_alias => 'Dave Thomson',
        service_notification_commands => 'notify-service-by-email,notify-service-by-epager',
        host_notification_commands => 'notify-host-by-email,notify-host-by-epager',
        email => 'dthomson@rsmart.com',
	    pager => 'adrnalnrsh@textfree.us',
    }

    icinga::contact { 'cramaker':
        contact_alias => 'Cody Ramaker',
        email => 'cramaker@rsmart.com',
    }

    icinga::contact { 'cbrokaw':
        contact_alias => 'Charles Brokaw',
        email => 'cbrokaw@rsmart.com',
    }

    icinga::contact { 'skamali':
        contact_alias => 'Simin Kamali',
        email => 'skamali@rsmart.com',
    }

    icinga::contact { 'ihagan':
        contact_alias => 'Ian Hagan',
        email => 'ihagan@rsmart.com',
}

    icinga::contact { 'stieke':
        contact_alias => 'Sascha Tieke',
        email => 'stieke@rsmart.com',
    }

    icinga::contact { 'aburian':
        contact_alias => 'Austin Burian',
        email => 'aburian@rsmart.com',
    }

    icinga::contact { 'jcrodriguez':
        contact_alias => 'Juan Carlos',
        email => 'jcrodriguez@rsmart.com',
    }

    icinga::contact {'djung':
        contact_alias => 'Daniel Jung',
        email => 'djung@rsmart.com',
    }

    icinga::contact { 'pmains':
        contact_alias => 'Peter Mains',
        email => 'pmains@rsmart.com',
    }

    icinga::contact { 'duffy':
        contact_alias => 'Duffy Gillman',
        email => 'dgillman@rsmart.com',
    }

    icinga::contact { 'mpankow':
        contact_alias => 'Mark Pankow',
        email => 'mpankow@rsmart.com',
    }
    
    icinga::contact { 'ppilli':
        contact_alias => 'Prabhu',
        email => 'ppilli@rsmart.com',
    }

    icinga::contact { 'mbrown':
        contact_alias => 'Myrna',
        email => 'mbrown@rsmart.com',
    }

    icinga::contact { 'lprzybylski':
        contact_alias => 'Leo',
        email => 'lprzybylski@rsmart.com',
    }

    icinga::contact { 'abest':
        contact_alias => 'abest from sgu',
        email => 'abest@sgu.edu',
    }

    icinga::contact { 'sharford':
        contact_alias => 'sharford from sgu',
        email => 'sharford@sgu.edu',
    }

    icinga::contact { 'droberts':
        contact_alias => 'droberts at SGU',
        email => 'droberts@sgu.edu',
    }

    icinga::contact { 'dnotify':
        contact_alias => 'Domino Notify for SGU',
        email => 'dominonotify@sgu.edu',
    }

    icinga::contact { 'wonstine':
        contact_alias => 'Warner',
        email => 'wonstine@rsmart.com',
    }
}
