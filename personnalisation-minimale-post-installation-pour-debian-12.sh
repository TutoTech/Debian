#!/bin/bash

# Vérifier que le script est exécuté avec les privilèges administrateur
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté avec les privilèges administrateur (sudo)."
  exit 1
fi

# Fonction de vérification des retours d'erreur
check_command() {
  if [ $? -ne 0 ]; then
    echo "[ERREUR] La commande précédente a échoué. Vérifiez les journaux et corrigez les erreurs."
    exit 1
  fi
}

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

echo "
###### #####   ##   #####  ###### 
#        #    #  #  #    # #      
#####    #   #    # #    # #####  
#        #   ###### #####  #      
#        #   #    # #      #      
######   #   #    # #      ###### 
                                  
                                                  
 ####  #    # # #    #   ##   #    # ##### ###### 
#      #    # # #    #  #  #  ##   #   #   #      
 ####  #    # # #    # #    # # #  #   #   #####  
     # #    # # #    # ###### #  # #   #   #      
#    # #    # #  #  #  #    # #   ##   #   #      
 ####   ####  #   ##   #    # #    #   #   ######" 

# Étape : Changer le hostname
read -p "Entrez le nouveau hostname : " NEW_HOSTNAME
hostnamectl set-hostname "$NEW_HOSTNAME"
echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts



echo "
###### #####   ##   #####  ###### 
#        #    #  #  #    # #      
#####    #   #    # #    # #####  
#        #   ###### #####  #      
#        #   #    # #      #      
######   #   #    # #      ###### 
                                  
                                                  
 ####  #    # # #    #   ##   #    # ##### ###### 
#      #    # # #    #  #  #  ##   #   #   #      
 ####  #    # # #    # #    # # #  #   #   #####  
     # #    # # #    # ###### #  # #   #   #      
#    # #    # #  #  #  #    # #   ##   #   #      
 ####   ####  #   ##   #    # #    #   #   ######" 

# Étape : Configurer une IP fixe
read -p "Souhaitez-vous configurer une IP fixe ? (y/n) : " CONFIGURE_IP
if [[ "$CONFIGURE_IP" == "y" ]]; then
  echo "Interfaces réseau disponibles :"
  ip -o link show | awk -F': ' '{print $2}'
  read -p "Entrez le nom de l'interface réseau : " INTERFACE
  read -p "Entrez l'adresse IP fixe (ex : 192.168.1.100/24) : " STATIC_IP
  read -p "Entrez la passerelle (gateway) : " GATEWAY
  read -p "Entrez le ou les serveurs DNS (séparés par des espaces) : " DNS_SERVERS

  if [[ -z "$INTERFACE" || -z "$STATIC_IP" || -z "$GATEWAY" || -z "$DNS_SERVERS" ]]; then
    echo "[ERREUR] Informations incomplètes pour configurer une IP fixe. Cette étape est ignorée."
  else
    cat <<EOF > /etc/network/interfaces.d/$INTERFACE
auto $INTERFACE
iface $INTERFACE inet static
    address $STATIC_IP
    gateway $GATEWAY
    dns-nameservers $DNS_SERVERS
EOF
    check_command
    systemctl restart networking
    check_command
  fi
fi



echo "
###### #####   ##   #####  ###### 
#        #    #  #  #    # #      
#####    #   #    # #    # #####  
#        #   ###### #####  #      
#        #   #    # #      #      
######   #   #    # #      ###### 
                                  
                                                  
 ####  #    # # #    #   ##   #    # ##### ###### 
#      #    # # #    #  #  #  ##   #   #   #      
 ####  #    # # #    # #    # # #  #   #   #####  
     # #    # # #    # ###### #  # #   #   #      
#    # #    # #  #  #  #    # #   ##   #   #      
 ####   ####  #   ##   #    # #    #   #   ######" 
 
# Étape : Mettre à jour le système
apt update && apt upgrade -y
check_command


echo "
###### #####   ##   #####  ###### 
#        #    #  #  #    # #      
#####    #   #    # #    # #####  
#        #   ###### #####  #      
#        #   #    # #      #      
######   #   #    # #      ###### 
                                  
                                                  
 ####  #    # # #    #   ##   #    # ##### ###### 
#      #    # # #    #  #  #  ##   #   #   #      
 ####  #    # # #    # #    # # #  #   #   #####  
     # #    # # #    # ###### #  # #   #   #      
#    # #    # #  #  #  #    # #   ##   #   #      
 ####   ####  #   ##   #    # #    #   #   ######" 

sudo apt-get install -y console-data
    sudo loadkeys fr
    sudo sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="fr"/' /etc/default/keyboard
    sudo dpkg-reconfigure -f noninteractive keyboard-configuration
	echo "LE CLAVIER EST PASSE EN FRANCAIS"

echo "
###### #####   ##   #####  ###### 
#        #    #  #  #    # #      
#####    #   #    # #    # #####  
#        #   ###### #####  #      
#        #   #    # #      #      
######   #   #    # #      ###### 
                                  
                                                  
 ####  #    # # #    #   ##   #    # ##### ###### 
#      #    # # #    #  #  #  ##   #   #   #      
 ####  #    # # #    # #    # # #  #   #   #####  
     # #    # # #    # ###### #  # #   #   #      
#    # #    # #  #  #  #    # #   ##   #   #      
 ####   ####  #   ##   #    # #    #   #   ######" 

# Étape : Modifier le port SSH
read -p "Entrez le nouveau port SSH (par défaut 22) : " SSH_PORT
if [[ -z "$SSH_PORT" ]]; then
  SSH_PORT=22
fi
if [[ "$SSH_PORT" =~ ^[0-9]+$ && $SSH_PORT -ge 1 && $SSH_PORT -le 65535 ]]; then
  sed -i "s/^#\?Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
  sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config
  systemctl restart sshd
  check_command
else
  echo "[ERREUR] Port SSH invalide. Cette étape est ignorée."
fi

echo "
###### #####   ##   #####  ###### 
#        #    #  #  #    # #      
#####    #   #    # #    # #####  
#        #   ###### #####  #      
#        #   #    # #      #      
######   #   #    # #      ###### 
                                  
                                                  
 ####  #    # # #    #   ##   #    # ##### ###### 
#      #    # # #    #  #  #  ##   #   #   #      
 ####  #    # # #    # #    # # #  #   #   #####  
     # #    # # #    # ###### #  # #   #   #      
#    # #    # #  #  #  #    # #   ##   #   #      
 ####   ####  #   ##   #    # #    #   #   ######" 

# Étape : Créer un utilisateur standard et désactiver l'accès root SSH
read -p "Entrez le nom de l'utilisateur standard : " STANDARD_USER
if [[ -n "$STANDARD_USER" ]]; then
  adduser $STANDARD_USER
  check_command
  usermod -aG sudo $STANDARD_USER
  check_command
  sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config
  systemctl restart sshd
  check_command
else
  echo "[AVERTISSEMENT] Aucun utilisateur standard créé."
fi

# Affichage d'un récapitulatif
echo "Configuration terminée ! Voici les changements effectués :"
echo "- Système mis à jour"
echo "- Hostname modifié : $NEW_HOSTNAME"
echo "- Port SSH : $SSH_PORT"
echo "- Utilisateur standard créé : $STANDARD_USER"
if [[ "$CONFIGURE_IP" == "y" ]]; then
  echo "- IP fixe configurée sur l'interface $INTERFACE avec l'adresse $STATIC_IP"
fi

exit 0
