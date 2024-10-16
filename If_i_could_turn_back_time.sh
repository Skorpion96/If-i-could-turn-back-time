#!/bin/bash

sudo apt-get install backstep libcanberra-gtk-module libcanberra-gtk3-module -y

./sound.sh
echo ""

for script in *reinstall*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "Running $script..."
        ./"$script"
        echo "Finished running $script, don't forget to check /opt /var and other eventual directories for your eventual softwares and SDKs for what could not have been reinstalled by this script as it isn't omnipotent"
        echo "-----------------------------"
    fi
done

