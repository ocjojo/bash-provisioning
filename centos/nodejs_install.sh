#!/bin/bash

if ! function_exists nodejs_install 2> /dev/null; then
nodejs_install() {
  # NODEJS
  if not_installed "nodejs"; then
    curl -sL https://rpm.nodesource.com/setup_8.x | bash -
    yum install -y nodejs
  fi
}
fi
