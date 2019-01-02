#!/bin/bash

jre_install() {
  if [[ -z "$(java -version 2>&1 | grep 'java version')" ]]; then
  	echo "Installing JRE ..."
  	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jre-8u162-linux-x64.rpm" -O jre-x64.rpm
  	yum localinstall -y jre-x64.rpm
    rm -f jre-x64.rpm
  fi
}
