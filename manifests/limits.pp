class limits {

  # nested class/define
  define conf (
    $domain = "root",
    $type = "soft",
    $item = "nofile",
    $value = "10000"
    ) {

      # guid of this entry
      $key = "$domain/$type/$item"

      # augtool> match /files/etc/security/limits.conf/domain[.="root"][./type="hard" and ./item="nofile" and ./value="10000"]

      $context = "/files/etc/security/limits.conf"

      $path_list  = "domain[.=\"$domain\"][./type=\"$type\" and ./item=\"$item\"]"
      $path_exact = "domain[.=\"$domain\"][./type=\"$type\" and ./item=\"$item\" and ./value=\"$value\"]"

      # TODO add duplicate entry cleanup

      augeas { "limits_conf/$key":
         context => "$context",
         onlyif  => "match $path_exact size==0",
         changes => [
           # remove all matching to the $domain, $type, $item, for any $value
           "rm $path_list", 
           # insert new node at the end of tree
           "set domain[last()+1] $domain",
           # assign values to the new node
           "set domain[last()]/type $type",
           "set domain[last()]/item $item",
           "set domain[last()]/value $value",
         ],
       }

  } 

}

