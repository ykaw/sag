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

## Are we root?
if test "$(whoami)" != root; then
	doas "$0" "$@"
	exit $?
fi

## Need it software
pkg_add git gnuplot--

## Handling errors
error() {
	echo "Error: $1" >&2
	exit 1
}

## constants
     user=sag
    group=$user
  SAGHOME=/home/$user; export SAGHOME
git_repos=https://github.com/ykaw/sag
editor=${EDITOR:-/usr/bin/vi}  # set default editor to vi
# export SAGHOME=/var/log/sag  # for debug

## remove existing SAG user/group
 userinfo -e $user  &&  userdel -r $user
groupinfo -e $group && groupdel $group

## Creation 'sag' usr
useradd -m -G $group -s /bin/ksh -d $SAGHOME $user

su - $user <<EOF
## Cloning sag code with sag usr
if cd $SAGHOME; then
    git clone $git_repos

    ## Put the files in order
    mv sag/.git sag/* $SAGHOME && rmdir sag
    ln -s $(which gnuplot) $SAGHOME/bin
    ls -l $SAGHOME/bin
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
su - $user -c "$editor $SAGHOME/conf/dfplot.gp"
su - $user -c "$editor $SAGHOME/conf/netcmd.sh"
su - $user -c "$editor $SAGHOME/conf/shconf.sh"

su - $user <<EOF
## Graph drawing related setup
cp $SAGHOME/plot/examples/common.gp \
   $SAGHOME/plot/examples/gen* \
   $SAGHOME/plot
mkdir $SAGHOME/var
EOF

## As root now we setup the rest

if ! crontab -l | fgrep -q 'ntpctl -s all'; then  # to avoid dupulicate append
    (crontab -l; cat $SAGHOME/conf/examples/crontab-root) | crontab -
fi

if ! fgrep -q '# for System Activity Grapher' /etc/rc.local; then  # to avoid dupulicate append

    cat $SAGHOME/conf/examples/rc.local >> /etc/rc.local
    sed -i -e "s|PATH-TO-CMD/bin/addgap|$SAGHOME/bin/addgap|" /etc/rc.local
fi

crontab -u $user -r 2>/dev/null || true # to clear crontab if exists
sed -e "s|^SAGHOME=.*|SAGHOME=$SAGHOME|" $SAGHOME/conf/examples/crontab | crontab -u $user -

## Web related settings
mkdir -p /var/www/htdocs/sag
cp $SAGHOME/conf/examples/index.html /var/www/htdocs/sag
chown -R ${user}:${group} /var/www/htdocs/sag

## As sag we finishing the last edits
su - $user -c "$editor $SAGHOME/conf/postgproc.sh"

## Warning about add httpd(8)
printf "*** You need to add the entry on your httpd.conf(8) file ***\n"
