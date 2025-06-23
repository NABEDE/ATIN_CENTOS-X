#!/bin/bash
source ./variables.sh
source ./logo.sh
# ---------- La partie fonction de ATIN_CENTOS ------------------

# --- Fonctions d'affichage ---
function error_exit {
    echo -e "${RED}ERREUR: $1${NC}" | tee -a "$LOG_FILE" >&2 # Affiche l'erreur en rouge gras et log
    #exit 1
}

function info_msg {
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE" # Affiche l'information en bleu gras et log
}

function success_msg {
    echo -e "${GREEN}$1${NC}" | tee -a "$LOG_FILE" # Affiche le succès en vert gras et log
}

function warn_msg {
    echo -e "${YELLOW}AVERTISSEMENT: $1${NC}" | tee -a "$LOG_FILE" # Affiche l'avertissement en jaune gras et log
}

# ------------------ Fonction de l'interaction avec l'utilisateur dans ATIN_CENTOS ---------------------------

# ----------- Fonction pour afficher les éléments pour interagir avec l'utilisateur ------------------------
function user_interaction {
    # ----------------- Présentation des éléments de choix pour l'utilisateur afin qu'il puisse interagir avec l'outil. ----------------------------
     echo -e "${RED}=========== ATIN_CENTOS-1.0 ================${NC}"
     # Si vous voulez une version un peu plus "étoilée" visuellement :
     logo
     echo " ===================================================="
     echo "1. Mettre à jour tous les paquets installés sur votre Système Centos -----"
     echo "2. Nettoyer le cache des paquets et supprimer les paquets orphelins -----"
     echo "3. Vérifier l'utilisation de l'espace disque ---------"
     echo "4. Identifier les fichiers ou répertoires les plus volumineux ------"
     echo "5. Nettoyer les fichiers temporaires ou les vieux logs --------"
     echo "6. Démarrer, arrêter, redémarrer et vérifier l'état des services (systemctl start/stop/status/enable) ------"
     echo "7. Gérer les services au démarrage du système --------"
     echo "8. Ajouter ou supprimer des règles de pare-feu (ouvrir des ports, autoriser des services) ------"
     echo "9. Activer ou désactiver des zones de pare-feu ---------"
     echo "10. Recharger les configurations du pare-feu ----------"
     echo "11. Automatiser l'installation de serveurs web (Apache/Nginx), de bases de données (MariaDB/PostgreSQL), ou d'environnements de scripting (PHP, Python, Node.js) etc ------"
     echo "12. Gérer l'ajout de dépôts tiers (EPEL, Remi, etc.) si nécessaire -----"
     echo "13. Afficher l'état des interfaces réseau (ip a, ss -tulpn) ------"
     echo "14. Changer l'adresse IP statique ou configurer le DHCP (bien que cela soit souvent géré par NetworkManager sur les versions plus récentes) -----"
     echo "15. Rechercher des erreurs ou des avertissements spécifiques dans les journaux (journalctl, /var/log/) ----"
     echo "16. Archiver ou purger les anciens fichiers journaux -------"
     echo "17. Vérifier l'état du swap (swapon --show) ----"
     echo "18. Créer et activer un fichier de swap si nécessaire ----"
     echo "19. Générer des rapports simples sur l'état du système : utilisation du CPU/mémoire, processus en cours, uptime -----"
     echo "20. Stocker ces rapports dans un fichier ou les envoyer par e-mail (si un MTA est configuré) ------"
     echo "21. Quitter ---- "
}

# --- Fonction d'aide ---
function show_help {
    echo -e "${BLUE}Naviguez vers le dossier apps : cd app/centos${NC}"
    echo -e "${BLUE}Rendre exécutable le fichier install : chmod +x install.sh${NC}"
    echo -e "${BLUE}Utilisation: sudo ./install.sh${NC}"
    echo -e "${BLUE}Ce script va vous aider dans l'assistance à dans l'administration Système Centos.${NC}"
    echo -e "${BLUE}Options disponibles:${NC}"
    echo -e "${GREEN}--help${NC}    Affiche ce message d'aide."
    echo -e "${GREEN}--no-confirm${NC}  Exécute le script sans demander de confirmation."
    echo -e "\n${YELLOW}Assurez-vous d'avoir une connexion internet active.${NC}"
    exit 0
}