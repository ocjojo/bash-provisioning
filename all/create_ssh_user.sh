#!/bin/bash

create_ssh_user() {
	if [[ "$1" == "" ]] ; then
		echo "Usage: create_ssh_user username [root] [path/to/authorized_keys]"
		return
	fi
	user=$1
	shift

	echo "Creating user $user"
	useradd -m $user # create user with home directory
	usermod -s /bin/bash $user # grant shell rights to user
	mkdir --parents /home/$user/.ssh/

	# allow new user in SSH
	SSH_USERS=$(cat /etc/ssh/sshd_config 2>&1 | grep '^AllowUsers')
	if [[ "$SSH_USERS" == "" ]]; then
		echo "Adding $user to sshd_config."
	  echo -e "\nAllowUsers $user" >> /etc/ssh/sshd_config
	elif ! [[ $SSH_USERS =~ .*$user.* ]] ; then
		sed -i "s/\(^AllowUsers.*\)/\1 $user/" /etc/ssh/sshd_config
	fi

	for arg; do
		if [[ "$arg" == "root" ]] && [[ -z "$(cat /etc/sudoers 2>&1 | grep ^$user)" ]] ; then
			echo "Adding $user to sudoers."
			echo -e "\n$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers	
		fi
		if [[ -f $arg ]]; then
			echo "copying authorized_keys from $arg"
			mv $arg /home/$user/.ssh/
			chown -R $user:$user /home/$user/.ssh/
			chmod 600 /home/$user/.ssh/authorized_keys
		fi
	done
}