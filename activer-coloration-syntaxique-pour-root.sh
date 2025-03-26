#!/bin/bash

# Fonction d'explication
function afficher_explication() {
    clear
    echo "### Explication : Coloration syntaxique pour root ###"
    echo
    echo "La coloration syntaxique permet d'améliorer la lisibilité et la navigation dans la console."
    echo "Lorsqu'elle est activée pour root, vous bénéficiez des avantages suivants :"
    echo "1. Prompt coloré : Le nom d'utilisateur, le répertoire courant et l'invite de commande s'affichent avec des couleurs distinctives."
    echo "2. Commandes ls et grep : Les résultats de commandes comme 'ls' ou 'grep' sont colorés pour faciliter la distinction des fichiers, répertoires, et correspondances."
    echo
    echo "Cela peut être utile pour identifier rapidement le contexte et éviter des erreurs (par ex. suppression de fichiers au mauvais endroit)."
    echo
    echo "Souhaitez-vous maintenant activer la coloration syntaxique ? (oui/non)"
}

# Fonction d'activation
function activer_coloration() {
    echo "Activation de la coloration syntaxique pour root..."

    # Vérification et création de ~/.bashrc si nécessaire
    if [ ! -f /root/.bashrc ]; then
        echo "Fichier .bashrc non trouvé pour root. Création en cours..."
        touch /root/.bashrc
    fi

    # Ajout de l'alias et de la configuration si absent
    if ! grep -q "force_color_prompt=yes" /root/.bashrc; then
        echo "Ajout de la ligne force_color_prompt=yes dans .bashrc"
        echo "force_color_prompt=yes" >> /root/.bashrc
    fi

    if ! grep -q "PS1='\\\[\\\033[01;32m\\\]\\u@\\h:\\\[\\\033[01;34m\\\]\\w\\\[\\\033[00m\\\]\\\$ '" /root/.bashrc; then
        echo "Configuration du prompt coloré pour root..."
        cat << 'EOF' >> /root/.bashrc

if [ "$force_color_prompt" = yes ]; then
    if [ -n "$TERM" ] && [[ "$TERM" =~ (xterm|vt100|linux) ]]; then
        PS1='\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w\[\033[00m\]\$ '
    fi
fi
EOF
    fi

    # Vérification des outils de coloration
    echo "Vérification de la disponibilité de 'dircolors'..."
    if ! command -v dircolors &>/dev/null; then
        echo "Le paquet 'coreutils' doit être installé pour activer les couleurs dans ls et dircolors."
        echo "Installation de coreutils..."
        apt update && apt install -y coreutils
    fi

    # Ajout de la configuration de dircolors
    if ! grep -q "eval \"\$(dircolors" /root/.bashrc; then
        echo "Configuration des couleurs pour ls et dircolors..."
        echo 'eval "$(dircolors -b)"' >> /root/.bashrc
        echo "alias ls='ls --color=auto'" >> /root/.bashrc
        echo "alias grep='grep --color=auto'" >> /root/.bashrc
    fi

    echo "Configuration terminée. Relancez la session root pour appliquer les changements."
}

# Boucle principale
while true; do
    echo "Voulez-vous activer la coloration syntaxique pour root dans la console ?"
    echo "Choix disponibles :"
    echo "1. oui"
    echo "2. non"
    echo "3. explication"
    echo -n "Votre choix : "
    read -r choix

    case $choix in
    oui | 1)
        activer_coloration
        break
        ;;
    non | 2)
        echo "Aucune modification effectuée. Au revoir."
        break
        ;;
    explication | 3)
        afficher_explication
        ;;
    *)
        echo "Choix invalide. Veuillez entrer 'oui', 'non', ou 'explication'."
        ;;
    esac
done
