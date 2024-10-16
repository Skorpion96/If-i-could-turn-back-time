#!/bin/bash

becho() {
	echo -e "\033[1m$@\033[0m"
}

spinat=0

spinner() {
	spinat=$(( (spinat + 1) % 4 ))
	case "$spinat" in
		0) spin="|" ;;
		1) spin="/" ;;
		2) spin="-" ;;
		3) spin="\\" ;;
	esac
	printf "\b$spin"
}

spinner_loop() {
	while :; do
		spinner
		sleep 0.1s
	done
}

spinner_register() {
	spinner_proc=$1
	export spinner_proc
}

spinner_cancel() {
	kill -PIPE $spinner_proc
	printf "\b \b"
}

stopnow=0
export stopnow

trap "echo 'Detected CTRL-C, exiting...'; stopnow=1; export stopnow" INT TERM

becho " * Scanning for all installed packages on the system..."

[ "$stopnow" = "1" ] && exit

spinner_loop &
spinner_register %%

pkgs=$(flatpak list --app | grep -vE 'Application|Version|ID|Ref' | awk '{print $1}' | egrep -v '(flatpak)')

spinner_cancel

[ "$stopnow" = "1" ] && exit

becho " * Reinstallation will start in 3 seconds..."

[ "$stopnow" = "1" ] && exit

sleep 3s

[ "$stopnow" = "1" ] && exit

becho " * Reinstalling..."

rm -f reinstall.log

for pkg in $pkgs; do
	echo -e "\033[1m   * Reinstalling:\033[0m $pkg"
	echo "***** Reinstalling: $pkg *****" >> reinstall.log
	printf "      "
	[ "$stopnow" = "1" ] && exit
	spinner_loop &
	spinner_register %%
	sudo flatpak install --reinstall -y $pkg >> reinstall.log 2>&1
	cerr=$?
	spinner_cancel
	printf "\b \b"
	if [ ! "$cerr" = "0" ]; then
		echo "ERROR: Reinstallation failed. See reinstall.log for details."
		exit 1
	fi
	[ "$stopnow" = "1" ] && exit
done

