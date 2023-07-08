#!/bin/sh

# sagrename.sh - rename old logfile to new one
# $Id: sagrename.sh,v 1.1 2023/07/08 20:47:14 kaw Exp $

# error messages to stderr
#
errmsg () {
    echo "$@" >&2
}

# set files to process
#
if [[ -n "$1" ]]; then
    # files specified
    files="$@"
else
    # default files: no files specified
    files="rl????-???.gz"
    if ! ls -1d $files >/dev/null 2>&1; then
        errmsg "${0##*/}: No files to process"
        exit 1
    fi
fi

for log in $files
do
    # check file exsitence
    #
    if [[ ! -r "$log" ]] then
        errmsg "$log - can't read this"
        continue
    fi

    # find and set (last) timestamp
    #
    set -- $(zgrep '^=dt [1-9][0-9][0-9][0-9] [0-9][0-9] [0-9][0-9] [0-9][0-9] [0-9][0-9]$' "$log" | tail -n 1)
    daytime="$2$3$4"  # YYYYMMDD

    if [[ -z "$daytime" ]]; then  # no timestamp in the logfile
        errmsg "$log - timestamp not found"
	continue
    fi

    newlog="${log%%-*.gz}-${daytime}.gz"

    if [[ "$log" = "$newlog" ]]; then
        errmsg "$log - identical, no need to rename"
	continue
    fi

    # output sh commands for renaming to stdout
    # for real process, pipe this to /bin/sh
    echo mv "\"$log\"" "\"$newlog\""
done
