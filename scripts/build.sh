#!/bin/bash

# Script de Build Complet - Aramco Frontend
# Usage: ./scripts/build.sh [environment] [platform]
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
ENVIRONMENT=${1:-production}
PLATFORM=${2:-all}
BUILD_DIR="build"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="logs/build_${TIMESTAMP}.log"

# Créer le répertoire de logs
mkdir -p logs

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
    log "Vérification des prérequis..."
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé ou n'est pas dans le PATH"
        exit 1
    fi
    
    # Vérifier la version de Flutter
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log_info "Version Flutter: $FLUTTER_VERSION"
    
    # Vérifier les médecins Flutter
    log_info "Vérification de l'environnement Flutter..."
    flutter doctor -v > /tmp/flutter_doctor.log
    
    if [ $? -ne 0 ]; then
        log_warning "Certains problèmes détectés par Flutter Doctor"
        log_info "Vérifiez le fichier /tmp/flutter_doctor.log pour plus de détails"
    fi
    
    # Vérifier les variables d'environnement
    if [ ! -f ".env.$ENVIRONMENT" ]; then
        log_error "Fichier d'environnement .env.$ENVIRONMENT introuvable"
        exit 1
    fi
    
    log "Prérequis vérifiés avec succès"
}

# Fonction de nettoyage
clean_project() {
    log "Nettoyage du projet..."
    
    # Nettoyer Flutter
    flutter clean
    flutter pub cache clean
    
    # Nettoyer les anciens builds
    rm -rf $BUILD_DIR/
    
    # Nettoyer les fichiers générés
    find . -name "*.g.dart" -type f -delete
    find . -name "*.mocks.dart" -type f -delete
    
    log "Nettoyage terminé"
}

# Fonction d'installation des dépendances
install_dependencies() {
    log "Installation des dépendances..."
    
    # Installer les dépendances Flutter
    flutter pub get
    
    # Générer les fichiers nécessaires
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    log "Dépendances installées avec succès"
}

# Fonction de configuration de l'environnement
configure_environment() {
    log "Configuration de l'environnement $ENVIRONMENT..."
    
    # Copier le fichier d'environnement
    cp ".env.$ENVIRONMENT" .env
    
    # Vérifier les variables requises
    source .env
    
    if [ -z "$API_BASE_URL" ]; then
        log_error "API_BASE_URL n'est pas défini dans .env.$ENVIRONMENT"
        exit 1
    fi
    
    log "Environnement configuré avec succès"
}

# Fonction de tests
run_tests() {
    log "Exécution des tests..."
    
    # Tests unitaires
    flutter test --coverage --reporter=json > test_results.json
    
    if [ $? -ne 0 ]; then
        log_error "Les tests ont échoué"
        exit 1
    fi
    
    # Analyse du code
    flutter analyze
    
    if [ $? -ne 0 ]; then
        log_warning "L'analyse du code a détecté des warnings"
    fi
    
    log "Tests terminés avec succès"
}

# Fonction de build Android
build_android() {
    log "Build Android pour l'environnement $ENVIRONMENT..."
    
    case $ENVIRONMENT in
        "dev")
            flutter build apk --debug --flavor dev
            ;;
        "staging")
            flutter build apk --release --flavor staging
            ;;
        "production")
            flutter build apk --release --flavor prod
            flutter build appbundle --release --flavor prod
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "Build Android terminé avec succès"
        
        # Créer le répertoire de distribution
        mkdir -p dist/android
        
        # Copier les artifacts
        cp build/app/outputs/flutter-apk/*/*.apk dist/android/ 2>/dev/null || true
        cp build/app/outputs/bundle/*/*.aab dist/android/ 2>/dev/null || true
        
        # Générer le checksum
        cd dist/android
        for file in *.apk *.aab; do
            if [ -f "$file" ]; then
                sha256sum "$file" > "$file.sha256"
            fi
        done
        cd ../..
        
        log "Artifacts Android disponibles dans dist/android/"
    else
        log_error "Build Android a échoué"
        exit 1
    fi
}

# Fonction de build iOS
build_ios() {
    log "Build iOS pour l'environnement $ENVIRONMENT..."
    
    # Vérifier si on est sur macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_warning "Build iOS nécessite macOS, skip..."
        return 0
    fi
    
    case $ENVIRONMENT in
        "dev")
            flutter build ios --debug --flavor dev
            ;;
        "staging")
            flutter build ios --release --flavor staging
            ;;
        "production")
            flutter build ios --release --flavor prod
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "Build iOS terminé avec succès"
        
        # Créer le répertoire de distribution
        mkdir -p dist/ios
        
        # Copier les artifacts
        cp -r build/ios/iphoneos/Runner.app dist/ios/ 2>/dev/null || true
        
        log "Artifacts iOS disponibles dans dist/ios/"
    else
        log_error "Build iOS a échoué"
        exit 1
    fi
}

# Fonction de build Web
build_web() {
    log "Build Web pour l'environnement $ENVIRONMENT..."
    
    case $ENVIRONMENT in
        "dev")
            flutter build web --debug --web-renderer html
            ;;
        "staging")
            flutter build web --release --web-renderer canvaskit --base-href "/staging/"
            ;;
        "production")
            flutter build web --release --web-renderer canvaskit
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "Build Web terminé avec succès"
        
        # Créer le répertoire de distribution
        mkdir -p dist/web
        
        # Copier les artifacts
        cp -r build/web/* dist/web/
        
        # Optimiser les assets pour la production
        if [ "$ENVIRONMENT" = "production" ]; then
            # Compresser les images
            find dist/web/assets -name "*.png" -exec pngquant --quality=65-80 --output {} --force {} \;
            find dist/web/assets -name "*.jpg" -exec jpegoptim --max=80 {} \;
            
            # Minifier le HTML si possible
            if command -v html-minifier &> /dev/null; then
                html-minifier --collapse-whitespace --remove-comments --minify-css --minify-js -o dist/web/index.html dist/web/index.html
            fi
        fi
        
        # Générer le manifeste PWA
        cat > dist/web/manifest.json << EOF
{
  "name": "Aramco Frontend",
  "short_name": "Aramco",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#1976D2",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
        
        log "Artifacts Web disponibles dans dist/web/"
    else
        log_error "Build Web a échoué"
        exit 1
    fi
}

# Fonction de build complet
build_all() {
    log "Début du build complet pour l'environnement $ENVIRONMENT..."
    
    # Build Android
    build_android
    
    # Build iOS
    build_ios
    
    # Build Web
    build_web
    
    log "Build complet terminé avec succès"
}

# Fonction de génération du rapport
generate_report() {
    log "Génération du rapport de build..."
    
    cat > "dist/build_report_${TIMESTAMP}.json" << EOF
{
  "build_info": {
    "timestamp": "$TIMESTAMP",
    "environment": "$ENVIRONMENT",
    "platform": "$PLATFORM",
    "flutter_version": "$FLUTTER_VERSION",
    "git_commit": "$(git rev-parse HEAD)",
    "git_branch": "$(git branch --show-current)"
  },
  "artifacts": {
    "android": {
      "apk_files": $(ls dist/android/*.apk 2>/dev/null | wc -l),
      "aab_files": $(ls dist/android/*.aab 2>/dev/null | wc -l)
    },
    "ios": {
      "app_bundle": $([ -d "dist/ios/Runner.app" ] && echo "true" || echo "false")
    },
    "web": {
      "build_size": $(du -sh dist/web | cut -f1),
      "files_count": $(find dist/web -type f | wc -l)
    }
  },
  "tests": {
    "total_tests": $(cat test_results.json | jq '.tests' 2>/dev/null || echo "0"),
    "passed": $(cat test_results.json | jq '.passed' 2>/dev/null || echo "0"),
    "failed": $(cat test_results.json | jq '.failed' 2>/dev/null || echo "0"),
    "coverage": "$(cat coverage/lcov.info | grep -o 'lines......*' | tail -1 | grep -o '[0-9.]*%' || echo 'N/A')"
  }
}
EOF
    
    log "Rapport généré: dist/build_report_${TIMESTAMP}.json"
}

# Fonction principale
main() {
    log "Début du script de build - Aramco Frontend"
    log "Environnement: $ENVIRONMENT"
    log "Platform: $PLATFORM"
    log "Timestamp: $TIMESTAMP"
    
    # Vérifier les prérequis
    check_prerequisites
    
    # Nettoyer le projet
    clean_project
    
    # Installer les dépendances
    install_dependencies
    
    # Configurer l'environnement
    configure_environment
    
    # Exécuter les tests
    run_tests
    
    # Build selon la platforme
    case $PLATFORM in
        "android")
            build_android
            ;;
        "ios")
            build_ios
            ;;
        "web")
            build_web
            ;;
        "all")
            build_all
            ;;
        *)
            log_error "Platform non reconnue: $PLATFORM"
            log_info "Platforms disponibles: android, ios, web, all"
            exit 1
            ;;
    esac
    
    # Générer le rapport
    generate_report
    
    log "Build terminé avec succès!"
    log "Artifacts disponibles dans le répertoire dist/"
    log "Logs disponibles dans $LOG_FILE"
    log "Rapport disponible: dist/build_report_${TIMESTAMP}.json"
}

# Gestion des signaux
trap 'log_error "Script interrompu"; exit 1' INT TERM

# Exécuter la fonction principale
main "$@"
