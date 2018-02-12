#!/bin/bash

create_ssh_user() {
	if [[ "$1" == "" ]] ; then
		echo "Usage: create_ssh_user username [root] [path/to/authorized_keys]"
	fi
	user=$1
	shift

	useradd -m $user # create user with home directory
	usermod -s /bin/bash $user # grant shell rights to user
	mkdir --parents /home/$user/.ssh/

	# allow new user in SSH
	SSH_USERS=$(cat /etc/ssh/sshd_config 2>&1 | grep '^AllowUsers')
	if [[ "$SSH_USERS" == "" ]] || [[ $SSH_USERS =~ ^#.* ]]; then
	  echo "AllowUsers $user" >> /etc/ssh/sshd_config
	else
		sed "s/\(^AllowUsers.*\)/\1 $user/" /etc/ssh/sshd_config
	fi

	for arg; do
		if [[ "$arg" == "root" ]] ; then
			echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers	
		fi
		if [[ -f $arg ]]; then
			mv $arg /home/$user/.ssh/
			chown -R $user:$user /home/$user/.ssh/
			chmod 600 /home/$user/.ssh/authorized_keys
		fi
	done
}