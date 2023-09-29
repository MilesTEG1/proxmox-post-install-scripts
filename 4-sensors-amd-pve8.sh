#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ Script pour ajouter les sondes de températures dans Proxmox VE           ║
# ║                          Version pour CPU AMD                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# ! À lancer en root !
# chmod 764 *.sh

# ~~~~~~~~~~ Variables à modifier ~~~~~~~~~ #

backup_folder=~/"config-proxmox/backup-$(date +%Y-%m-%d--%Hh%Mm%Ss)"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# ~~~~~~~~~~~ Dossier de backup ~~~~~~~~~~~ #
mkdir -p "${backup_folder}"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

printf "\n-- Script pour configurer les sondes de température dans proxmox --"
printf "\n-- 1. Mise à jour des dépôts et des paquets existants\n"
read -p "Press enter to continue"
sudo apt update && sudo apt upgrade

printf "\n-- 2. Installation des dépendances : lm-sensors\n"
read -p "Press enter to continue"
sudo apt install -y lm-sensors

printf "\n-- 3. Sauvegardes des fichiers à modifer"
cp --parents -v /usr/share/perl5/PVE/API2/Nodes.pm "${backup_folder}"
cp --parents -v /usr/share/pve-manager/js/pvemanagerlib.js "${backup_folder}"

# DEBUG
read -p "Press enter to continue #3 Backup"
# DEBUG

printf "\n-- 4. Édition du fichier '/usr/share/perl5/PVE/API2/Nodes.pm'"
# 1er fichier : /usr/share/perl5/PVE/API2/Nodes.pm
# Source : https://stackoverflow.com/a/12248998/17694638
a_rechercher="\tmy \$dinfo"
a_ajouter="\t\$res->{thermalstate} = \`sensors k10temp-pci-00c3\`;\n\n"
# Vérification que cette modification n'a pas déjà été faite
if ! grep "\$res->{thermalstate} = \`sensors k10temp-pci-00c3\`;" /usr/share/perl5/PVE/API2/Nodes.pm; then
    # Modification non faite. On la fait.
    sed -i "/$a_rechercher/ { N; s/$a_rechercher/$a_ajouter&/ }" /usr/share/perl5/PVE/API2/Nodes.pm
else
    printf "\nLa modification du fichier '/usr/share/perl5/PVE/API2/Nodes.pm' semble déjà avoir été effectuée.\nRien ne sera modifié ici. Vérifier quand même le fichier.\n"
fi

printf "\n-- 5. Édition du fichier '/usr/share/pve-manager/js/pvemanagerlib.js'"
# 2ème fichier : /usr/share/pve-manager/js/pvemanagerlib.js
# Source : https://forum.hardware.fr/hfr/Programmation/Shell-Batch/remplacer-plusieurs-fichiers-sujet_148479_1.htm#t2454720
a_rechercher="\t{\n\t    xtype: 'box',\n\t    colspan: 2,\n\t    padding: '0 0 20 0',\n\t},\n\t{\n\t    itemId: 'cpus',\n\t    colspan: 2,\n\t    printBar: false,\n\t    title: gettext('CPU(s)'),\n\t    textField: 'cpuinfo',\n\t    renderer: Proxmox.Utils.render_cpu_model,\n\t    value: '',\n\t},\n\t{\n\t    itemId: 'kversion',\n\t    colspan: 2,\n\t    title: gettext('Kernel Version'),\n\t    printBar: false,\n\t    textField: 'kversion',\n\t    value: '',\n\t},\n\t{\n\t    itemId: 'version',\n\t    colspan: 2,\n\t    printBar: false,\n\t    title: gettext('PVE Manager Version'),\n\t    textField: 'pveversion',\n\t    value: '',\n\t},"
a_remplacer="\t{\n\t    xtype: 'box',\n\t    colspan: 2,\n\t    padding: '0 0 10 0',\n\t},\n\t{\n\t    itemId: 'cpus',\n\t    colspan: 2,\n\t    printBar: false,\n\t    title: gettext('CPU(s)'),\n\t    textField: 'cpuinfo',\n\t    renderer: Proxmox.Utils.render_cpu_model,\n\t    value: '',\n\t},\n\t{\n\t    itemId: 'kversion',\n\t    colspan: 2,\n\t    title: gettext('Kernel Version'),\n\t    printBar: false,\n\t    textField: 'kversion',\n\t    value: '',\n\t},\n\t{\n\t    itemId: 'version',\n\t    colspan: 2,\n\t    printBar: false,\n\t    title: gettext('PVE Manager Version'),\n\t    textField: 'pveversion',\n\t    value: '',\n\t},\n\t{\n    \titemId: 'thermal',\n    \tcolspan: 2,\n    \tprintBar: false,\n    \ttitle: gettext('CPU Thermal State'),\n    \ttextField: 'thermalstate',\n      \trenderer:function(value){\n        \tconst tdie = value.match(\/Tdie.*?\+([\d\.]+)\/)[1];\n        \treturn \`Tdie: \${tdie} ℃ \`;\n    \t}\n\t},"
# Voir ici : https://stackoverflow.com/a/7680548/17694638
# sed "s/$a_rechercher/$a_remplacer/g" ./essais.js > tmp.js
# Vérification que cette modification n'a pas déjà été faite
if ! grep "return \`Tdie: \${tdie} ℃ \`;" /usr/share/pve-manager/js/pvemanagerlib.js; then
    # Modification non faite. On la fait.
    sed -z -i "s/$a_rechercher/$a_remplacer/g" /usr/share/pve-manager/js/pvemanagerlib.js
else
    printf "\nLa modification du fichier '/usr/share/pve-manager/js/pvemanagerlib.js' semble déjà avoir été effectuée.\nRien ne sera modifié ici. Vérifier quand même le fichier.\n"
fi

printf "\n-- 6. Redémarrage de la Web-UI"
systemctl restart pveproxy

printf "\n-- Script terminé --"
