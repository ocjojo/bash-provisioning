#!/bin/bash

if ! function_exists install_nodejs 2> /dev/null; then
install_nodejs() {
  if is_not_installed "nodejs"; then
    curl -sL https://deb.nodesource.com/setup_11.x | bash -
    apt-get install -y nodejs
  fi
}
fi
