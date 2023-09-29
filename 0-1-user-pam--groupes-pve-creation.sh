#!/usr/bin/env bash

# Source : https://www.forum-nas.fr/threads/proxmox-s%C3%A9curisation-utilisateurs-groupe-script.20177/

# ====================================================================================== #
# ========================== Partie création de l'utilisateur ========================== #
# ====================================================================================== #

#########################################################################################################
# Nettoyage de la console #
###########################
clear;

#########################################################################################################
# Déclaration des variables #
#############################
# Nom d'utilisateur et mot de passe du compte:
UTILISATEUR="myproxmoxuser"
MOTDEPASSE="onesuperbigpassowrdhardtocrackwith16254309875"
USERID=1000
EMAIL="admin@my-server.tld"
PRENOM=""
NOM=""
#########################################################################################################
# Création du compte #
######################
/usr/sbin/useradd \
--home-dir /home/${UTILISATEUR} \
--base-dir /home/${UTILISATEUR} \
--uid ${USERID} \
--no-user-group \
--shell /bin/bash \
--create-home ${UTILISATEUR};

#########################################################################################################
# Définir le mot de passe du compte #
#####################################
(echo "${UTILISATEUR}:${MOTDEPASSE}") | chpasswd;

#########################################################################################################
# Sudoers son utilisateur #
###########################
# echo "${UTILISATEUR} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UTILISATEUR};
echo "${UTILISATEUR} ALL=(ALL:ALL) ALL" > /etc/sudoers.d/${UTILISATEUR};
#########################################################################################################
# Vérification #
################
id ${UTILISATEUR};



# ====================================================================================== #
# ============================= Partie création des groupes ============================ #
# ====================================================================================== #

UTILISATEUR="${UTILISATEUR}@pam"

#########################################################################################################
# Nettoyage de Proxmox #
########################
pveum group del Administrateurs 2>/dev/null
pveum group del Audit 2>/dev/null
pveum group del Stockage 2>/dev/null
pveum group del Utilisateurs 2>/dev/null
pveum group del VMadmin 2>/dev/null
pveum user delete ${UTILISATEUR} 2>/dev/null

#########################################################################################################
# Gestion des Utilisateurs #
############################
#
# Groupes:
pveum group add Administrateurs -comment "Groupe des administrateurs"
pveum group add Audit -comment "Groupe des auditeurs"
pveum group add Stockage -comment "Groupe du stockage"
pveum group add Utilisateurs -comment "Groupe des utilisateurs"
pveum group add VMadmin -comment "Groupe des Admins des VM"
#
# Utilisateur:
pveum user add "${UTILISATEUR}" -email "${EMAIL}" -enable 1 -first "${PRENOM}" -lastname "${NOM}"
#
# Mot de passe:
(
    echo "${MOTDEPASSE}"
    echo "${MOTDEPASSE}"
) | pveum passwd ${UTILISATEUR}
#
#########################################################################################################
# Edition des permissions du Groupe #
####################################
pveum acl modify / -group Administrateurs -role Administrator
pveum acl modify / -group Audit -role PVEAuditor
pveum acl modify / -group Stockage -role PVEDatastoreAdmin
pveum acl modify / -group Utilisateurs -role PVEVMUser
pveum acl modify / -group VMadmin -role PVEVMAdmin

#########################################################################################################
# Ajout de l'Utilisateur dans le Groupe #
#########################################
pveum user modify "${UTILISATEUR}" -group Administrateurs

# pveum user modify "${UTILISATEUR}" -group Utilisateurs;
# pveum user modify "${UTILISATEUR}" -group Audit;
# pveum user modify "${UTILISATEUR}" -group VMadmin;
# pveum user modify "${UTILISATEUR}" -group Stockage;
