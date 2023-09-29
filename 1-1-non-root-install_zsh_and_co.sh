#!/usr/bin/env bash

  # ╔══════════════════════════════════════════════════════════════════════════╗
  # ║ Script pour installer ZSH et OhMySZH et PowerLevel10K                    ║
  # ║ avec quelques extensions                                                 ║
  # ╚══════════════════════════════════════════════════════════════════════════╝

printf "\nScript pour 'root' afin d'installer ZSH et OhMySZH et PowerLevel10K avec quelques extensions\n"

printf "\n\n1. Installation de ZSH pour root et %s\n"
read -p "Press enter to continue"
chsh -s $(which zsh)

printf "\n\n2. Installation de Oh My ZSH! pour %s\n" "$(whoami)"
read -p "Press enter to continue"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

printf "\n\n3. Installation quelques plugins pour OMZ\n"
read -p "Press enter to continue"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/DarrinTisdale/zsh-aliases-exa.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-aliases-exa
  git clone https://github.com/z-shell/zsh-eza.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-eza
  git clone https://github.com/eza-community/eza.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/eza

printf "\n\n4. Copie du fichier .zshrc configuré avec les alias et fonctions et surtout le prompt pour %s!\n" "$(whoami)"
read -p "Press enter to continue"
mv ~/.zshrc ~/.zshrc.backup
cp ~/config-proxmox/zshrc_configured ~/.zshrc
# sudo ln -s /root/.zshrc ~/.zshrc
mkdir -p ~/.config/neofetch/
cp ~/config-proxmox/neofetch/config.conf ~/.config/neofetch/

printf "\n\n5. Si tout va bien, à la fin de ce point, le prompt devrait être bien joli ^^.\nIl faudra relancer une session afin de vérifier si tout fonctionne bien.\n\nChargement du fichier .zshrc pour %s.\n" "$(whoami)"
read -p "Press enter to continue"
source ~/.zshrc

printf "\n\n6. AJout des options pour nano"
# ~~~~~~ Ajout des options pour nano ~~~~~~ #
printf "\n\n-- Ajout d'options pour nano\n"
if [ -f "~/.nanorc" ]; then
    mv ~/.nanorc ~/.nanorc.bak
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


printf "\n\nInstallation de ZSH et associés terminé pour %s. Veuillez relancer une session." "$(whoami)"
