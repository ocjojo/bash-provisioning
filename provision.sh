#!/bin/bash

###############################
# Provision
# provides helper functions:
# - function_exists
# - network_check
# - summary
# Sources all helpers (os specific)
###############################

[ -n "$PROVISIONER" ] && return || readonly PROVISIONER=1

function_exists() {
    declare -f -F $1 > /dev/null
    return $?
}

# save for later use
start_seconds="$(date +%s)"
PROV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# FUNCTIONS

network_detection() {
  # Make an HTTP request to google.com to determine if outside access is available
  # to us. If 3 attempts with a timeout of 5 seconds are not successful, then we'll
  # skip a few things further in provisioning rather than create a bunch of errors.
  if [[ "$(wget --tries=3 --timeout=5 --spider --recursive --level=2 http://google.com 2>&1 | grep 'connected')" ]]; then
    echo "Network connection detected..."
    return "Connected"
  else
    echo "Network connection not detected. Unable to reach google.com..."
    return "Not Connected"
  fi
}

network_check() {
  if [[ ! "$(network_detection)" == "Connected" ]]; then
    return ""
  else
  	return 1
  fi
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
  . /etc/os-release

  if [[ "$NAME" == "CentOS Linux" ]]; then
		for f in $PROV_DIR/centos/*.sh; do source $f; done
  fi
fi

# source other files
for f in $PROV_DIR/all/*.sh; do source $f; done
