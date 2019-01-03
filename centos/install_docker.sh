#!/bin/bash

if ! function_exists install_docker 2> /dev/null; then
install_docker() {
  if is_not_installed "docker"; then
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install docker-ce
    kick enable docker
    kick start docker
  fi
}
fi
