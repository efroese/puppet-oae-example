class oae {
    # 
    define sling_config($config){
        file { "/usr/local/sakaioae/sling/config/${name}":
            owner => "sakaioae",
            group => "sakaioae",
            mode  => 0440,
            content => template("oae/sling_config.erb"),
        }
    }
}
