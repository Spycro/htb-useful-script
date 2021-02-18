#!/bin/bash
NET_INTERFACE=tun0
CONFIG=kaarn

read -r -d '' HELP << EOM
This command is made to have a easy access to the htb (for now) vpn config
	-c; --config : Specify config file
	on; --on  : switch on openvpn config
	off; --off : switch off openvpn config
	status; -s : give ip or nothing
	help; -h: send this message
EOM

get_ip () {
	IP=$(/sbin/ip a | grep "$NET_INTERFACE" | grep inet | cut -d ' ' -f 6 |cut -d '/' -f 1)
}

switch_off() {
	/bin/systemctl is-active --quiet openvpn@"$1"
	if [ "$?" -ne 0 ]; then
		echo "[*] Config $1 is already inactive"
		return 0
	fi

	/bin/systemctl stop --quiet openvpn@"$1"
	if [ $? -ne 0 ]; then
		echo "[!] There was a problem with the specified config"
	else
		echo "[-] htb off"
	fi
}

switch_on() {
	/bin/systemctl is-active --quiet openvpn@"$1"
	if [ "$?" -eq 0 ]; then
		echo "[*] Config $1 is already active"
		return 0
	fi
	/bin/systemctl start --quiet openvpn@"$1" 
	if [ $? -ne 0 ]; then
		echo "[!] There was a problem with the specified config"
	else
		echo "[+] htb on"
	fi
}

status() {
	/bin/systemctl is-active --quiet  openvpn@"$1"
	if [ "$?" -eq 0 ]; then
		echo "[*] status of $1.conf: $IP"
	else
		echo "[*] $1 is inactive" 
	fi
}

get_help() {
	echo "$HELP"
}

exit_if_not_root() {
	if [ "$EUID" -ne 0 ] ; then
		echo "Please run as root"
		exit
	fi
}


PARAMS=""

while (( "$#" )); do # while loop on argument
	
	case "$1" in
	--config | -c)
		if [ -n "$2" ]; then
			CONFIG="$2"
			echo "[*] Set config to : $CONFIG"
		else
			echo "Please provide an openvpn configuration name"
			exit 1
		fi
		shift
		;;	
	off | --off) FLAG_OFF=1;;
	on | --on) FLAG_ON=1;;
	help | -h) get_help;;
	status | -s) FLAG_STATUS=1;;
	*) 
		echo "$1 was not recognized."
		get_help
		exit 1;;
	esac
	shift
done


if [ -n "$FLAG_ON" ]; then
	exit_if_not_root
	switch_on "$CONFIG"
elif [ -n "$FLAG_OFF" ]; then
	exit_if_not_root
	switch_off "$CONFIG"
elif [ -n "$FLAG_STATUS" ]; then
	get_ip
	status "$CONFIG"
fi
