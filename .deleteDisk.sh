#!/bin/bash
echo "VBoxManage storageattach Buttaire --storagectl SATA ... --medium emptydrive ..."
VBoxManage storageattach Buttaire --storagectl SATA --port 0 --device 0 --type hdd --medium emptydrive 2> /dev/null
echo "VBoxManage closemedium disk buttaire.vdi --delete 2> /dev/null"
VBoxManage closemedium disk buttaire.vdi --delete 2> /dev/null
echo "rm -f .attach"
rm -f .attach
exit 0

