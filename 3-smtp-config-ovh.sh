#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ Script pour configurer le SMTP dans Proxmox VE                           ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# ! À lancer en root !
# chmod 764 *.sh

# ~~~~~~~~~~ Variables à modifier ~~~~~~~~~ #
email="admin@my-server.tld"
smtp_host="smtp-host.tld"
smtp_port=465
smtp_password="some-very-hard-pw-to-crack-13432562788290309876531"
backup_folder=~/"config-proxmox/backup-$(date +%Y-%m-%d--%Hh%Mm%Ss)"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# ~~~~~~~~~~~ Dossier de backup ~~~~~~~~~~~ #
mkdir -p "${backup_folder}"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

printf "\n-- Script pour configurer le SMTP OVH dans proxmox --"
printf "\n-- 1. Installation de libsasl2-modules"
apt install libsasl2-modules

printf "\n-- 2. Création du fichier de mot de passe"
sasl_passwd_path=/etc/postfix/sasl_passwd
if [ -f "${sasl_passwd_path}" ]; then
    printf "\n     !! Le fichier '%s' existe, il sera copié dans '%s'." "${sasl_passwd}" "${backup_folder}"
    mv "${sasl_passwd_path}" "${backup_folder}"
fi

cat >"${sasl_passwd_path}" <<EOL
# Pour OVH : ssl0.ovh.net:465 youremail@mail.com:votremotdepasse
${smtp_host}:${smtp_port} ${email}:${smtp_password}
EOL

printf "\n-- 3. Création de la base de donnés depuis le fichier de mot de passe"
postmap hash:"${sasl_passwd_path}"
chmod 600 "${sasl_passwd_path}"

printf "\n-- 4. Édition du fichiers de configuration"
postfix_main_file=/etc/postfix/main.cf
if [ -f "${postfix_main_file}" ]; then
    printf "\n     !! Le fichier '%s' existe, il sera copié dans '%s'." "${postfix_main_file}" "${backup_folder}"
    cp "${postfix_main_file}" "${backup_folder}"
fi

sed -i "s/mydestination = .*/mydestination =/" "${postfix_main_file}"
sed -i "s/relayhost.*/relayhost = ${smtp_host}:${smtp_port}/" "${postfix_main_file}"
sed -i "s/inet_interfaces = .*/inet_interfaces = all/" "${postfix_main_file}"

contents=$(<"${postfix_main_file}")
section='smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
smtp_tls_session_cache_timeout = 3600s
smtp_tls_wrappermode = yes
smtp_tls_security_level = secure
mailbox_size_limit = 0
inet_protocols = ipv4'

if [[ $contents == *"$section"* ]]; then
    printf "\n     Le fichier %s contient déjà la section à ajouter à sa fin." "${postfix_main_file}"
else
    # append it to the file
    printf "\n     Le fichier %s ne contient la section à ajouter à sa fin." "${postfix_main_file}"
    echo "$section" >>"${postfix_main_file}"
fi

printf "\n--      Vérification du fichier de configuration...\n"
cat "${postfix_main_file}"

printf "\n"
while true; do

    read -p "\n     Le fichier est-il correctement modifié ? (y/n) " yn

    case $yn in
    [yY])
        printf "\n     On relance postfix"
        postfix reload
        break
        ;;
    [nN])
        printf "\n     Copie retour du backup de main.cf"
        cp "${backup_folder}"/main.cf "${postfix_main_file}"
        exit
        ;;
    *)
        printf "\ninvalid response"
        ;;
    esac

done

printf "\n-- 5. Vérification du fonctionnement de postfix"
postfix status
if (systemctl is-active -q postfix); then
    printf "\n     Success: postfix is running."
else
    printf "\n     Error: postfix is not running!"
fi
