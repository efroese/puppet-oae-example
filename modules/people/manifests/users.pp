class people::users {

	Class['Localconfig'] -> Class['People::Users']
	Class['People::Groups'] -> Class['People::Users']

	@user { $localconfig::user:
		uid => $localconfig::uid,
		gid => $localconfig::gid,
		home => "/home/${localconfig::user}",
		managehome => true,
	}

    @group { 'branden': guid => 900 }
    @user { 'branden':
        uid        => 900,
        groups     => [ 'branden', 'wheel' ],
        home       => '/home/branden',
        managehome => true,
    }
    @ssh_authorized_key { 'branden-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAr9l2yQjCoZO6D9ANFX0VNSQi7uN1ucqXISjgIcr37D0aAF+/7+fKwvwfAYNj++4rUeWJmzSXDgdVWLBTfQ8bZpb2jx8bvCFbl0jMBiNxhL849iJR/mfpQeXqJ8cYg00lkzuxWtbpynl4kVa+8m1z2v5RBTB9qjpkag7xPj5aplb7pirBgdSOOFeF2hyWkwXwDXfbzPAfCaei9eSTQhgiHqGzKPFz4rdyswT+SWmBusVsFYlclRB5Ig72PgBAt0lb677PI32ZFIWy3wnY0eZVNvmWYj64zWP+nNpidx3BnhNYV2p95vwXf3WLaOTWCgcseRVYKLk0B0VeYN67grLcfQ==',
        require => User['branden'],
    }
    
    @group { 'denbuzze': guid => 901 }
    @user { 'denbuzze':
        uid        => 901,
        groups     => [ 'denbuzze', 'wheel' ],
        home       => '/home/denbuzze',
        managehome => true,
    }
    @ssh_authorized_key { 'denbuzze-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCrhr1zJSSzQEEvuz4g54Gvtm4qSBbniM0j6OQu9w40zai3T7ac+k/vTIPF2xJI6JkrKiOLLu8nJbouRVryPygF6Gg+ZnteIaZzlTVohoMW4msOnXxYOPSg30isW4dXkB35Nsxqwi7X4S77JjsbPuTIb0Z6kV1VvCfkdSewIjh7+w2YMsqT4c2N0R8yE4XSGBsT51VOI47EHl2oYcIvwH42jpeeD5LIuf8hTw/e8BhGpyMtkJi/9mAMb9YCx6oor2btjQpgbLlAcv4DJzilfQePxERQ9zROxU1UNzfUrkI9g92dHROBwK/oqQJSpEbArpgzAyoHBnuzFi2QTiAHw0N3',
        require => User['denbuzze'],
    }
    
    @group { 'raydavis': guid => 902 }
    @user { 'raydavis':
        uid        => 902,
        groups     => [ 'raydavis', 'wheel' ],
        home       => '/home/raydavis',
        managehome => true,
    }
    @ssh_authorized_key { 'raydavis-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1kc3MAAACBAM8LZvmcQDR+nSOAeed1muv3q30NSL6H9l8OBEttdyCc9G6Qp4t0uGHApszVn7szJgfvB/0i8QXS6GoIhBSl/mGSgQSkllptqam3v34gFhiXkjHAQJ/8SywzP4zGmdZ7X/cZyPxr5oVx5TR8V2bKKv70s9/Bc8H/4UM3FspfK8RlAAAAFQDmt0bA9aEOJBJR6mh9vb7+3xNBDwAAAIBhLAFr0K20iOr86n1/zUItqMyferaVJpUeVQO+We6+Szlk4Zef3NNrUdbyGfQPzskDuTLXNEFX8achFpYNnvYUKW1tRxJzoG5a2eifOtrSUB3sInJchKeKSrekTa8dVcD03EkeWTWRFW3tMNoOoU/emV4VfJnvO18YYqjfQI26OgAAAIBhsxngwaPLz6AZNBDcB1gY9nzjHkd8pK1WYDKCDbT8tha2F876Mc+U7xDLSsm8xJZ79rgpEVvqOV4rldSiqRhkgpo9fQg47epFtQCLXQk4oZmzFbNe5bDq01SHn0jqqsPTPApgng/ErI/toXvwX2eZWiTkSE+4w0vsOwiaMoV6WQ==',
        require => User['raydavis'],
    }
    
    @group { 'stuart': guid => 903 }
    @user { 'stuart':
        uid        => 903,
        groups     => [ 'stuart', 'wheel' ],
        home       => '/home/stuart',
        managehome => true,
    }
    @ssh_authorized_key { 'stuart-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAtmHx7EdE6WVfyfh4K6veFhZLjmbsts99sgmAbqfmsAO/Nxx9/F7ggNe7LnytgsSCqEzqR+kvy32CFEKJjNuF3APJ4o3O8IavsnskVSJ5wDR/Z+KWyzMCecDp7OqVjfNasGY0G4W/SWbWIo+PQFNBC1W7LPdYq6V59Ar/5/ommk0Mxrh8ggS9hFdJlX8/JhBXgp/sLOCoL12jHFkb/Vei+X3ksL9jP2YTAMm0bhT3N7cBz9NJPxnxPAlnCaRiEHQ6NdAzRJ1lA1SH3wfQFkpcShobvHdGIs3kAsqZAXTEwvEFheXHdqB/rUzKRbsdTZLrCtMjxDdZZF1/w7U7MbH0JQ==',
        require => User['stuart'],
    }

    @group { 'aberg': guid => 904 }
    @user { 'aberg':
        uid        => 904,
        groups     => [ 'aberg', 'wheel' ],
        home       => '/home/aberg',
        managehome => true,
    }
    @ssh_authorized_key { 'aberg-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1kc3MAAACBAJ9HHFR+goY4hE/5oaV5Ef1rp59UWgBL62DomaJPH19tGLcdt4ynZGHPTMfY9vz/o6f3NJkzMbrXjyQzYLPNVwh6DeRv1RGCgl7qbStxEk44s256Hf1Ziu6b7fa2iijGA58iLnIZNCBspwmVP01pcwz2ew455EMT+UVfPdcnRczvAAAAFQCYMX7xsJsgaQRWswqR1p8Qnd3lpwAAAIAHnSmTJj0bqSNij/JdJBew3Gr7STrZpasoS/m4vow5jRJEdHxjowAks+BldJtdzptdBv2BTXK1yNbj+Kl9ackenR5kIPZW1r2TqrNLFUpiMhe3UX9wjSyioy3mGmkuSGw6tq2vXL72HgSnl5f23w0O3jWfE2oOibd3G3EPdFuieAAAAIBYarab0V/ZuEK1LndNr+HCJvP4tKicKrLomkx6vyS6wjMRZOhZN2PQbdJxkq/u5IVXWOovPvbdmht+UIFD1FPobJpMLksMFgNTTo3s5jSCxbZ/Ealh2PmlIJX0MMtN6JUiAXXcn5eFKibnEAwRSJresgC44sE0dhekpyJ/NEALBg==',
        require => User['aberg'],
    }

    @group { 'chall': guid => 905 }
    @user { 'chall':
        uid        => 905,
        groups     => [ 'chall', 'wheel' ],
        home       => '/home/chall',
        managehome => true,
    }
    @ssh_authorized_key { 'chall-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDN51xT+NzhOdf4CJ1/tA1TYpr1DQ8qMiRT33E0D9FDYpBD9IELvdkq0pawOMiys4XrOqz5WSvq0d2G8iS8kSqyydyFwQ1ncSbYBzdTBKvZJ2JV+JPVF1igV3g0/aOFThnavUp9MKTKHHIhgXI/g7TPXZLKWeyKk4BbEdGuA+wU4k48uVpctatJB0k+WUPePg9ThS5h4qvhFutmZRRQ/SIi2vta/jdEBbdJBgrpHtIwuJokYBkn7bpDopRX3I0s4cjFDp2iBQHKeucUohUUz79p0/DzexwfF5gjhd6C3U7CwObyavXM7n5cfYD+ngAKjKn5X2kCMdyO1P7UXI810RaF',
        require => User['chall'],
    }
    
    @group { 'ctweney': guid => 906 }
    @user { 'ctweney':
        uid        => 906,
        groups     => [ 'ctweney', 'wheel' ],
        home       => '/home/ctweney',
        managehome => true,
    }
    @ssh_authorized_key { 'ctweney-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA0Pq1a6y2ZH0fOkRH7//YiUhGMpRYKMni2SXdhHq7aS6D9iknXqAGnJoQljJONqudqZiSZ9l0b61/+pceKMYndDqEmBz0j/ckIQv2DpTsetr2vd7LWHQZmutdNWLqOPsbIhrglFX794DVb/w8y0y0AWt0WRpiKTrEfHX6eaTDLLpRyDYER8g+0Ls9E8mJdqZzCH7/WKDFh1UZwfyY447K2yVrgJHVSgocd7GD4OsvI2TcQhqXf03rTyh16lDQ2HvdLXfCht0DV8RSt0q6EAnIgteJtDmWMoFfvA+QAT9QN4Z7YwMCg1mES7p3PV4bdWW7V7jE+cgwLD7HM43Q0lTYnQ==',
        require => User['ctweney'],
    }
    
    @group { 'zach': guid => 907 }
    @user { 'zach':
        uid        => 907,
        groups     => [ 'zach', 'wheel' ],
        home       => '/home/zach',
        managehome => true,
    }
    @ssh_authorized_key { 'zach-public':
        type    => 'ssh-rsa',
        key     => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA0q5OsCWMLy4hSzC24f/l+iTNiHy7yzXlBretthTfrARNLcrrSxS/qh7m+/VfZJWastSLp46aGr88gq/T52cbM/3v7a0US0MXBETu31+ugUdUylp1n8PREJVUtSqnLMHUyEPFGjiUpzBUVlQHTib3RO/CBTKfhCxuInwuJ6wXAEBr3UEL5kqMOErojnJy4QVTRE0MA1HruRkOGn5MysKpvekviimVI5AOhM/ZGpbv+3yD6DRldwG9RLN5Y2WQJ+YiXtSacfPNq374GJ3Yc+7lBpPWuN+RI7UmDMzarDkVkIRjbgnoOQe0LnIrAo75AFN+VbWhCNbTJwYeT9qgs8Kkww==',
        require => User['zach'],
    }
}
