# Shell Provisioning

This provides a collection of shell scripts to simplify provisioning a new server.

## Usage
1. Create a shell script that sources `provision.sh`.
2. Call helper functions.

Sample script `setup.sh`

```bash
#!/bin/bash

echo "MySQL Root Password:"
read MYSQL_ROOT_PW

yum install -y git nano
if [[ ! -d "bash-provisioning" ]]; then
  git clone git@github.com:ocjojo/bash-provisioning.git
else
  cd bash-provisioning && git fetch && git reset --hard origin/master && cd ..
fi

# Packages to install
package_check_list=(
  # PHP
  php71w-fpm
  php71w-common

  # nginx is installed as the default web server
  nginx

  # mariadb as the database
  mariadb-server
)

# extend here ...

# Call other scripts
source ./bash-provisioning/provision.sh
if ! network_check ; then 
	package_install
	secure_mysql $MYSQL_ROOT_PW
	composer_install
	adminer_install "/var/www/adminer"
fi
kick enable nginx php-fpm mariadb
kick restart nginx php-fpm mariadb
summary # Prints a summary
```

You can and should extend the script. e.g. to setup users, configure services (nginx, php-fpm, ..)

## Functions

This is a list of functions `provision.sh` provides:

- `adminer_install /path/to/install/dir` installs adminer
- `composer_install` installs composer and makes it available in $PATH
- `jre_install` installs jre 1.8
- `kick [start|stop|restart|enable|status] service1 [service2 ...]`  
  replacement for systemctl/service extended for multiple services
- `network_check` to check wether internet is available
- `nodejs_install` installs node.js
- `package_install` checks and installs all packages from `package_check_list`
- `secure_mysql <MYSQL_ROOT_PW>` secures the mysql server and configures the root password.
- `secure_sshd` generates a secure sshd_config
- `summary` prints a summary of provisioning time
- `create_ssh_user username [root] [path/to/authorized_keys]` creates a user [with root priviledge] allows ssh login [and adds authorized_keys]

## Contribute
Feel free to contribute by creating issues and/or pull requests.
