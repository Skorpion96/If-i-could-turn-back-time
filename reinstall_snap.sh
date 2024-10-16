#!/bin/bash

whitelist=("bare" "core" "core18" "core20" "core22" "snapd")

becho() {
    echo -e "\033[1m$@\033[0m"
}

spinat=0

spinner() {
    spinat=`expr $spinat + 1`
    if [ "$spinat" = "1" ];then
        spin="|"
    elif [ "$spinat" = "2" ];then
        spin="/"
    elif [ "$spinat" = "3" ];then
        spin="-"
    elif [ "$spinat" = "4" ];then
        spin="\\"
        spinat=0;
    else
        spinat=0;
    fi
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

becho " * Scanning for all installed snap packages on the system..."

[ "$stopnow" = "1" ] && exit

spinner_loop &
spinner_register %%

pkgs=$(snap list | awk 'NR>1 {print $1}')

spinner_cancel

[ "$stopnow" = "1" ] && exit

becho " * Reinstallation will start in 3 seconds..."

[ "$stopnow" = "1" ] && exit

sleep 3s

[ "$stopnow" = "1" ] && exit

becho " * Reinstalling..."

rm -f reinstall.log

for pkg in $pkgs; do
    if [ "$pkg" = "go" ]; then
        continue
    fi

    if [[ " ${whitelist[@]} " =~ " ${pkg} " ]]; then
        echo "***** Skipping whitelisted package: $pkg *****" >> reinstall.log
        continue
    fi

    echo -e "\033[1m   * Reinstalling:\033[0m $pkg"
    echo "***** Reinstalling: $pkg *****" >> reinstall.log
    printf "      "
    [ "$stopnow" = "1" ] && exit
    
    spinner_loop &
    spinner_register %%

    sudo snap disable $pkg && sudo snap remove $pkg && sudo snap install $pkg >> reinstall.log

    cerr=$?
    spinner_cancel
    backstep "      "
    
    if [ ! "$cerr" = "0" ]; then
        echo "ERROR: Reinstallation failed. See reinstall.log for details."
        exit 1
    fi
    
    [ "$stopnow" = "1" ] && exit
done

if [ -d ~/snap/go ]; then
    echo "   * Reinstalling go snap..."
    printf "      "
    [ "$stopnow" = "1" ] && exit
    
    spinner_loop &
    spinner_register %%    
    sudo snap disable go && sudo snap remove go && sudo snap install go --classic >> reinstall.log
    cerr=$?
    spinner_cancel
    backstep "      "
    
    if [ ! "$cerr" = "0" ]; then
        echo "ERROR: Reinstallation failed. See reinstall.log for details."
        exit 1
    fi
    
    [ "$stopnow" = "1" ] && exit
else
    echo "   * go snap is not installed, skipping..."
fi
