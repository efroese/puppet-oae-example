class oae::core {

    oae::sling_config { "org/sakaiproject/nakamura/lite/storage/jdbc/JDBCStorageClientPool.config":
        dirname => "org/sakaiproject/nakamura/lite/storage/jdbc",
        pid     => '"org.sakaiproject.nakamura.lite.storage.jdbc.JDBCStorageClientPool"',
        config => {
            'jdbc-driver' => "\"${oae::params::sparsedriver}\"",
            'jdbc-url'    => "\"${oae::params::sparseurl}\"",
            'username'    => "\"${oae::params::sparseuser}\"",
            'password'    => "\"${oae::params::sparsepass}\"",
        }
    }
    
}
