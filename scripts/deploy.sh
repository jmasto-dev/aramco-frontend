#!/bin/bash

# Script de Déploiement - Aramco Frontend
# Usage: ./scripts/deploy.sh [environment] [platform]
# Environments: dev, staging, production
# Platforms: android, ios, web, all

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables par défaut
ENVIRONMENT=${1:-staging}
PLATFORM=${2:-web}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="logs/deploy_${TIMESTAMP}.log"
BACKUP_DIR="backups"
DEPLOY_CONFIG_FILE="deploy_config.json"

# Créer les répertoires nécessaires
mkdir -p logs
mkdir -p $BACKUP_DIR

# Fonction de log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Fonction de vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis de déploiement..."
    
    # Vérifier si les artifacts existent
    if [ ! -d "dist" ]; then
        log_error "Répertoire dist introuvable. Exécutez d'abord le script de build."
        exit 1
    fi
    
    # Vérifier la configuration de déploiement
    if [ ! -f "$DEPLOY_CONFIG_FILE" ]; then
        log_error "Fichier de configuration $DEPLOY_CONFIG_FILE introuvable"
        exit 1
    fi
    
    # Vérifier les outils nécessaires selon la plateforme
    case $PLATFORM in
        "android")
            if ! command -v adb &> /dev/null; then
                log_warning "ADB non trouvé, déploiement physique impossible"
            fi
            ;;
        "ios")
            if [[ "$OSTYPE" != "darwin"* ]]; then
                log_warning "Déploiement iOS nécessite macOS"
            fi
            ;;
        "web")
            if ! command -v firebase &> /dev/null && ! command -v rsync &> /dev/null; then
                log_warning "Aucun outil de déploiement web trouvé (firebase, rsync)"
            fi
            ;;
    esac
    
    log "Prérequis vérifiés avec succès"
}

# Fonction de configuration de l'environnement
load_deploy_config() {
    log "Chargement de la configuration de déploiement..."
    
    # Charger la configuration JSON
    if command -v jq &> /dev/null; then
        DEPLOY_HOST=$(jq -r ".environments.$ENVIRONMENT.host" $DEPLOY_CONFIG_FILE)
        DEPLOY_USER=$(jq -r ".environments.$ENVIRONMENT.user" $DEPLOY_CONFIG_FILE)
        DEPLOY_PATH=$(jq -r ".environments.$ENVIRONMENT.path" $DEPLOY_CONFIG_FILE)
        DEPLOY_URL=$(jq -r ".environments.$ENVIRONMENT.url" $DEPLOY_CONFIG_FILE)
        BACKUP_ENABLED=$(jq -r ".environments.$ENVIRONMENT.backup" $DEPLOY_CONFIG_FILE)
    else
        log_error "jq est requis pour parser la configuration de déploiement"
        exit 1
    fi
    
    if [ "$DEPLOY_HOST" = "null" ] || [ -z "$DEPLOY_HOST" ]; then
        log_error "Configuration pour l'environnement $ENVIRONMENT introuvable"
        exit 1
    fi
    
    log "Configuration chargée: $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH"
}

# Fonction de backup
create_backup() {
    if [ "$BACKUP_ENABLED" = "true" ]; then
        log "Création d'une backup..."
        
        BACKUP_NAME="backup_${ENVIRONMENT}_${TIMESTAMP}"
        BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
        
        case $PLATFORM in
            "web")
                if [ -d "$DEPLOY_PATH" ]; then
                    mkdir -p "$BACKUP_PATH"
                    cp -r "$DEPLOY_PATH"/* "$BACKUP_PATH/" 2>/dev/null || true
                    log "Backup web créé: $BACKUP_PATH"
                fi
                ;;
        esac
        
        # Compresser la backup
        tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "$BACKUP_NAME" 2>/dev/null || true
        rm -rf "$BACKUP_PATH" 2>/dev/null || true
        
        log "Backup compressée: $BACKUP_PATH.tar.gz"
    else
        log "Backup désactivé pour l'environnement $ENVIRONMENT"
    fi
}

# Fonction de déploiement Android
deploy_android() {
    log "Déploiement Android pour l'environnement $ENVIRONMENT..."
    
    case $ENVIRONMENT in
        "dev")
            # Déploiement sur appareil connecté
            if command -v adb &> /dev/null && adb devices | grep -q "device$"; then
                APK_FILE=$(find dist/android -name "*.apk" | head -n 1)
                if [ -f "$APK_FILE" ]; then
                    log "Installation de $APK_FILE sur l'appareil..."
                    adb install -r "$APK_FILE"
                    log "APK installé avec succès"
                else
                    log_error "Aucun fichier APK trouvé dans dist/android/"
                    exit 1
                fi
            else
                log_warning "Aucun appareil Android connecté"
                log_info "APK disponible dans dist/android/"
            fi
            ;;
        "staging"|"production")
            # Upload sur les stores de distribution
            AAB_FILE=$(find dist/android -name "*.aab" | head -n 1)
            if [ -f "$AAB_FILE" ]; then
                log "AAB prêt pour le déploiement: $AAB_FILE"
                log_info "Veuillez uploader manuellement sur Google Play Console"
                
                # Générer le checksum pour vérification
                sha256sum "$AAB_FILE" > "$AAB_FILE.deploy.sha256"
                log "Checksum généré: $AAB_FILE.deploy.sha256"
            else
                log_error "Aucun fichier AAB trouvé dans dist/android/"
                exit 1
            fi
            ;;
    esac
    
    log "Déploiement Android terminé"
}

# Fonction de déploiement iOS
deploy_ios() {
    log "Déploiement iOS pour l'environnement $ENVIRONMENT..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "Déploiement iOS nécessite macOS"
        return 0
    fi
    
    case $ENVIRONMENT in
        "dev")
            # Déploiement sur simulateur
            if command -v xcrun &> /dev/null; then
                APP_PATH="dist/ios/Runner.app"
                if [ -d "$APP_PATH" ]; then
                    log "Installation sur le simulateur iOS..."
                    xcrun simctl install booted "$APP_PATH"
                    xcrun simctl launch booted com.aramco.frontend
                    log "App installée et lancée sur le simulateur"
                else
                    log_error "App iOS introuvable: $APP_PATH"
                    exit 1
                fi
            fi
            ;;
        "staging"|"production")
            # Upload sur App Store Connect
            log_info "Veuillez utiliser Xcode pour uploader sur App Store Connect"
            log_info "App disponible dans: dist/ios/Runner.app"
            ;;
    esac
    
    log "Déploiement iOS terminé"
}

# Fonction de déploiement Web
deploy_web() {
    log "Déploiement Web pour l'environnement $ENVIRONMENT..."
    
    WEB_DIST_DIR="dist/web"
    
    if [ ! -d "$WEB_DIST_DIR" ]; then
        log_error "Répertoire de build web introuvable: $WEB_DIST_DIR"
        exit 1
    fi
    
    case $ENVIRONMENT in
        "dev")
            # Déploiement local pour développement
            if command -v python3 &> /dev/null; then
                log "Démarrage du serveur de développement local..."
                cd "$WEB_DIST_DIR"
                python3 -m http.server 8080 > /dev/null 2>&1 &
                SERVER_PID=$!
                cd ../..
                
                log "Serveur démarré sur http://localhost:8080 (PID: $SERVER_PID)"
                echo $SERVER_PID > .dev_server.pid
            else
                log_warning "Python3 non trouvé, serveur local non démarré"
            fi
            ;;
        "staging")
            # Déploiement sur Firebase Hosting (staging)
            if command -v firebase &> /dev/null; then
                log "Déploiement sur Firebase Hosting (staging)..."
                
                # Configurer Firebase pour staging
                firebase use aramco-frontend-staging 2>/dev/null || firebase use default
                
                # Déployer
                firebase deploy --only hosting:staging --message "Deploy staging $TIMESTAMP"
                
                log "Déploiement staging terminé"
                log_info "URL: https://staging.aramco-frontend.app"
            else
                # Déploiement via rsync si Firebase non disponible
                if [ -n "$DEPLOY_HOST" ] && command -v rsync &> /dev/null; then
                    log "Déploiement via rsync..."
                    rsync -avz --delete "$WEB_DIST_DIR/" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/staging/"
                    log "Déploiement rsync terminé"
                else
                    log_error "Aucun outil de déploiement disponible"
                    exit 1
                fi
            fi
            ;;
        "production")
            # Déploiement sur Firebase Hosting (production)
            if command -v firebase &> /dev/null; then
                log "Déploiement sur Firebase Hosting (production)..."
                
                # Vérification avant déploiement production
                read -p "Confirmer le déploiement en production? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    # Configurer Firebase pour production
                    firebase use aramco-frontend-production 2>/dev/null || firebase use default
                    
                    # Déployer
                    firebase deploy --only hosting:production --message "Deploy production $TIMESTAMP"
                    
                    log "Déploiement production terminé"
                    log_info "URL: https://aramco-frontend.app"
                else
                    log_warning "Déploiement production annulé"
                    exit 1
                fi
            else
                # Déploiement via rsync si Firebase non disponible
                if [ -n "$DEPLOY_HOST" ] && command -v rsync &> /dev/null; then
                    log "Déploiement production via rsync..."
                    
                    read -p "Confirmer le déploiement en production? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rsync -avz --delete "$WEB_DIST_DIR/" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/production/"
                        log "Déploiement rsync production terminé"
                    else
                        log_warning "Déploiement production annulé"
                        exit 1
                    fi
                else
                    log_error "Aucun outil de déploiement disponible"
                    exit 1
                fi
            fi
            ;;
    esac
    
    log "Déploiement Web terminé"
}

# Fonction de vérification post-déploiement
verify_deployment() {
    log "Vérification du déploiement..."
    
    case $PLATFORM in
        "web")
            if [ -n "$DEPLOY_URL" ]; then
                log_info "Vérification de l'URL: $DEPLOY_URL"
                
                # Vérifier si le site est accessible
                if command -v curl &> /dev/null; then
                    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL" || echo "000")
                    
                    if [ "$HTTP_CODE" = "200" ]; then
                        log "Site accessible (HTTP 200)"
                    else
                        log_warning "Site non accessible (HTTP $HTTP_CODE)"
                    fi
                fi
            fi
            ;;
    esac
    
    log "Vérification terminée"
}

# Fonction de notification
send_notification() {
    log "Envoi des notifications de déploiement..."
    
    # Notification Slack (si configuré)
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        MESSAGE="🚀 Aramco Frontend deployé sur $ENVIRONMENT ($PLATFORM) - $(date)"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$MESSAGE\"}" \
            "$SLACK_WEBHOOK_URL" 2>/dev/null || true
    fi
    
    # Notification email (si configuré)
    if command -v mail &> /dev/null && [ -n "$DEPLOY_EMAIL" ]; then
        echo "Déploiement terminé avec succès sur $ENVIRONMENT" | mail -s "Aramco Frontend Deploy $ENVIRONMENT" "$DEPLOY_EMAIL" 2>/dev/null || true
    fi
    
    log "Notifications envoyées"
}

# Fonction de nettoyage
cleanup() {
    log "Nettoyage des fichiers temporaires..."
    
    # Arrêter le serveur de développement si nécessaire
    if [ -f ".dev_server.pid" ]; then
        SERVER_PID=$(cat .dev_server.pid)
        if kill -0 "$SERVER_PID" 2>/dev/null; then
            kill "$SERVER_PID"
            log "Serveur de développement arrêté"
        fi
        rm -f .dev_server.pid
    fi
    
    # Nettoyer les anciennes backups (garder les 10 dernières)
    find $BACKUP_DIR -name "backup_*.tar.gz" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true
    
    log "Nettoyage terminé"
}

# Fonction de rollback
rollback() {
    log "Rollback du déploiement..."
    
    # Trouver la backup la plus récente
    LATEST_BACKUP=$(find $BACKUP_DIR -name "backup_${ENVIRONMENT}_*.tar.gz" -type f | sort -r | head -n 1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        log "Restauration depuis: $LATEST_BACKUP"
        
        case $PLATFORM in
            "web")
                # Extraire la backup
                tar -xzf "$LATEST_BACKUP" -C "$BACKUP_DIR"
                
                # Trouver le répertoire extrait
                EXTRACTED_DIR=$(tar -tzf "$LATEST_BACKUP" | head -n 1 | cut -f1 -d"/")
                
                # Restaurer les fichiers
                if [ -n "$DEPLOY_HOST" ] && command -v rsync &> /dev/null; then
                    rsync -avz --delete "$BACKUP_DIR/$EXTRACTED_DIR/" "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/"
                    log "Rollback web terminé"
                fi
                
                # Nettoyer le répertoire extrait
                rm -rf "$BACKUP_DIR/$EXTRACTED_DIR"
                ;;
        esac
        
        log "Rollback terminé avec succès"
    else
        log_error "Aucune backup trouvée pour le rollback"
        exit 1
    fi
}

# Fonction principale
main() {
    log "Début du script de déploiement - Aramco Frontend"
    log "Environnement: $ENVIRONMENT"
    log "Platform: $PLATFORM"
    log "Timestamp: $TIMESTAMP"
    
    # Vérifier si c'est un rollback
    if [ "$1" = "rollback" ]; then
        rollback
        exit 0
    fi
    
    # Vérifier les prérequis
    check_prerequisites
    
    # Charger la configuration
    load_deploy_config
    
    # Créer une backup
    create_backup
    
    # Déployer selon la plateforme
    case $PLATFORM in
        "android")
            deploy_android
            ;;
        "ios")
            deploy_ios
            ;;
        "web")
            deploy_web
            ;;
        "all")
            deploy_android
            deploy_ios
            deploy_web
            ;;
        *)
            log_error "Platform non reconnue: $PLATFORM"
            log_info "Platforms disponibles: android, ios, web, all"
            exit 1
            ;;
    esac
    
    # Vérifier le déploiement
    verify_deployment
    
    # Envoyer les notifications
    send_notification
    
    # Nettoyer
    cleanup
    
    log "Déploiement terminé avec succès!"
    log "Logs disponibles dans $LOG_FILE"
}

# Gestion des signaux
trap 'log_error "Script interrompu"; cleanup; exit 1' INT TERM

# Afficher l'aide
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [environment] [platform]"
    echo "       $0 rollback [environment] [platform]"
    echo ""
    echo "Environments: dev, staging, production"
    echo "Platforms: android, ios, web, all"
    echo ""
    echo "Examples:"
    echo "  $0 staging web"
    echo "  $0 production android"
    echo "  $0 rollback production web"
    exit 0
fi

# Exécuter la fonction principale
main "$@"
