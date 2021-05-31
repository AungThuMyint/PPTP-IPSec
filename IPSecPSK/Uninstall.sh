#!/usr/bin/env bash

echo "[+] Stop IPSec Services [+]"
service ipsec stop
service xl2tpd stop
echo "[+] Stop Additional Services [+]"
sleep 3
apt-get remove xl2tpd
rm -rf /usr/local/sbin/ipsec
rm -rf /usr/local/libexec/ipsec
rm -f /etc/init/ipsec.conf
rm -f /lib/systemd/system/ipsec.service
rm -f /etc/init.d/ipsec
rm -f /usr/lib/systemd/system/ipsec.service
rm -rf /etc/ipsec.conf*
rm -rf /etc/ipsec.secrets*
rm -rf /etc/ppp/chap-secrets*
rm -rf /etc/ppp/options.xl2tpd*
rm -rf /etc/pam.d/pluto
rm -rf /etc/sysconfig/pluto
rm -rf /etc/default/pluto
rm -rf /etc/ipsec.d
rm -rf /etc/xl2tpd
apt-get purge xl2tpd
echo "[+] Uninstall Completed [+]"