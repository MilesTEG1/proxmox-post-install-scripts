#!/usr/bin/env bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║ Script pour installer ZSH et OhMySZH et PowerLevel10K                    ║
# ║ avec quelques extensions                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════╝

USER_non_ROOT="myproxmoxuser"

printf "\nScript pour 'root' afin d'installer ZSH et OhMySZH et PowerLevel10K avec quelques extensions"
printf "\nIl faudra le lancer en root puis après avec l'utilisateur souhaité.\n"

printf "\n1. Mise à jour des dépôts et des paquets existants\n"
read -p "Press enter to continue"
sudo apt update && sudo apt upgrade

printf "\n2. Installation des dépendances : git wget curl neofetch net-tools\n"
read -p "Press enter to continue"
sudo apt install -y git wget curl neofetch net-tools
mkdir -p ~/.config/neofetch/
cp ~/config-proxmox/neofetch/config.conf ~/.config/neofetch/

wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

printf "\n\n3. Installation de ZSH pour root.\n"
read -p "Press enter to continue"
sudo apt install -y zsh
sudo chsh -s $(which zsh)

# Check if the shell change was successful
if [ $? -ne 0 ]; then
    printf "chsh command unsuccessful. Change your default shell manually!"
else
    export SHELL="$zsh"
    printf "Shell successfully changed to '%s'.}" "$(which zsh)"
fi

printf "\n\n4. Installation de Oh My ZSH! pour root\n"
read -p "Press enter to continue"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

printf "\n\n5. Installation quelques plugins pour OMZ\n"
read -p "Press enter to continue"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completionsgit clone https://github.com/z-shell/zsh-eza.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-eza
  git clone https://github.com/eza-community/eza.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/eza
  
printf "\n\n6. Copie du fichier .zshrc configuré avec les alias et fonctions et surtout le prompt pour root !\n"
read -p "Press enter to continue"
mv ~/.zshrc ~/.zshrc.backup
cp ~/config-proxmox/zshrc_configured_root ~/.zshrc

printf "\n\n7. Copie des fichiers nécessaire pour configurer l'utilisateur non root : il faudra lancer le script '1-1-non-root-install_zsh_and_co.sh' manuellement dans la session utilisateur.\n"
read -p "Press enter to continue"
mkdir -p /home/${USER_non_ROOT}/config-proxmox
cp ~/config-proxmox/zshrc_configured /home/${USER_non_ROOT}/config-proxmox/
cp ~/config-proxmox/1-1-non-root-install_zsh_and_co.sh /home/${USER_non_ROOT}/config-proxmox/
cp -R ~/config-proxmox/neofetch /home/${USER_non_ROOT}/config-proxmox/
chown -R "${USER_non_ROOT}":users /home/${USER_non_ROOT}/config-proxmox
chmod 764 /home/${USER_non_ROOT}/config-proxmox/1-1-non-root-install_zsh_and_co.sh

printf "\n\n8. Si tout va bien, à la fin de ce point, le prompt devrait être bien joli ^^.\nIl faudra relancer une session root afin de vérifier si tout fonctionne bien.\n\nChargement du fichier .zshrc pour root.\n"
read -p "Press enter to continue"
source ~/.zshrc

printf "\n\nInstallation de ZSH et associés terminé. Veuillez relancer une session."
