#!/bin/bash

if ! function_exists install_nodejs 2> /dev/null; then
install_nodejs() {
  # NODEJS
  if is_not_installed "nodejs"; then
    curl -sL https://rpm.nodesource.com/setup_11.x | bash -
    yum install -y nodejs
  fi
}
fi
