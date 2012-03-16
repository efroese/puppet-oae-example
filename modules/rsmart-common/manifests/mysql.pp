#
# = Class rsmart-common::mysql
# Common space for mysql configurations.
# 
class rsmart-common::mysql {

    # Config changes to be applied to MySQL CLE servers
    $cle_changes = [
        # general settings
        "set default-storage-engine InnoDB",
        "set character_set_server   UTF8",
        "set transaction_isolation  READ-COMMITTED",
        "set wait_timeout           3600",
        "set interactive_timeout    3600",
        "set lower_case_table_names 1",

        # network-related settings
        # "set skip_name_resolve  1",
        "set back_log			  500",
        "set max_connections	  750",
        "set max_connect_errors 1000",
        "set max_allowed_packet 128M",

        # logging
        "set slow_query_log_file /var/log/mysql/mysqld-slow.log",
        "set log_error           /var/log/mysql/mysql-errors.log",
        # "set log_bin             /var/lib/mysql/binlogs/mysqld-binlog",
        # "set log_bin_index       /var/lib/mysql/binlogs/mysqld-binlog",
        # "set binlog_format          MIXED",
        "set expire_logs_days     7",
        "set sync_binlog          0",

        # Replication (for future use, possibly)
        "set server_id 10",

        # general buffers and caches
        "set max_heap_table_size      64M",
        "set tmp_table_size           64M",
        "set sort_buffer_size         4M",
        "set join_buffer_size         2M",
        "set key_buffer_size          64M",
        "set read_buffer_size         2M",
        "set read_rnd_buffer_size     1M",
        "set bulk_insert_buffer_size  128M",
        "set table_cache              4096",
        "set thread_cache_size        32",
    ]
}