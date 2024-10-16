#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    SUDO_USER=$(who -m | awk '{print $1}')
    if [ -z "$SUDO_USER" ]; then
        echo "This script must be run with sudo."
        exit 1
    fi
    exec sudo -u "$SUDO_USER" "$0" "$@"
fi

mpv --loop=inf https://www.youtube.com/watch?v=9n3A_-HRFfc --no-video &


