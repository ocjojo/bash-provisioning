#!/bin/bash

# Build a bash array to pass all of the packages we want to install to a single
# apt command. This avoids doing all the leg work each time a package is
# set to install. It also allows us to easily comment out or add single
# packages. We set the array as empty to begin with so that we can append
# individual packages to it as required.
package_install_list=()

is_not_installed() {
  dpkg -s "$1" 2>&1 | grep -q 'not installed'
  # returns 0 if string 'not installed' is found, truthy value otherwise
  return "$?"
}

package_check() {
  # Loop through each of our packages that should be installed on the system. If
  # not yet installed, it should be added to the array of packages to install.
  local pkg

  for pkg in "${package_check_list[@]}"; do
    if is_not_installed "${pkg}"; then
      echo " *" "$pkg" [not installed]
      package_install_list+=($pkg)
    else
      dpkg -s "${pkg}"
    fi
  done
}

package_install() {
  package_check

  if [[ ${#package_install_list[@]} = 0 ]]; then
    echo -e "No packages to install.\n"
  else
    # Update all of the package references before installing anything
    echo "Running apt-get update..."
    apt-get -y update

    # Install required packages
    echo "Installing packages..."
    apt-get -y install ${package_install_list[@]}

    # Remove unnecessary packages
    echo "Removing unnecessary packages..."
    apt-get autoremove -y
  fi
}
