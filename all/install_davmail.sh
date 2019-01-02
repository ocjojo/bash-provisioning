#!/bin/bash

install_davmail() {

	if [[ ! -d "/usr/local/src/davmail" ]]; then
		echo "installing davmail..."
		# URL from http://davmail.sourceforge.net/download.html
		curl "https://phoenixnap.dl.sourceforge.net/project/davmail/davmail/4.8.3/davmail-4.8.3-2554.zip" -O "davmail.zip"
		unzip davmail.zip -d /usr/local/src/davmail
		rm -f davmail.zip
	fi

	if [ -z "$1" ]; then
    echo "Please provide a base exchange url for davmail."
    return
  fi

	# standard config
	cat > /etc/davmail.properties <<_EOF_
# DavMail settings, see http://davmail.sourceforge.net/ for documentation

#############################################################
# Basic settings

# Server or workstation mode
davmail.server=true
# connection mode auto, EWS or WebDav
davmail.enableEws=auto
# base Exchange OWA or EWS url
davmail.url=${1}

# Listener ports
davmail.caldavPort=1080
davmail.imapPort=1143
davmail.ldapPort=1389
davmail.popPort=1110
davmail.smtpPort=1025

#############################################################
# Network settings

# Network proxy settings
davmail.enableProxy=false
davmail.useSystemProxies=false
davmail.proxyHost=
davmail.proxyPort=
davmail.proxyUser=
davmail.proxyPassword=

# proxy exclude list
davmail.noProxyFor=

# allow remote connection to DavMail
davmail.allowRemote=true
# bind server sockets to a specific address
davmail.bindAddress=
# client connections SO timeout in seconds
davmail.clientSoTimeout=

# DavMail listeners SSL configuration
davmail.ssl.keystoreType=
davmail.ssl.keystoreFile=
davmail.ssl.keystorePass=
davmail.ssl.keyPass=

# Accept specified certificate even if invalid according to trust store
davmail.server.certificate.hash=

# disable SSL for specified listeners
davmail.ssl.nosecurecaldav=false
davmail.ssl.nosecureimap=false
davmail.ssl.nosecureldap=false
davmail.ssl.nosecurepop=false
davmail.ssl.nosecuresmtp=false

# disable update check
davmail.disableUpdateCheck=true

# Send keepalive character during large folder and messages download
davmail.enableKeepalive=false
# Message count limit on folder retrieval
davmail.folderSizeLimit=0
# Default windows domain for NTLM and basic authentication
davmail.defaultDomain=

#############################################################
# Caldav settings

# override default alarm sound
davmail.caldavAlarmSound=
# retrieve calendar events not older than 90 days
davmail.caldavPastDelay=90
# WebDav only: force event update to trigger ActiveSync clients update
davmail.forceActiveSyncUpdate=false

#############################################################
# IMAP settings

# Delete messages immediately on IMAP STORE \Deleted flag
davmail.imapAutoExpunge=true
# Enable IDLE support, set polling delay in minutes
davmail.imapIdleDelay=
# Always reply to IMAP RFC822.SIZE requests with Exchange approximate message size for performance reasons
davmail.imapAlwaysApproxMsgSize=

#############################################################
# POP settings

# Delete messages on server after 30 days
davmail.keepDelay=30
# Delete messages in server sent folder after 90 days
davmail.sentKeepDelay=90
# Mark retrieved messages read on server
davmail.popMarkReadOnRetr=false

#############################################################
# SMTP settings

# let Exchange save a copy of sent messages in Sent folder
davmail.smtpSaveInSent=true

#############################################################
# Loggings settings

# log file path, leave empty for default path
davmail.logFilePath=/var/log/davmail.log
# maximum log file size, use Log4J syntax, set to 0 to use an external rotation mechanism, e.g. logrotate
davmail.logFileSize=1MB
# log levels
log4j.logger.davmail=WARN
log4j.logger.httpclient.wire=WARN
log4j.logger.org.apache.commons.httpclient=WARN
log4j.rootLogger=WARN

#############################################################
# Workstation only settings

# smartcard access settings
davmail.ssl.pkcs11Config=
davmail.ssl.pkcs11Library=

# SSL settings for mutual authentication
davmail.ssl.clientKeystoreType=
davmail.ssl.clientKeystoreFile=
davmail.ssl.clientKeystorePass=

# disable all balloon notifications
davmail.disableGuiNotifications=false
# disable startup balloon notifications
davmail.showStartupBanner=true

# enable transparent client Kerberos authentication
davmail.enableKerberos=false

_EOF_

	# create service
	cat > /etc/init.d/davmail <<_EOF_
#! /bin/sh
### BEGIN INIT INFO
# Provides:          davmail
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: DavMail Exchange gatway
# Description:       A gateway between Microsoft Exchange and open protocols.
### END INIT INFO

# Author: Jesse TeKrony <jesse ~at~ jtekrony ~dot~ com>

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Davmail Exchange gateway"
NAME=davmail
CONFIG=/etc/davmail.properties
DAEMON=/usr/local/src/davmail/davmail.sh
DAEMON_ARGS="\$CONFIG"
PIDFILE=/var/run/\$NAME.pid
SCRIPTNAME=/etc/init.d/\$NAME
LOGFILE=/var/log/davmail.log

# Exit if the package is not installed
[ -x "\$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/\$NAME ] && . /etc/default/\$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
    start-stop-daemon --start --quiet --pidfile \$PIDFILE --exec \$DAEMON --test > /dev/null \
        || return 1
    start-stop-daemon --start --quiet --pidfile \$PIDFILE --exec \$DAEMON -- \
        \$DAEMON_ARGS >> \$LOGFILE 2>&1 &
    [ \$? != 0 ] && return 2
    echo \$! > \$PIDFILE
    exit 0
}

#
# Function that stops the daemon/service
#
do_stop()
{
    start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile \$PIDFILE
    RETVAL="\$?"
    [ "\$RETVAL" = 2 ] && return 2.
    start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec \$DAEMON
    [ "\$?" = 2 ] && return 2
    rm -f \$PIDFILE
    return "\$RETVAL"
}

case "\$1" in
  start)
    [ "\$VERBOSE" != no ] && log_daemon_msg "Starting \$DESC" "\$NAME"
    do_start
    case "\$?" in
        0|1) [ "\$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "\$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  stop)
    [ "\$VERBOSE" != no ] && log_daemon_msg "Stopping \$DESC" "\$NAME"
    do_stop
    case "\$?" in
        0|1) [ "\$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "\$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  status)
       status_of_proc "\$DAEMON" "\$NAME" && exit 0 || exit \$?
       ;;
  restart|force-reload)
    log_daemon_msg "Restarting \$DESC" "\$NAME"
    do_stop
    case "\$?" in
      0|1)
        do_start
        case "\$?" in
            0) log_end_msg 0 ;;
            1) log_end_msg 1 ;; # Old process is still running
            *) log_end_msg 1 ;; # Failed to start
        esac
        ;;
      *)
        # Failed to stop
        log_end_msg 1
        ;;
    esac
    ;;
  *)
    echo "Usage: \$SCRIPTNAME {start|stop|status|restart| force-reload}" >&2
    exit 3
    ;;
esac

_EOF_
	chmod +x /etc/init.d/davmail
}