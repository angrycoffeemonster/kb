#!/bin/bash
#
# On your Mac, install openvpn2 and tun driver via MacPorts:
# 	sudo port install openvpn2 tuntaposx
#
# On your Android Phone, install Azilink (http://code.google.com/p/azilink/)
#

init() {
	adb forward tcp:41927 tcp:41927
	sudo openvpn2 --dev tun \
				--remote 127.0.0.1 41927 \
				--proto tcp-client \
				--ifconfig 192.168.56.2 192.168.56.1 \
				--route 0.0.0.0 128.0.0.0 \
				--route 128.0.0.0 128.0.0.0 \
				--keepalive 10 30 \
				--tun-mtu 1500 \
				--tun-mtu-extra 32 \
				--mssfix 1450 \
				--script-security 2 \
				--up "$0 up" \
				--down "$0 down"
}

up() {
	tun_dev=$1
	ns=192.168.56.1
	sudo /usr/sbin/scutil << EOF
open
d.init
get State:/Network/Interface/$tun_dev/IPv4
d.add InterfaceName $tun_dev
set State:/Network/Service/openvpn-$tun_dev/IPv4

d.init
d.add ServerAddresses * $ns
set State:/Network/Service/openvpn-$tun_dev/DNS
quit
EOF
}

down() {
	tun_dev=$1
	sudo /usr/sbin/scutil << EOF
open
remove State:/Network/Service/openvpn-$tun_dev/IPv4
remove State:/Network/Service/openvpn-$tun_dev/DNS
quit
EOF
}

case $1 in
	up  ) up $2 ;;  # openvpn will pass tun/tap dev as $2
	down) down $2 ;;
	*   ) init ;;
esac
