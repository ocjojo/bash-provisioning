#!/bin/bash

###############################
# Helper
# provides helper functions:
# - function_exists
# - is_internet_available
# - run_install
# - summary
# Sources all helpers (os specific)
###############################

[ -n "$PROVISIONER" ] && return || readonly PROVISIONER=1

# save for later use
start_seconds="$(date +%s)"
HELPER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_DIR="$( cd "$( dirname "$0" )" && pwd )"


# FUNCTIONS

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

is_on_host() {
  if ! function_exists getent; then
    echo "getent not found, assuming to be on local"
    return "1"
  fi
  local HOST_IP=$(getent hosts "$1" | awk '{ print $1 }')
  ifconfig 2>&1 | grep -q $HOST_IP
  # returns 0 if IP is found in ifconfig, truthy value otherwise
  return "$?"
}

is_internet_available() {
  # Make an HTTP request to google.com to determine if outside access is available.
  # Fails, if 3 attempts with a timeout of 5 seconds are not successful
  if [[ "$(wget --tries=3 --timeout=5 --spider --recursive --level=2 http://google.com 2>&1 | grep 'connected')" ]]; then
    echo "Network connection detected..."
    return 1
  else
    echo "Network connection not detected. Unable to reach google.com..."
    return 0
  fi
}

run_install() {
  if ! is_internet_available ; then
    return
  fi
  # Check if a function exists, otherwise install as package
  for pkg in "${install_list[@]}"; do
    if function_exists "install_$pkg"; then
      $("install_$pkg")
    else
      package_check_list+=($pkg)
    fi
  done

  package_install
}

if ! function_exists summary; then
summary() {
	echo " "
	end_seconds="$(date +%s)"
	echo "-----------------------------"
	echo "Provisioning complete in "$(( end_seconds - start_seconds ))" seconds"
}
fi

# source os specific files
if [ -f /etc/os-release ]; then
  source /etc/os-release

  if [[ "$NAME" == "CentOS Linux" ]]; then
		for f in $HELPER_DIR/centos/*.sh; do source $f; done
  fi
fi

# source other files
for f in $HELPER_DIR/all/*.sh; do source $f; done

for f in $(find "$SOURCE_DIR" -name 'install_*.sh'); do source $f; done
