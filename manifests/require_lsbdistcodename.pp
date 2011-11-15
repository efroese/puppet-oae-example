# To fail the complete compilation, include this class
class require_lsbdistcodename inherits assert_lsbdistcodename {
	exec { "false # require_lsbdistcodename": require => Exec[require_lsbdistcodename], }
}
