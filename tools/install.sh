#!/bin/sh

##
## Early version of installer, still needs more adjustments
## and checks but for now it does the hardwork.
##
## Read the file INSTALL-{JP,EN}.md for more details
##
## initially written by gonzalo (@x61sh at Twitter)
##

## DEBUG
#set -x
set -e

#-------------------
# echo to stderr
#
echo2 () {
    echo "$@" >&2
}

#-------------------
# ask user yes or no
# outputs answer to stdout
#
#     usage: ask_yn prompt yn
#
#       yn ... y: defaults to yes
#              n: defaults to no
#              r: no default ... ask again
#              else: no default ... return -1 if answered not yn
#
#       output ... 1: yes, 0: no, -1: else yn, -2: error occured
#
function ask_yn {

    if [ -z "$2" ]; then
        echo -2
        return
    fi

    local prompt="$1"; shift
    local yn_default="$1"; shift
    local yn_ans

    case X"$yn_default"X in
        X[Yy]X) yn_default=Y; prompt="$prompt [Y/n] -> " ;;
        X[Nn]X) yn_default=N; prompt="$prompt [y/N] -> " ;;
        X[Rr]X) yn_default=R; prompt="$prompt [y/n] -> " ;;
        *)      yn_default=E; prompt="$prompt [y/n] -> " ;;
    esac

    while :; do
        echo2 -n "$prompt"; read yn_ans

        case X"$yn_ans"X in
            X[Yy]X) echo 1; return;;
            X[Nn]X) echo 0; return;;
            XX)
                case X"$yn_default"X in
                    XYX) echo 1;  return;;
                    XNX) echo 0;  return;;
                    XRX) continue;;
                    *)   echo -1; return;;
                esac;;
            *)
                continue;;
        esac
    done
}

#-------------------
# ask selection out of multiple items
# outputs answer to stdout
#
#     usage: ask_which prompt default item1 item2 ...
#
#       Note: although user's choice is one originated
#             default is zero originated
#
#       output: first word of selected item
#               returns empty line unless selected normally
#
function ask_which {
    if [ $# -lt 3 ]; then
        return
    fi

    local prompt="$1";  shift
    local default="$1"; shift
    local i item val

    # skip null item
    #
    i=0
    for val in "$@"; do
        if [ -n "$val" ]; then
           item[$i]="$val"
           i=$((i+1))
        fi
    done

    # only one item is default itself
    #
    [ "${#item[@]}" = 1 ] && default=${item[0]}

    i=0
    while [ -n "${item[$i]}" ]; do
        if [ "$default" = "${item[$i]}" ]; then
            OIFS="$IFS"
            IFS= prompt="$prompt\n"`printf '%3d: [%s]' $((i+1)) ${item[$i]}`
            IFS="$OIFS"
        else
            OIFS="$IFS"
            IFS= prompt="$prompt\n"`printf '%3d:  %s' $((i+1)) ${item[$i]}`
            IFS="$OIFS"
        fi
        i=$((i+1))
    done
    echo "$prompt" >&2

    local ans
    ans=`rl_wread '' ''`

    # take first argument
    #
    set -- $ans
    ans=$1
    
    # return selected item
    #
    if expr "$ans" : '^[0-9][0-9]*$' >/dev/null && \
       [ "$ans" -le ${#item[@]} ]; then
        set -- ${item[$((ans-1))]}
        echo $1
    elif [ -n "$default" -a -z "$ans" ]; then
        set -- $default
        echo $1
    fi
}

#-------------------
# read user's input with readline functionality
# outputs echoed to stdout
#
#     usage: rl_wread prompt-str default-str [completion words ....]
#
function rl_wread {
    local prompt="$1";  shift
    local default="$1"; shift
    local retval

    # check if rlwrap is available
    #   When control tty is missing (in /etc/rc.shutdown for example),
    #   rlwrap in command substitution "$(rlwrap ...) " fails.
    if retval=$(/usr/local/bin/rlwrap true) 2>/dev/null; then
        echo "$@" > $lockdir/rl_words
        rlwrap -b '' \
               -f $lockdir/rl_words \
               -P "$default" \
               sh -f -c 'echo -n "'"$prompt"'->" >&2 ; read w || echo EOF; echo $w' || echo RL_ERR
    else
        #-------------------
        # fallback to dumb input
        #
        if [ X"$default" = X ]; then
            echo -n "${prompt}->" >&2
            read w
        else
            echo -n "$prompt [$default] -> " >&2
            read w
            if [ X"$w" = X ]; then
              w="$default"
            fi
        fi
        echo $w
    fi
}

#-------------------
# output notice message
#   usage: notice cmd messages...
#
#   if cmd is "yn", the answer will
#   output to stdout
#
notice () {
    local cmd=$1; shift
    case "$cmd" in
	"c")
            clear >&2
            echo2 "==== $@";;
	"yn")
	    echo $(ask_yn "==== $@" n);;
	*)
            echo2 "==== $@";;
    esac
}

#=======================
# Active Code from here
#=======================

## Are we root?
if [[ "$(whoami)" != "root" ]]; then
    notice 0 "You must be root."
    exit 1
fi

## lock installtion process
lockdir=/tmp/saginstall_lock
if ! mkdir "$lockdir"; then
    notice 0 "Another installer runninng, or remove ${lockdir}."
    exit 1
fi
trap "rmdir $lockdir" EXIT

## parameters
     user='sag'
    group="$user"
  SAGHOME="/home/$user"; export SAGHOME
git_repos='https://github.com/ykaw/sag'
  tgz_url='https://fuguita.org/sag/sag.tar.gz'
   editor="${EDITOR:-/usr/bin/vi}"  # set default editor to vi
  install='localtgz'    # git, tgz or localtgz
scheduler=$(ask_which 'Select installation type:' 'standalone' 'cron' 'standalone')

## Check SAG data already exists
if [[ -e $SAGHOME ]]; then
    notice 0 "$SAGHOME already exists"
    mvhome=${SAGHOME}_$(date +%s)_$$
    if [[ $(notice yn "Backup $SAGHOME, then proceed install?") -eq 1 ]]; then
	mv $SAGHOME $mvhome
	notice 0 "$SAGHOME renamed as $mvhome"
    else
	exit 0
    fi
fi

## Need it software
notice 0 "Installing dependencies from package"
case "$install" in
    git)
        pkg_add git gnuplot--
        ;;
    tgz|localtgz)
        pkg_add gnuplot--
        ;;
    *)
        exit 1
        ;;
esac

## remove existing SAG user/group
notice 0 "Creating SAG account: user=$user, group=$group, home=$SAGHOME"
 userinfo -e $user  &&  userdel -r $user
groupinfo -e $group && groupdel $group

## Creation 'sag' user
useradd -m -G $group -s /bin/sh -d $SAGHOME $user

if [[ "$install" = "git" ]]; then
    ## Cloning sag code with sag usr
    notice 0 "Retrieving SAG source from the repository"
    su - $user <<EOF
if cd $SAGHOME; then
    git clone $git_repos
    mv sag/.git sag/* .
    rmdir sag
else
    exit 1
fi
EOF
elif [[ "$install" = "tgz" ]]; then
    ## Downloading sag tarball from fuguita.org
    notice 0 "Downloading SAG tarball"
    su - $user <<EOF
if cd $SAGHOME; then
    ftp $tgz_url

    ## Put the files in order
    tar -xz -s '|^\./||' -s '|^sag/||' -f sag.tar.gz
    rm sag.tar.gz
else
    exit 1
fi
EOF
elif [[ "$install" = "localtgz" ]]; then
    ## mainly for debugging
    notice 0 "Extracting sag.tar.gz at current working directory"
    ocwd=$(pwd)
    su - $user <<EOF
if cd $SAGHOME; then
    cat ${ocwd}/sag.tar.gz | tar -xz -s '|^\./||' -s '|^sag/||' -f -
else
    exit 1
fi
EOF
else
    exit 1
fi
notice 0 "SAG tarball extracted"

su - $user <<EOF
if cd $SAGHOME; then
    ## make a symlink to gnuplot
    ln -sf $(which gnuplot) bin
    ## copy template files to real location
    cp $SAGHOME/conf/examples/dfplot.gp \
       $SAGHOME/conf/examples/netcmd.sh \
       $SAGHOME/conf/examples/postgproc.sh \
       $SAGHOME/conf/examples/shconf.sh \
       $SAGHOME/conf
else
    exit 1
fi
EOF

## generate a template of dfplot.gp
(df | awk '
BEGIN { printf("plot") }
3<=NR { printf(",") }
2<=NR { printf(" \\\n    \"sumtmp-0100df\" using 1:%d title \"%s\"",
               NR+1,
               $6) }
END { printf("\n") }'
 cat <<EOF
#
# Edit the gnuplot configuration above to match the actual file system
# layout shown below.
#
# You can rearrange or delete the configuration lines as you wish.
#
EOF
 df -h | sed -e 's/^/# /' ) > $SAGHOME/conf/dfplot.gp
                            # This redirection is for preserve file attributes.

notice 0 "Here is generated dfplot.gp"
cat $SAGHOME/conf/dfplot.gp
if [[ $(notice yn "Edit this file?") -eq 1 ]]; then
    su - $user -c "$editor $SAGHOME/conf/dfplot.gp"
fi

## find appropriate network interface
netdev=$(ifconfig -a | awk '
BEGIN            { FS=":" }
/^[a-z]/         { iface=$1 }
/groups: egress/ { egress=iface }
/mtu 1500/       { otherdev=iface }
END { if (egress=="") {
          print otherdev
      } else {
          print egress
      }
    }')
if [[ -n "$netdev" ]]; then
    # replace template to the device found
    su - $user -c "sed -i -e 's/bce0/$netdev/' $SAGHOME/conf/netcmd.sh"
fi
notice 0 "Here is generated netcmd.sh"
cat $SAGHOME/conf/netcmd.sh
if [[ $(notice yn "Edit this file?") -eq 1 ]]; then
    su - $user -c "$editor $SAGHOME/conf/netcmd.sh"
fi

notice 0 "Here is shconf.sh"
cat $SAGHOME/conf/shconf.sh
if [[ $(notice yn "Edit this file?") -eq 1 ]]; then
    su - $user -c "$editor $SAGHOME/conf/shconf.sh"
fi

notice 0 "Preparing stuffs to aggregate and plot data"
su - $user <<EOF
## Graph drawing related setup
cp $SAGHOME/plot/examples/common.gp \
   $SAGHOME/plot/examples/gen* \
   $SAGHOME/plot
mkdir -p $SAGHOME/var
EOF

## As root now we setup the rest
notice 0 "Setting up root's crontab"
if ! crontab -l | fgrep -q 'ntpctl -s all'; then  # to avoid dupulicate append
    (crontab -l; cat $SAGHOME/conf/examples/crontab-root) | crontab -
fi

if [[ "$scheduler" = "cron" ]]; then
    notice 0 "Setting up the startup file"
    if [[ -f /etc/rc.local ]] \
           && fgrep -q '# for System Activity Grapher' /etc/rc.local; then  # to avoid dupulicate append
        :  # rc.local set up already - do nothing
    else
        cat $SAGHOME/conf/examples/rc.local >> /etc/rc.local
        sed -i -e "s|PATH-TO-CMD/bin/addgap|$SAGHOME/bin/addgap|" /etc/rc.local
    fi

    notice 0 "Setting up ${user}'s crontab"
    crontab -u $user -r 2>/dev/null || true # to clear crontab if exists
    sed -e "s|^SAGHOME=.*|SAGHOME=$SAGHOME|" $SAGHOME/conf/examples/crontab | crontab -u $user -

    chmod 0644 $SAGHOME/bin/t[0-9][0-9][0-9][0-9]
elif [[ "$scheduler" = "standalone" ]]; then
    notice 0 "Setting up the startup file"
    cat <<EOF >> /etc/rc.local
# for System Activity Grapher

# setups for ntp monitoring
#
touch /tmp/ntpctl.out
chown sag:sag /tmp/ntpctl.out
chmod 0640 /tmp/ntpctl.out

# starting up SAG
su -l sag -c '/home/sag/bin/sag_rc.sh start'
EOF
    chmod 0744 $SAGHOME/bin/t[0-9][0-9][0-9][0-9]
fi

## Web related settings
notice 0 "Setting up web-related stuffs"
mkdir -p /var/www/htdocs/sag
cp $SAGHOME/conf/examples/index.html /var/www/htdocs/sag
chown -R ${user}:${group} /var/www/htdocs/sag

## As sag we finishing the last edits
notice 0 "Here is postgproc.sh, a script to copy graphs to Web. if not needed, leave this untouched."
cat $SAGHOME/conf/postgproc.sh
if [[ $(notice yn "Edit this file?") -eq 1 ]]; then
    su - $user -c "$editor $SAGHOME/conf/postgproc.sh"
fi

## Warning about add httpd(8)
notice 0 ""
notice 0 "You need to add the entry on your httpd.conf(8) file."

## startup SAG with standalone mode
if [[ "$scheduler" = standalone ]]; then
    notice 0 ""
    if [[ $(notice yn "start SAG now?") -eq 1 ]]; then
        su - $user -c "$SAGHOME/bin/sag_rc.sh start"
        sleep 5
        su - $user -c "$SAGHOME/bin/sag_rc.sh status"
    else
        notice 0 "SAG will be active since subsequent boot."
    fi
fi
