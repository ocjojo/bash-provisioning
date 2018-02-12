#!/bin/bash

secure_mysql() {
  # If MariaDB/MySQL is installed, go through the various imports and service tasks.
  if [[ "mysql: unrecognized service" != "$(kick status mariadb)" ]]; then

    if [ -z "$1" ]; then
      echo "Please provide a root password for mysql."
      return
    fi

    kick restart mariadb

    # MariaDB/MySQL
    # secure sql
    mysql --user=root <<_EOF_
      UPDATE mysql.user SET Password=PASSWORD('${1}') WHERE User='root';
      DELETE FROM mysql.user WHERE User='';
      DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
      DROP DATABASE IF EXISTS test;
      DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
      FLUSH PRIVILEGES;
_EOF_
    
    kick restart mariadb

  else
    echo -e "\nMySQL is not installed."
  fi
}