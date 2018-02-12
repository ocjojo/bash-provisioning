#!/bin/bash

###############################
# secure SSHD_CONFIG
###############################

if ! function_exists secure_sshd 2> /dev/null; then
secure_sshd() {
	# save allowed users for later
	SSH_USERS=$(cat /etc/ssh/sshd_config 2>&1 | grep '^AllowUsers')

	if [[ "$SSH_USERS" == "" ]] || [[ $SSH_USERS =~ ^#.* ]]; then
	  echo "You should have a non root user with SSH Access."
	  echo "Create one and run again"
	  return
	fi
	# standard config
	cat > /etc/ssh/sshd_config_tmp <<_EOF_
	# see http://www.faqs.org/docs/securing/chap15sec122.html for explanation of options

	# default port
	Port 22

	# hostkey files
	HostKey /etc/ssh/ssh_host_ecdsa_key
	HostKey /etc/ssh/ssh_host_ed25519_key
	HostKey /etc/ssh/ssh_host_rsa_key

	# copy paste password, but mostly public key so can and should be short!
	LoginGraceTime 30

	#log for assessing problems in ssh
	LogLevel INFO

	# don't allow remote root login
	PermitRootLogin no

	# print message of the day /etc/motd
	# PrintMotd yes

	# public key authentication
	RSAAuthentication yes

	#disable rhosts
	IgnoreRhosts yes
	RhostsRSAAuthentication no

	# Set this to 'yes' to enable PAM authentication, account processing,
	# and session processing. If this is enabled, PAM authentication will
	# be allowed through the ChallengeResponseAuthentication and
	# PasswordAuthentication.  Depending on your PAM configuration,
	# PAM authentication via ChallengeResponseAuthentication may bypass
	# the setting of "PermitRootLogin without-password".
	# If you just want the PAM account and session checks to run without
	# PAM authentication, then enable this but set PasswordAuthentication
	# and ChallengeResponseAuthentication to 'no'.
	# WARNING: 'UsePAM no' is not supported in Red Hat Enterprise Linux and may cause several
	# problems.
	UsePAM yes

	# disable password authentication
	ChallengeResponseAuthentication no
	PasswordAuthentication no

	# disallow empty passwords, should not be used anyway b/c publickey auth
	PermitEmptyPasswords no

	# predefined remote command used by scp2 and sftp
	Subsystem   sftp    /usr/libexec/openssh/sftp-server

	# log to protected file
	SyslogFacility AUTHPRIV

	# preauthenticate in unprivileged child process
	UsePrivilegeSeparation sandbox

	# checks proper permissions on .ssh dir and files
	StrictModes yes

	# not necessary without GUI
	X11Forwarding no

	# use agent forwarding for git pull, etc.
	AllowAgentForwarding yes

	# whitelist users
	# AllowUsers user1 user2
_EOF_

	# add allowed users back
	echo "$SSH_USERS" >> /etc/ssh/sshd_config_tmp

	mv /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
	mv /etc/ssh/sshd_config_tmp /etc/ssh/sshd_config

	if [[ "$(sshd -t)" == "" ]]; then
		kick restart sshd
		return 1
	else
		echo "error in sshd_config!"
		mv /etc/ssh/sshd_config_backup /etc/ssh/sshd_config
	fi
}
fi
