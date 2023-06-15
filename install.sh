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

notice () {
    local wait=$1; shift
    if [[ 1 -le $wait ]]; then
        clear
        echo "##" "$@"
        sleep $wait
    else
	echo "##" "$@"
    fi
}

## Are we root?
if [[ "$(whoami)" != "root" ]]; then
    notice 0 "You must be root - please enter your password."
    doas "$0" "$@"
    exit $?
fi

## Need it software
notice 0 "Installing dependencies from package"
pkg_add git gnuplot--

## constants
     user=sag
    group=$user
  SAGHOME=/home/$user; export SAGHOME
git_repos=https://github.com/ykaw/sag
editor=${EDITOR:-/usr/bin/vi}  # set default editor to vi
# export SAGHOME=/var/log/sag  # for debug

## remove existing SAG user/group
notice 0 "Creating SAG account: user=$user, group=$group, home=$SAGHOME"
 userinfo -e $user  &&  userdel -r $user
groupinfo -e $group && groupdel $group

## Creation 'sag' usr
useradd -m -G $group -s /bin/ksh -d $SAGHOME $user

## Cloning sag code with sag usr
notice 0 "Retrieving SAG source from the repository"
su - $user <<EOF
if cd $SAGHOME; then
    git clone $git_repos

    ## Put the files in order
    mv sag/.git sag/* $SAGHOME && rmdir sag
    ln -s $(which gnuplot) $SAGHOME/bin
    cp $SAGHOME/conf/examples/dfplot.gp \
       $SAGHOME/conf/examples/netcmd.sh \
       $SAGHOME/conf/examples/postgproc.sh \
       $SAGHOME/conf/examples/shconf.sh \
       $SAGHOME/conf
else
    exit 1
fi
EOF

## Editing files
(cat <<EOF
#
# Edit the gnuplot configuration above to match the actual file system
# layout shown below.
#
EOF
 df -h | awk '1==NR{print "# gnuplot   | ", $0} 2<=NR{print "#", "using 1:"NR+1" | ", $0}' ) >> $SAGHOME/conf/dfplot.gp
notice 5 "Edit dfplot.gp - specify disk partitions to plot, if necessary."
su - $user -c "$editor $SAGHOME/conf/dfplot.gp"

notice 5 "Edit netcmd.sh - specify the network interface to plot."
su - $user -c "$editor $SAGHOME/conf/netcmd.sh"

notice 5 "Edit shconf.sh - specify spans to archive logs and plot graphs."
su - $user -c "$editor $SAGHOME/conf/shconf.sh"

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
notice 5 "Edit a script to copy graphs to Web. if not needed, leave this untouched."
su - $user -c "$editor $SAGHOME/conf/postgproc.sh"

## Warning about add httpd(8)
notice 1 "All done."
notice 0 ""
notice 0 "You need to add the entry on your httpd.conf(8) file."
notice 0 ""
