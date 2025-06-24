#!/bin/bash
source ./variables.sh
source ./logo.sh
# ---------- La partie fonction de ATIN_CENTOS ------------------

# --- Fonctions d'affichage ---
function error_exit {
    echo -e "${RED}ERREUR: $1${NC}" | tee -a "$LOG_FILE" >&2 # Affiche l'erreur en rouge gras et log
    exit 1
}

# --- Fonctions pour les commandes ------

# Check if firewalld is active
check_firewalld() {
    if ! systemctl is-active --quiet firewalld; then
        echo "❌ firewalld n'est pas actif. Activation..."
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
        echo "✅ firewalld est maintenant actif."
    fi
}

# Reload firewall after changes
reload_firewalld() {
    sudo firewall-cmd --reload > /dev/null
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

function switch_function {
    #Code à utiliser (Mettre à jour tous les paquets de Centos) : sudo yum update --enablerepo='*'
    #Code à utiliser (Mettre à jour tous les paquets sur Centos avec dnf): sudo dnf update --enablerepo='*'
    #Code à utiliser ( Vérification des paquets à installe ) : sudo dnf check-upgrade

    case $1 in
        1.* )
            info_msg "📦 Mise à jour des paquets CentOS..."

            if sudo dnf -y update --enablerepo='*'; then
                success_msg "✅ Mise à jour des paquets CentOS réussie ! 🎉"
            else
                error_exit "❌ La mise à jour des paquets CentOS a échoué ⚠️"
            fi
            ;;

        2.* )
            info_msg "🧹 Nettoyage du cache des paquets..."

            if sudo dnf clean all; then
                success_msg "✅ Cache des paquets nettoyé avec succès !"
            else
                error_exit "❌ Échec du nettoyage du cache des paquets."
            fi

            info_msg "🗑️ Suppression des paquets orphelins..."

            if sudo dnf autoremove -y; then
                success_msg "✅ Paquets orphelins supprimés avec succès !"
            else
                error_exit "❌ Échec de la suppression des paquets orphelins."
            fi

            ;;
        3.* )
            info_msg "💽 Vérification de l'utilisation de l'espace disque..."

            if df -h --total; then
                usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
                if [ "$usage" -ge 90 ]; then
                    echo -e "⚠️  Avertissement : l'utilisation du disque est à ${usage}% !"
                fi
                success_msg "✅ Utilisation de l'espace disque vérifiée."
            else
                error_exit "❌ Échec de la vérification de l'espace disque."
            fi
            ;;

        4.* )
            TARGET_DIR="."  # Tu peux remplacer par /var, /home, etc.

            info_msg "📂 Identification des fichiers/répertoires les plus volumineux dans '$TARGET_DIR'..."
            total_size=$(du -sh "$TARGET_DIR" 2>/dev/null | cut -f1)
            info_msg "📊 Taille totale de '$TARGET_DIR' : $total_size"

            if du -h --max-depth=1 "$TARGET_DIR" 2>/dev/null | sort -hr | head -n 10; then
                success_msg "✅ Liste des fichiers/répertoires les plus volumineux générée avec succès."
            else
                error_exit "❌ Échec de l'identification des fichiers/répertoires volumineux dans '$TARGET_DIR'."
            fi
            ;;

        5.* )
            info_msg "Nettoyage des fichiers temporaires ou des vieux logs"

            read -p "⚠️ Cette action supprimera des fichiers dans /tmp et /var/log. Voulez-vous continuer ? (oui/non) : " confirmation

            if [[ "$confirmation" =~ ^([Oo][Uu][Ii]|[Yy]es|[Oo])$ ]]; then
                if sudo rm -rf /tmp/* /var/log/*; then
                    success_msg "✅ Nettoyage des fichiers temporaires ou des vieux logs réussi"
                else
                    error_exit "❌ Le nettoyage des fichiers temporaires ou des vieux logs a échoué"
                fi
            else
                echo "❎ Opération annulée par l'utilisateur."
            fi
            ;;

        6.* )
            info_msg "⚙️  Gestion interactive des services systemctl"

            # Récupérer la liste des services disponibles
            mapfile -t services < <(systemctl list-units --type=service --all --no-pager --no-legend | awk '{print $1}')

            if [ ${#services[@]} -eq 0 ]; then
                error_exit "❌ Aucun service systemctl trouvé sur ce système."
            fi

            # Afficher les services avec numérotation
            echo "📋 Liste des services disponibles :"
            for i in "${!services[@]}"; do
                printf "%3d) %s\n" $((i+1)) "${services[$i]}"
            done

            # Sélection du service
            read -rp "🔢 Entrez le numéro du service à gérer : " service_index

            # Validation du numéro
            if ! [[ "$service_index" =~ ^[0-9]+$ ]] || [ "$service_index" -lt 1 ] || [ "$service_index" -gt "${#services[@]}" ]; then
                error_exit "🚫 Numéro de service invalide."
            fi

            SERVICE_NAME="${services[$((service_index-1))]}"
            info_msg "🔧 Service sélectionné : $SERVICE_NAME"

            # Choix de l'action
            echo "🎛️  Actions possibles : start, stop, restart, status, enable, disable"
            read -rp "🧭 Entrez l'action à effectuer : " ACTION

            case "$ACTION" in
                start|stop|restart|status|enable|disable)
                    info_msg "🔧 Exécution : systemctl $ACTION $SERVICE_NAME"
                    if sudo systemctl "$ACTION" "$SERVICE_NAME"; then
                        success_msg "✅ Action '$ACTION' sur '$SERVICE_NAME' exécutée avec succès."
                    else
                        error_exit "❌ L'action '$ACTION' sur '$SERVICE_NAME' a échoué."
                    fi
                    ;;
                *)
                    error_exit "🚫 Action invalide. Veuillez utiliser : start, stop, restart, status, enable ou disable."
                    ;;
            esac
            ;;
        7.* )
            info_msg "🛠️ Vérification et mise à jour des services installés sur le système CentOS..."

            declare -A SERVICE_TO_PACKAGE_MAP
            declare -A UPDATES_PENDING_SERVICES

            info_msg "📥 Récupération de la liste des services connus..."

            SERVICES=$(systemctl list-unit-files --type=service --state=enabled,static,disabled,generated --no-legend --plain --full \
                | awk '{print $1}' \
                | sed 's/\.service$//' \
                | grep -Ev '^(systemd-|dev-|proc-|sys-|tmp-|var-|run-|usr-|local-|home-|mnt-|opt-|srv-|boot-).*|.*\.mount$|.*\.slice$|.*\.socket$|.*\.path$|.*\.timer$')

            if [ -z "$SERVICES" ]; then
                error_exit "❌ Aucun service applicable trouvé sur le système."
            fi

            info_msg "🔍 Détection des paquets associés et vérification des mises à jour..."

            for service_name in $SERVICES; do
                package_name=""
                case "$service_name" in
                    httpd)        package_name="httpd" ;;
                    nginx)        package_name="nginx" ;;
                    mariadb)      package_name="mariadb-server" ;;
                    postgresql)   package_name="postgresql-server" ;;
                    docker)       package_name="docker-ce" ;;
                    sshd)         package_name="openssh-server" ;;
                    firewalld)    package_name="firewalld" ;;
                    crond)        package_name="cronie" ;;
                    rsyslog)      package_name="rsyslog" ;;
                    *)
                        if systemctl status "$service_name" &>/dev/null; then
                            pid=$(systemctl show "$service_name" --property=MainPID --value 2>/dev/null)
                            if [ -n "$pid" ] && [ "$pid" -ne 0 ]; then
                                binary_path=$(readlink -f "/proc/$pid/exe")
                                if [ -e "$binary_path" ]; then
                                    package_full=$(rpm -qf "$binary_path" 2>/dev/null)
                                    if [[ "$package_full" != *"is not owned by any package"* ]]; then
                                        package_name=$(echo "$package_full" | sed 's/-[0-9].*$//')
                                    fi
                                fi
                            fi
                        fi
                        [ -z "$package_name" ] && package_name="$service_name"
                        ;;
                esac

                if [ -n "$package_name" ]; then
                    SERVICE_TO_PACKAGE_MAP["$service_name"]="$package_name"
                    if sudo dnf list installed "$package_name" &>/dev/null; then
                        if sudo dnf check-update "$package_name" &>/dev/null; then
                            UPDATES_PENDING_SERVICES["$service_name"]="$package_name"
                        fi
                    fi
                fi
            done

            if [ ${#UPDATES_PENDING_SERVICES[@]} -eq 0 ]; then
                success_msg "✅ Aucun service n'a de mise à jour de paquet en attente."
            else
                info_msg "📦 Mises à jour disponibles pour les services suivants :"
                for service_name in "${!UPDATES_PENDING_SERVICES[@]}"; do
                    echo " - $service_name (Paquet : ${UPDATES_PENDING_SERVICES[$service_name]})"
                done

                read -rp "🔁 Voulez-vous mettre à jour ces paquets ? (oui/non) : " update_confirm
                if [[ "$update_confirm" =~ ^([oO][uU][iI]|[yY][eE][sS])$ ]]; then
                    for service_name in "${!UPDATES_PENDING_SERVICES[@]}"; do
                        package_to_update="${UPDATES_PENDING_SERVICES[$service_name]}"
                        info_msg "📤 Mise à jour de '$package_to_update' pour '$service_name'..."
                        if sudo dnf update -y "$package_to_update"; then
                            success_msg "✅ '$package_to_update' mis à jour avec succès."

                            if systemctl is-active "$service_name" &>/dev/null; then
                                info_msg "🔁 Le service '$service_name' est actif. Redémarrage recommandé."
                                read -rp "👉 Voulez-vous redémarrer '$service_name' maintenant ? (oui/non) : " restart_service
                                if [[ "$restart_service" =~ ^([oO][uU][iI]|[yY][eE][sS])$ ]]; then
                                    info_msg "🚀 Redémarrage de '$service_name'..."
                                    if sudo systemctl restart "$service_name"; then
                                        success_msg "✅ '$service_name' redémarré avec succès."
                                    else
                                        error_msg "⚠️ Échec du redémarrage de '$service_name'."
                                    fi
                                else
                                    info_msg "⏭️ Redémarrage ignoré pour '$service_name'."
                                fi
                            else
                                info_msg "ℹ️  Le service '$service_name' est inactif. Aucun redémarrage nécessaire."
                            fi
                        else
                            error_msg "❌ Échec de la mise à jour du paquet '$package_to_update'."
                        fi
                    done
                    success_msg "🎉 Mise à jour des services terminée."
                else
                    info_msg "🚫 Mise à jour annulée par l'utilisateur."
                fi
            fi
            ;;

        8.* )
            info_msg "🛡️  Gestion du pare-feu (firewalld) - CentOS"

            # Vérifie si firewalld est actif
            if ! systemctl is-active firewalld &>/dev/null; then
                error_msg "Le service firewalld n'est pas actif. Tentative de démarrage..."
                if sudo systemctl start firewalld; then
                    success_msg "firewalld a été démarré avec succès."
                else
                    error_exit "Impossible de démarrer firewalld. Opération annulée."
                fi
            fi

            echo "Que souhaitez-vous faire ?"
            echo "1) 🔓 Ouvrir un port"
            echo "2) 🔐 Fermer un port"
            echo "3) ✅ Autoriser un service (http, ssh, etc.)"
            echo "4) ❌ Supprimer un service autorisé"
            read -rp "👉 Entrez le numéro de votre choix : " CHOICE

            ZONE="public"

            case "$CHOICE" in
                1)
                    read -rp "🔢 Entrez le port à ouvrir (ex: 8080/tcp) : " PORT
                    if sudo firewall-cmd --zone=$ZONE --add-port="$PORT" --permanent && sudo firewall-cmd --reload; then
                        success_msg "Le port $PORT a été ouvert avec succès."
                    else
                        error_msg "Échec de l'ouverture du port $PORT."
                    fi
                    ;;
                2)
                    read -rp "🚪 Entrez le port à fermer (ex: 8080/tcp) : " PORT
                    if sudo firewall-cmd --zone=$ZONE --remove-port="$PORT" --permanent && sudo firewall-cmd --reload; then
                        success_msg "Le port $PORT a été fermé avec succès."
                    else
                        error_msg "Échec de la fermeture du port $PORT."
                    fi
                    ;;
                3)
                    read -rp "🧩 Entrez le nom du service à autoriser (ex: http, ssh) : " SERVICE
                    if sudo firewall-cmd --zone=$ZONE --add-service="$SERVICE" --permanent && sudo firewall-cmd --reload; then
                        success_msg "Le service '$SERVICE' a été autorisé avec succès."
                    else
                        error_msg "Échec de l'autorisation du service '$SERVICE'."
                    fi
                    ;;
                4)
                    read -rp "🧼 Entrez le nom du service à supprimer (ex: http, ssh) : " SERVICE
                    if sudo firewall-cmd --zone=$ZONE --remove-service="$SERVICE" --permanent && sudo firewall-cmd --reload; then
                        success_msg "Le service '$SERVICE' a été supprimé avec succès."
                    else
                        error_msg "Échec de la suppression du service '$SERVICE'."
                    fi
                    ;;
                *)
                    error_msg "❗ Choix invalide. Veuillez sélectionner une option entre 1 et 4."
                    ;;
            esac
            ;;
        9.* )
            info_msg "Vérification de la sécurité du système"
            if sudo dnf update && sudo dnf upgrade && sudo dnf autoremove && sudo apt-get autoclean; then
                success_msg "Vérification de la sécurité du système réussie"
            else
                error_exit "La vérification de la sécurité du système a échoué"
            fi
            ;;
        10.* )
             info_msg 
}