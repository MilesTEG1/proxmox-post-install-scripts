#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ Script pour configurer Proxmox VE                                        ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# ! À lancer en root !
# chmod 764 *.sh
#
# Ce script va :
#   - Changer le port SSH par défaut 22 par celui défini dans la variable
#           ->  Source : https://www.forum-nas.fr/threads/tuto-changer-le-port-ssh-de-votre-serveur-debian.16456/
#
#   - Lancer le script post-pve-install.sh qui fera ce qui suit :
#           * corriger les sources Proxmox VE
#           * désactiver le référentiel 'pve-enterprise'
#           * activer le référentiel 'pve-no-subscription'
#           * activer les "dépôts de packages ceph"
#           * ajout (ou pas) du référentiel 'pvetest'
#           * désactiver l'abonnement nag
#           * désactiver la haute disponibilité
#           * mettre à jour Proxmox VE
#           * redémarrer Proxmox VE (redémarrage recommandé)
#           -> Source : https://tteck.github.io/Proxmox/
#
#   - Ajout du support de la souris (et autres options) pour nano
#           -> Source :https://www.nano-editor.org/dist/v2.9/nanorc.5.html
#

# ~~~~~~~~ Définition des variables ~~~~~~~ #
# Changement du port SSH
port_ssh="99"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
script_folder="$(pwd)"
backup_folder="${script_folder}/0-0-backup_files--$(date +%Y-%m-%d--%Hh%Mm%Ss)"
mkdir -p "${backup_folder}"
# ~~~~~~~~~~~ Dossier de backup ~~~~~~~~~~~ #




# ~~~~~~~~~ Changement du port SSH ~~~~~~~~ #
# Source : https://www.forum-nas.fr/threads/tuto-changer-le-port-ssh-de-votre-serveur-debian.16456/
# Backup the sshd_config file
# cp /etc/ssh/sshd_config ./ && grep "#Port" ./sshd_config
printf "\n-- Changement du port SSH (par défaut 22) pour le port %s" "${port_ssh}"
printf "\n   Copie de sauvegarde du fichier modifié dans '/etc/ssh/sshd_config.BAK'.\n"
cp --parents /etc/ssh/sshd_config "${backup_folder}"
sed -i "s/#Port 22/Port ${port_ssh}/" /etc/ssh/sshd_config # && grep "Port " ./sshd_config
/etc/init.d/ssh restart
printf "\n-- Changement du port SSH effectué.\nLe redémarrage du service SSH ne 'casse' pas la connexion actuelle. Tester la connexion dans une autre session SSH."
read -p "Appuyer sur ENTRER pour continuer. Ou CTRL+C pour arrêter le script."
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# ~~~~~~ Ajout des options pour nano ~~~~~~ #
printf "\n\n-- Ajout d'options pour nano\n"
if [ -f "~/.nanorc" ]; then
    mv ~/.nanorc "${backup_folder}"/.nanorc.bak
fi
cat >~/.nanorc <<EOL
## Use auto-indentation.
set autoindent

## Constantly display the cursor position in the statusbar.  Note that
## this overrides "quickblank".
#set const

## Add lines number
set linenumbers

## Enable mouse support, if available for your system.  When enabled,
## mouse clicks can be used to place the cursor, set the mark (with a
## double click), and execute shortcuts.  The mouse will work in the X
## Window System, and on the console when gpm is running.
set mouse

## Use this tab size instead of the default; it must be greater than 0.
set tabsize 4

## Convert typed tabs to spaces.
set tabstospaces

## Make the Home key smarter.  When Home is pressed anywhere but at the
## very beginning of non-whitespace characters on a line, the cursor
## will jump to that beginning (either forwards or backwards).  If the
## cursor is already at that position, it will jump to the true
## beginning of the line.
set smarthome

## Use smooth scrolling as the default.
#set smooth

## Allow nano to be suspended.
#set suspend
EOL
printf "\n-- Ajout d'options pour nano terminé.\n"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
read -p "Appuyer sur ENTRER pour continuer sur la désactivation de l'IPv6. Ou CTRL+C pour arrêter le script."

# ~~~~~~~~ Désactivation de l'IPv6 ~~~~~~~~ #
printf "\n-- Désactivation de l'IPv6"
printf "\n   Copie de sauvegarde du fichier modifié dans '/etc/ssh/sshd_config.BAK'.\n"
cp --parents /etc/sysctl.conf "${backup_folder}"

cat >>/etc/sysctl.conf <<EOL
###################################################################
# désactivation de ipv6 pour toutes les interfaces
net.ipv6.conf.all.disable_ipv6 = 1

# désactivation de l’auto configuration pour toutes les interfaces
net.ipv6.conf.all.autoconf = 0

# désactivation de ipv6 pour les nouvelles interfaces (ex:si ajout de carte réseau)
net.ipv6.conf.default.disable_ipv6 = 1

# désactivation de l’auto configuration pour les nouvelles interfaces
net.ipv6.conf.default.autoconf = 0

net.ipv6.conf.lo.disable_ipv6 = 1
###################################################################
EOL
sysctl -p
printf "\n-- Désactivation de l'IPv6 terminée.\n"
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

read -p "Appuyer sur ENTRER pour continuer sur l'installation de sudo. Ou CTRL+C pour arrêter le script."

# ~~~~~~~~~~ Installation de sudo ~~~~~~~~~ #
printf "\n-- Installation de sudo"
apt update
apt install -y sudo
printf "\n-- Installation de sudo terminé."
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

read -p "Appuyer sur ENTRER pour continuer sur la suppression de l'avertissement de licence. Ou CTRL+C pour arrêter le script."


# # ~~ Supprimer l'avertissement de licence ~ #
printf "\n-- Suppression de l'avertissement de licence dans PVE"
cp --parents /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js "${backup_folder}";
# Source de la commande : https://johnscs.com/remove-proxmox51-subscription-notice/
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
printf "\n-- Suppression de l'avertissement de licence dans PVE terminée.\n"


read -p "Appuyer sur ENTRER pour continuer sur PBS Post Install script. Ou CTRL+C pour arrêter le script."


# ~~~~~ Installation et configuration ~~~~~ #
# ~~~~~~~~~~~~~ des locales FR ~~~~~~~~~~~~ #
# Source : https://serverfault.com/a/894545
# Install locales package
apt-get install -y locales
# Uncomment fr_FR.UTF-8 for inclusion in generation
cp --parents /etc/locale.gen "${backup_folder}";

sed -i 's/^# *\(fr_FR.UTF-8\)/\1/' /etc/locale.gen
# Generate locale
locale-gen
# Export env vars
echo "export LC_ALL=fr_FR.UTF-8" >> ~/.bashrc
echo "export LANG=fr_FR.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=fr_FR.UTF-8" >> ~/.bashrc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #



# ~~~~~~~~ PBS Post Install ~~~~~~~~ #
printf "\n-- Lancement du script post-pve-install."
cp -r --parents /etc/apt/{sources.list,sources.list.d} "${backup_folder}";
bash -c "$(wget -qLO - https://github.com/tteck/Proxmox/raw/main/misc/post-pve-install.sh)"
printf "\n-- Script post-pve-install terminé.\n"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
printf "\n-- Modification du fichier /etc/apt/sources.list avec un dépôt FR et les composants non-free non-free-firmware"
cp sources.list-modified /etc/apt/sources.list

# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #