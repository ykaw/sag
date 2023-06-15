#!/bin/sh

##
## Early version of installer, still needs more adjustments
## and checks but for now it does the hardwork.
##
## Read the file INSTALL-{JP,EN}.md for more details
##

## DEBUG
#set -x

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

## Creation 'sag' usr
useradd -m -G sag -s /bin/ksh sag

## Cloning sag code with sag usr
su - sag -c "cd /home/sag && git clone https://github.com/ykaw/sag"

## Put the files in order
su - sag -c "mv sag/.git sag/* ~ && rmdir sag"
su - sag -c "ln -s /usr/local/bin/gnuplot ~/bin"
su - sag -c "ls -l ~/bin"
su - sag -c "cd ~/conf && cp examples/dfplot.gp examples/netcmd.sh examples/postgproc.sh examples/shconf.sh ."

## Editing files
df && \
sleep 10 && \
su - sag -c "cd ~/conf && $EDITOR dfplot.gp"
su - sag -c "cd ~/conf && $EDITOR netcmd.sh"
su - sag -c "cd ~/conf && $EDITOR shconf.sh"

## Graph drawing related setup
su - sag -c "cd ~/plot && cp examples/common.gp examples/gen* ."
su - sag -c "mkdir ~/var"

## As root now we setup the rest
cd ~sag/conf/examples/
crontab -l > crontab.orig
cat crontab.orig crontab-root | crontab -
cat rc.local >> /etc/rc.local
$EDITOR /etc/rc.local
crontab -u sag ~sag/conf/examples/crontab
mkdir /var/www/htdocs/sag
cp /home/sag/conf/examples/index.html /var/www/htdocs/sag
chown -R sag:sag /var/www/htdocs/sag

## As sag we finishing the last edits
su - sag -c "$EDITOR ~/conf/postgproc.sh"

## Warning about add httpd(8)
printf "*** You need to add the entry on your httpd.conf(8) file ***\n"

