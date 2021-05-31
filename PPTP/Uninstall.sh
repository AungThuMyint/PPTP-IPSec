#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
	echo "Run as root"
	exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TMPFILE=$(mktemp crontab.XXXXX)
crontab -l > $TMPFILE

sed -i -e "\@/etc/iptables.rules@d" $TMPFILE
sed -i -e "\@/etc/ppp/checkserver.sh@d" $TMPFILE

crontab $TMPFILE > /dev/null
rm $TMPFILE

echo "[+] Restoring Sysctl [+]"
wget http://web/Config/sysctl.conf
echo "[+] Continue To Type : Yes [+]"
cp -i sysctl.conf /etc/sysctl.conf
rm -rf sysctl.conf
sysctl -p
cat /etc/sysctl.d/*.conf /etc/sysctl.conf | sysctl -e -p -

echo "[+] Restoring Firewall [+]"
iptables-save | awk '($0 !~ /^-A/)||!($0 in a) {a[$0];print}' > /etc/iptables.rules
sed -i -e "/--comment PPTP/d" /etc/iptables.rules
iptables -F
iptables-restore < /etc/iptables.rules
rm /etc/iptables.rules

echo "[+] Removing Installed Packages [+]"
apt-get purge --auto-remove ppp pptpd
echo "[+] Restoring Configs [+]"
echo "[+] Uninstall Completed [+]"
