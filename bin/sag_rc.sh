#!/bin/sh

export SAGHOME=/home/sag

progname=${0##*/}
   ticker="sag_ticker.sh"
ticker_re="[s]ag_ticker.sh"  # to ignore pgrep itself

# print error message to stderr
#
err () {
    echo "$progname: $*" >&2
}

# print error message then exit
#
err_exit () {
    err "$*"
    exit 1
}

# check if sag_ticker.sh already running
#
is_ticker_run () {
    pgrep -f "${ticker_re}"
    return $?
}

cd $SAGHOME || err_exit "cannot cd to $SAGHOME"

case "$1" in
    start)
        ticker_pid=$(is_ticker_run) && err_exit "$ticker is already running"
        $SAGHOME/bin/sag_ticker.sh >> ${SAGHOME}/sag.log 2>&1 &
    ;;
    stop)
        ticker_pid=$(is_ticker_run) || err_exit "$ticker is not running"
        kill -TERM $ticker_pid
        ;;
    status)
        if ticker_pid=$(is_ticker_run); then
            echo "$ticker is running, PID is $ticker_pid"
        else
            echo "$ticker is not running"
        fi
        ;;
    *)
        err "Usage: $progname [start|stop|status]"
        ;;
esac
