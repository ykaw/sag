#!/bin/sh

# print error message to stderr
#
err () {
    echo "${0##*/}: $*" >&2
}

# print error message then exit
#
err_exit () {
    err "$*"
    exit 1
}

# wait until specified sec
#
wait_next_sec () {
    local min="$(date +%S)"
    min="${min#0}"  # strip heading zero
                    # to avoid an error in
                    # next arith. expansion
    if ! sleep $((60 + $1 - min)); then
	err "interval sleep with error"

        # to avoid sleepless loop
        if ! sleep 60; then
            # maybe unrecoverable - bailing out
            err_exit "sleep command failed"
        fi
    fi
}

# driver for data acquision and processing
#
sag_driver () {
    export DAYTIME=$(date +'%Y %m %d %H %M')
    set -- $DAYTIME
    hour="${4#0}"  # strip heading zero
    min="${5#0}"   # strip heading zero

    commands="./bin/t0001"  # without any condition

    # build a command sequence
    #
    [[ $((min % 5)) = 1 ]]      && commands="${commands}; ./bin/t0005"
    [[ "$min" = "50" ]]         && commands="${commands}; ./bin/t0100"
    [[ "$hour:$min" = "3:55" ]] && commands="${commands}; ./bin/t2400"

    /bin/sh -c "$commands"
}

# environment check and setup
#
cd $SAGHOME || err_exit "cannot cd to $SAGHOME"

export LANG=C

# make gap for data absence
#
./bin/addgap

# main loop
#
while :; do
    wait_next_sec 10
    sag_driver
done
