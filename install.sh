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

## parameters
     user='sag'
    group="$user"
  SAGHOME="/home/$user"; export SAGHOME
git_repos='https://github.com/ykaw/sag'
  tgz_url='https://fuguita.org/sag/sag.tar.gz'
   editor="${EDITOR:-/usr/bin/vi}"  # set default editor to vi
  install='tgz'  # git or tgz


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

## Are we root?
if [[ "$(whoami)" != "root" ]]; then
    notice 0 "You must be root - please enter your password."
    doas "$0" "$@"
    exit $?
fi

## Need it software
notice 0 "Installing dependencies from package"
if [[ "$install" = "git" ]]; then
    pkg_add git gnuplot--
elif [[ "$install" = "tgz" ]]; then
    pkg_add gnuplot--
else
    exit 1
fi

## remove existing SAG user/group
notice 0 "Creating SAG account: user=$user, group=$group, home=$SAGHOME"
 userinfo -e $user  &&  userdel -r $user
groupinfo -e $group && groupdel $group

## Creation 'sag' usr
useradd -m -G $group -s /bin/ksh -d $SAGHOME $user

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
    tar -xvz -s '|^\./||' -s '|^sag/||' -f sag.tar.gz
    rm sag.tar.gz
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
mkdir $SAGHOME/var
EOF

## As root now we setup the rest

notice 0 "Setting up root's crontab"
if ! crontab -l | fgrep -q 'ntpctl -s all'; then  # to avoid dupulicate append
    (crontab -l; cat $SAGHOME/conf/examples/crontab-root) | crontab -
fi

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
notice 0 "All done."
notice 0 "You need to add the entry on your httpd.conf(8) file."
