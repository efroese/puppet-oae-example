define selinux::seport($ensure='present', $proto='tcp', $port) {

  # this is dreadful to read, sorry...

  $re = "^${name}\W+${proto}\W+.*\W${port}(\W|$)"

  if $ensure == "present" {
    $semanage = "--add"
    $grep     = "egrep -q"
  } else {
    $semanage = "--delete"
    $grep     = "! egrep -q"
  }

  exec { "semanage port ${port}, proto ${proto}, type ${name}":
    command => "semanage port ${semanage} --tyle ${name} --proto ${proto} ${port}",
    onlyif  => "semanage port --list | $( ${grep} '${proto}' )", # subshell required to invert return status with !
  }


}
