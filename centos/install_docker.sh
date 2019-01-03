#!/bin/bash

if ! function_exists install_docker 2> /dev/null; then
install_docker() {
  if is_not_installed "docker"; then
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y update
    yum -y install yum-utils device-mapper-persistent-data lvm2 docker-ce
    kick enable docker
    kick start docker
  fi
}
fi
