#!/bin/bash

adminer_install() {
	if [ -z "$1" ]; then
		echo "Please provide a path to install adminer to."
		return
	fi

  if [[ ! -d "$1" ]]; then
    mkdir --parents "$1"
  fi
  if [[ ! -e $1/index.php ]]; then
    wget https://www.adminer.org/latest-mysql.php -O $1/index.php
    wget https://raw.githubusercontent.com/vrana/adminer/master/designs/lucas-sandery/adminer.css -O $1/adminer.css
  fi
}