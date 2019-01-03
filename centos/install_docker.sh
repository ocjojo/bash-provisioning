#!/bin/bash

if ! function_exists install_docker 2> /dev/null; then
install_docker() {
  if is_not_installed "docker"; then
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y update
    yum -y install yum-utils device-mapper-persistent-data lvm2 docker-ce
    # install docker-compose
    curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    kick enable docker
    kick start docker
  fi
}
fi
