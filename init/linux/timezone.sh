#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

e_newline
e_header "Modify timezone to Asia/Tokyo"

sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

cat << EOL | sudo tee /etc/sysconfig/clock
ZONE="Asia/Tokyo"
UTC=true
EOL

e_done "Modified timezone to Asia/Tokyo"

e_header "rebooting crond..."
sudo service crond restart
e_done "crond rebooted"
