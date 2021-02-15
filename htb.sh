#!/bin/bash
NET_INTERFACE=tun0
IP=$(/sbin/ip a | grep "$NET_INTERFACE" | grep inet | cut -d ' ' -f 6 |cut -d '/' -f 1)

read -r -d '' HELP << EOM
This command is made to have a easy access to the htb (for now) vpn config
	on : switch on openvpn config
	off : switch off openvpn config
	status : give ip or nothing
EOM

if [ "$EUID" -ne 0 ] ; then
	echo "Please run as root"
	exit
fi
if [ -z $1 ]; then
	echo "$HELP"
elif [ "$1" = "off" ]; then
	/bin/systemctl stop openvpn@kaarn
	echo "[-] htb off"
elif [ "$1" = "on" ]; then
	/bin/systemctl start openvpn@kaarn
	echo "[+] htb on"
elif [ "$1" = "status" ]; then
	echo "[*] status : $IP" 
elif [ "$1" = "help" ]; then
	echo "$HELP"

else
	echo "$HELP"
fi

