#!/bin/bash

pip list --format=columns | awk '{print $1}' | sed 's/.*/\L&/' | sort > list.pip

sed 's/.*/\L&/' list.pip | xargs -Ipkg dpkg -l python-pkg python3-pkg pkg |& grep ^ii | awk '{print $2}' | sed -r s/^python3?-// | sort | uniq > list.apt

comm -23 list.pip list.apt > list_toRemove

sed -i '1d' list_toRemove

sed -i '/language-selector/d' list_toRemove

sed -i '/package/d' list_toRemove

sed -i '/pygobject/d' list_toRemove

sed -i '/pyrfc3339/d' list_toRemove

sed -i '/pyqt5-sip/d' list_toRemove

sed -i '/pynacl/d' list_toRemove

sed -i '/pyopengl/d' list_toRemove

sed -i '/pykerberos/d' list_toRemove

sed -i '/pyjwt/d' list_toRemove

sed -i '/python-apt/d' list_toRemove

sed -i '/sflib/d' list_toRemove

echo "Packages to be removed:"
while read -r package; do
    echo "$package"
done < list_toRemove

while read -r package; do
    pip uninstall -y "$package"
done < list_toRemove

pip install -r list_toRemove --user

sudo apt install libcairo2-dev libxt-dev libgirepository1.0-dev libkrb5-dev -y && pip install pycairo PyGObject pyrfc3339 pyqt5-sip pynacl pyopengl pykerberos pyjwt Gi

rm list.pip list.apt list_toRemove
