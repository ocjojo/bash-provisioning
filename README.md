# Shell Provisioning

This provides a collection of shell scripts to simplify provisioning a new server.

## Usage

1. Create a shell script that sources `helper.sh`.
2. add packages to install to `install_list`
3. call `run_install` and optionally `summary`

Depending on the packages you install additional configuration may be necessary.
The scripts will ask you to provide that configuration, if necessary.

### Sample script `provision.sh`

```bash
#!/bin/bash

# clone scripts if they are missing
if [[ ! -d "bash-provisioning" ]]; then
  git clone git@github.com:ocjojo/bash-provisioning.git
else
  cd bash-provisioning && git fetch && git reset --hard origin/master && cd ..
fi
source ./bash-provisioning/provision.sh

# Packages to install
install_list=(
  nodejs
)

run_install
summary # Prints a summary
```

You can and should extend the script. e.g. to setup users, configure services (nginx, php-fpm, ..)

You can create arbitrary shell functions named `install_*` within the current dir and add them to `install_list`.

## Functions

The following helper functions are provided. They are platform independent and can be used to create install functions.

- `kick [start|stop|restart|enable|status] service1 [service2 ...]`  
  replacement for systemctl/service extended for multiple services
- `is_internet_available` to check wether internet is available
- `summary` prints a summary of provisioning time
- `create_ssh_user username [root] [path/to/authorized_keys]` creates a user [with root priviledge] allows ssh login [and adds authorized_keys]
- `secure_mysql <MYSQL_ROOT_PW>` secures the mysql server and configures the root password.
- `secure_sshd` generates a secure sshd_config

Additionally the following platform independent install functions exist. They can be added to the `install_list` without the `install_` prefix.

- `install_nodejs` installs node.js
- `install_adminer /path/to/install/dir` installs adminer
- `install_composer` installs composer and makes it available in \$PATH
- `install_jre` installs jre 1.8

## Contribute

Feel free to contribute by creating issues and/or pull requests.
