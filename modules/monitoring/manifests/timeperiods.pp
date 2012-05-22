#
# Icinga timeperiod objects.
#
class monitoring::timeperiods {

    icinga::timeperiod { '24x7':
        timeperiod_alias => '24 Hours A Day, 7 Days A Week',
        includes => {
            'monday'    => '00:00-24:00',
            'tuesday'   => '00:00-24:00',
            'wednesday' => '00:00-24:00',
            'thursday'  => '00:00-24:00',
            'friday'    => '00:00-24:00',
            'saturday'  => '00:00-24:00',
            'sunday'    => '00:00-24:00',
         }
    }

    icinga::timeperiod { '24x7nobackups':
        timeperiod_alias => '24 Hours A Day, 7 Days A Week, except for backups',
        includes => {
            'monday'    => '00:00-04:00,6:15-24:00',
            'tuesday'   => '00:00-04:00,6:15-24:00',
            'wednesday' => '00:00-04:00,6:15-24:00',
            'thursday'  => '00:00-04:00,6:15-24:00',
            'friday'    => '00:00-04:00,6:15-24:00',
            'saturday'  => '00:00-04:00,6:15-24:00',
            'sunday'    => '00:00-04:00,6:15-24:00',
         }
    }

    icinga::timeperiod { '24x7kuali-qa':
        timeperiod_alias => 'All the time except 9-11PM',
        includes => {
            'monday'    => '00:00-21:00,23:00-24:00',
            'tuesday'   => '00:00-21:00,23:00-24:00',
            'wednesday' => '00:00-21:00,23:00-24:00',
            'thursday'  => '00:00-21:00,23:00-24:00',
            'friday'    => '00:00-21:00,23:00-24:00',
            'saturday'  => '00:00-21:00,23:00-24:00',
            'sunday'    => '00:00-21:00,23:00-24:00',
         }
    }

    icinga::timeperiod { '24x7cle-qa':
        timeperiod_alias => 'All the time except 1:30-5:30AM',
        includes => {
            'monday'    => '00:00-01:30,5:30-24:00',
            'tuesday'   => '00:00-01:30,5:30-24:00',
            'wednesday' => '00:00-01:30,5:30-24:00',
            'thursday'  => '00:00-01:30,5:30-24:00',
            'friday'    => '00:00-01:30,5:30-24:00',
            'saturday'  => '00:00-01:30,5:30-24:00',
            'sunday'    => '00:00-01:30,5:30-24:00',
         }
    }

    icinga::timeperiod { 'workhours':
        timeperiod_alias => 'Normal Work Hours',
        includes => {
            'monday'    => '09:00-17:00',
            'tuesday'   => '09:00-17:00',
            'wednesday' => '09:00-17:00',
            'thursday'  => '09:00-17:00',
            'friday'    => '09:00-17:00',
            'saturday'  => '09:00-17:00',
            'sunday'    => '09:00-17:00',
         }
    }

    icinga::timeperiod { 'none':
        timeperiod_alias => 'No Time Is A Good Time',
    }

    icinga::timeperiod { 'us-holidays':
        timeperiod_alias => 'U.S. Holidays',
        includes => {
            'january 1'            => '00:00-24:00 ; New Years',
            'monday -1 may '       => '00:00-24:00 ; Memorial Day (last Monday in May)',
            'july 4'               => '00:00-24:00 ; Independence Day',
            'monday 1 september'   => '00:00-24:00 ; Labor Day (first Monday in September)',
            'thursday -1 november' => '00:00-24:00 ; Thanksgiving (last Thursday in November)',
            'december 25'          => '00:00-24:00 ; Christmas',
         }
    }

    icinga::timeperiod { '24x7_sans_holidays':
        timeperiod_alias => '24x7 Sans Holidays',
        use		         => 'us-holidays',
        includes => {
            'monday'    => '00:00-24:00',
            'tuesday'   => '00:00-24:00',
            'wednesday' => '00:00-24:00',
            'thursday'  => '00:00-24:00',
            'friday'    => '00:00-24:00',
            'saturday'  => '00:00-24:00',
            'sunday'    => '00:00-24:00',
         }
     }
}
