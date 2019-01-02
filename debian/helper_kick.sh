#!/bin/bash

function kick() {
	case "$1" in
    start|stop|restart|enable|status) cmd=$1 ;;
    *)
        shift
        servicenames=${@-servicenames}
        echo "usage: kick [start|stop|restart|enable|status] $servicenames"
        return
	esac
	shift

	for name; do
		systemctl $cmd $name
	done
}