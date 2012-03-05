class people::devops {
    # non-production nodetype with added devops goodness
	realize(Group['devops'])
	realize(User['jenkins'])
	realize(Ssh_authorized_key['jenkins-home-pub'])
}