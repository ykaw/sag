#!/bin/sh

if [ $# -lt 2 ]
then
    echo "usage: $0 rot file1 (file2 ...)" >&2
    exit 1
fi

rot=$1
rot=${rot#*[^0-9]}
[ -z "$rot" ] && exit
shift
f=$1
while [ -n "$f" ]
do
    i=$rot
    while [ 0 -lt $i ]
    do
        fd=`printf "%s-%02d" $f $i`
        j=$((i - 1))
        if [ $j -lt 1 ]
        then
            fs=$f
        else
            fs=`printf "%s-%02d" $f $j`
        fi
        if [ -f $fs ]
        then
            mv -f $fs $fd
        fi
        i=$j
    done
    shift
    f=$1
done
