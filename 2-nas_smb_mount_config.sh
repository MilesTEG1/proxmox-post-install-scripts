#!/usr/bin/env bash

  # ╔══════════════════════════════════════════════════════════════════════════╗
  # ║ Script pour configurer un partage SMB sur le NAS pour Proxmox VE         ║
  # ╚══════════════════════════════════════════════════════════════════════════╝

# ! À lancer en root !
#
# Ce script va :
#   -  
#   - 



sudo apt install cifs-utils 

cat >~/.smbcredentials_syno <<EOL
username=myUser
password=myPassword
EOL

sudo mkdir -p /mnt/{Syno-ISOs,Syno-Proxmox-VE}
sudo cat >>~/toto.text <<EOL
//192.168.2.201/ISOs    /mnt/Syno-ISOs cifs rw,vers=3.0,uid=piliprox,credentials=/home/piliprox/.smbcredentials_syno,iocharset=utf8  0   0
//192.168.2.201/Proxmox-VE  /mnt/Syno-Proxmox-VE cifs rw,vers=3.0,uid=piliprox,credentials=/home/piliprox/.smbcredentials_syno,iocharset=utf8    0   0
EOL

sudo systemctl daemon-reload

mount -a