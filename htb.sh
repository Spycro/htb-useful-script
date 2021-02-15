#!/bin/bash
NET_INTERFACE=tun0
CONFIG=kaarn
IP=$(/sbin/ip a | grep "$NET_INTERFACE" | grep inet | cut -d ' ' -f 6 |cut -d '/' -f 1)

read -r -d '' HELP << EOM
This command is made to have a easy access to the htb (for now) vpn config
	on; --on [config name] : switch on openvpn config
	off; --off [config name]: switch off openvpn config
	status; -s : give ip or nothing
	help; -h: send this message
EOM


switch_off() {
	if [ ! -z "$1" ]; then
		CONFIG="$1"
	fi
	/bin/systemctl stop openvpn@"$CONFIG"
	if [ $? -ne 0 ]; then
		echo "[!] There was a problem in the specified config"
	else
		echo "[-] htb off"
	fi
}

switch_on() {
	if [ ! -z "$1" ]; then
		CONFIG="$1"
	fi
	/bin/systemctl start openvpn@"$CONFIG" 1>/dev/null 2>&1 
	if [ $? -ne 0 ]; then
		echo "[!] There was a problem in the specified config"
	else
		echo "[+] htb on"
	fi
}

status() {
	echo "[*] status : $IP" 
}

get_help() {
	echo "$HELP"
}

if [ "$EUID" -ne 0 ] ; then
	echo "Please run as root"
	exit
fi


while [ -n "$1" ]; do # while loop on argument
	
	case "$1" in

	off | --off) 
		switch_off "$2"
		exit;;
	on | --on) 
		switch_on "$2" 
		exit;;
	help | -h) get_help;;
	status | -s) status;;
	*) get_help;;
	esac
	shift
done
