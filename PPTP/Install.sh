#!/bin/sh

modprobe ip_nat_pptp
modprobe pptp
modprobe gre

if [ `id -u` -ne 0 ] 
then
  echo "Need root, try with sudo"
  exit 0
fi

network_interface=$(ip -o -4 route show to default | awk '{print $5}')

apt-get update

apt-get -y install pptpd || {
  echo "Could not install pptpd" 
  exit 1
}

#ubuntu has exit 0 at the end of the file.
sed -i '/^exit 0/d' /etc/rc.local

cat >> /etc/rc.local << END
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -p tcp --dport 1723 -j ACCEPT
iptables -I INPUT  --protocol 47 -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -d 0.0.0.0/0 -o $network_interface -j MASQUERADE
iptables -I FORWARD -s 192.168.2.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
END
sh /etc/rc.local

echo ""
echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ "
echo " | PPTP VPN Setup Script By Aung Thu Myint | "
echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ "
echo ""
echo -n " [#] Enter PPTP VPN UserName : "
read NAME
echo ""
echo -n " [#] Enter PPTP VPN Password : "
read PASS
echo ""
NAME=$NAME
PASS=$PASS

cat >/etc/ppp/chap-secrets <<END
$NAME pptpd $PASS *
END
cat >/etc/pptpd.conf <<END
option /etc/ppp/options.pptpd
logwtmp
localip 192.168.2.1
remoteip 192.168.2.10-100
END
cat >/etc/ppp/options.pptpd <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
lock
nobsdcomp 
novj
novjccomp
nologfd
END

apt-get -y install wget || {
  echo "Could not install wget, required to retrieve your IP address." 
  exit 1
}

IP=`wget -q -O - http://api.ipify.org`

if [ "x$IP" = "x" ]
then
  echo ""
  echo " [!] COULD NOT DETECT SERVER EXTERNAL IP ADDRESS [!]"
  echo ""
else
  echo ""
  echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ "
  echo " | PPTP VPN Setup Script By Aung Thu Myint | "
  echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ "
  echo ""
  echo " [#] External IP Address  : $IP "
  echo ""
fi
echo   " [#] PPTP VPN UserName    : $NAME"
echo ""
echo   " [#] PPTP VPN Password    : $PASS "
echo ""
echo   " If You Want To Add New User & Del User"
echo ""
echo   " Go To This Directory /etc/ppp/chap-secrets"
echo ""
echo   "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
echo ""
sleep 3

service pptpd restart

exit 0
