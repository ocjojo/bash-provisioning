
install_composer() {
  # create bin dir if it does not exist yet
  mkdir -p /usr/local/bin

  # Install Composer if it is not yet available.
  if [[ ! -n "$(/usr/local/bin/composer --version --no-ansi | grep 'Composer version')" ]]; then
    echo "Installing Composer..."
    curl -sS "https://getcomposer.org/installer" | php -- --install-dir=/usr/local/bin --filename=composer
  fi

  # Update both Composer and any global packages. Updates to Composer are direct from
  # the master branch on its GitHub repository.
  if [[ -n "$(/usr/local/bin/composer --version --no-ansi | grep 'Composer version')" ]]; then
    echo "Updating Composer..."
    COMPOSER_HOME=/usr/local/src/composer /usr/local/bin/composer self-update
    COMPOSER_HOME=/usr/local/src/composer /usr/local/bin/composer -q global require phpunit/phpunit
    COMPOSER_HOME=/usr/local/src/composer /usr/local/bin/composer -q global config bin-dir /usr/local/bin
    COMPOSER_HOME=/usr/local/src/composer /usr/local/bin/composer global update
  fi
}
