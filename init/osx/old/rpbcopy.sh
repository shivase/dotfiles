#!/bin/sh

# -------------------------------------------------
# remoteのclipboardをmacのclipboardにコピーするためのdaemon
# http://blog.glidenote.com/blog/2014/02/22/remote-pbcopy/
#
# sshの設定を弄って実現するので、ssh/configに以下の設定を入れる事
# RemoteForward 2224 127.0.0.1:2224
# -------------------------------------------------

. "$DOTPATH"/etc/lib/vital.sh

e_header "coping pbcopy.plist"
sudo cp -f $DOTPATH/etc/launchctl/pbcopy.plist $HOME/Library/LaunchAgents/
sudo launchctl load -w $HOME/Library/LaunchAgents/pbcopy.plist
e_done "coping pbcopy.plist"
