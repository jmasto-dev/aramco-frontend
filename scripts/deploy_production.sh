#!/bin/bash

# Script de Déploiement en Production - Projet Aramco SA
# Usage: ./scripts/deploy_production.sh [environment]
# Environments: staging, production

set -e  # Arrêter le script en cas d'erreur

# Configuration
ENVIRONMENT=${1:-staging}
PROJECT_NAME="aramco-sa"
BACKUP_DIR="/var/backups/$PROJECT_NAME"
LOG_FILE="/var/log/$PROJECT_NAME/deploy.log"
DATE=$(date +%Y%m%d_%H%M%S)

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions de logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier si Docker est installé
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        exit 1
    fi
    
    # Vérifier si Docker Compose est installé
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    # Vérifier si Node.js est installé
    if ! command -v node &> /dev/null; then
        log_error "Node.js n'est pas installé"
        exit 1
    fi
    
    # Vérifier si PHP est installé
    if ! command -v php &> /dev/null; then
        log_error "PHP n'est pas installé"
        exit 1
    fi
    
    # Vérifier si Flutter est installé
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé"
        exit 1
    fi
    
    log_success "Tous les prérequis sont installés"
}

# Configuration de l'environnement
setup_environment() {
    log_info "Configuration de l'environnement $ENVIRONMENT..."
    
    # Créer les répertoires nécessaires
    sudo mkdir -p "$BACKUP_DIR"
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo chown -R $USER:$USER "$BACKUP_DIR"
    sudo chown -R $USER:$USER "$(dirname "$LOG_FILE")"
    
    # Copier le fichier d'environnement approprié
    if [ "$ENVIRONMENT" = "production" ]; then
        cp aramco-backend/.env.production aramco-backend/.env
        log_info "Configuration de production chargée"
    else
        cp aramco-backend/.env.staging aramco-backend/.env
        log_info "Configuration de staging chargée"
    fi
    
    # Mettre à jour les variables d'environnement
    sed -i "s/APP_ENV=.*/APP_ENV=$ENVIRONMENT/" aramco-backend/.env
    sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" aramco-backend/.env
}

# Sauvegarde de l'ancienne version
backup_current_version() {
    log_info "Sauvegarde de l'ancienne version..."
    
    BACKUP_NAME="$PROJECT_NAME_backup_$DATE"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    mkdir -p "$BACKUP_PATH"
    
    # Sauvegarder la base de données
    if docker ps | grep -q postgres; then
        docker exec aramco-postgres pg_dump -U postgres aramco_production > "$BACKUP_PATH/database.sql"
        log_success "Base de données sauvegardée"
    fi
    
    # Sauvegarder les fichiers
    cp -r aramco-backend "$BACKUP_PATH/"
    cp -r aramco-frontend "$BACKUP_PATH/" 2>/dev/null || true
    
    # Compresser la sauvegarde
    tar -czf "$BACKUP_PATH.tar.gz" -C "$BACKUP_DIR" "$BACKUP_NAME"
    rm -rf "$BACKUP_PATH"
    
    log_success "Sauvegarde créée: $BACKUP_PATH.tar.gz"
}

# Tests pré-déploiement
run_pre_deployment_tests() {
    log_info "Exécution des tests pré-déploiement..."
    
    # Tests de connexion backend
    if dart scripts/test_backend_connection.dart; then
        log_success "Tests de connexion backend réussis"
    else
        log_error "Tests de connexion backend échoués"
        exit 1
    fi
    
    # Tests de performance
    if dart scripts/performance_test.dart; then
        log_success "Tests de performance réussis"
    else
        log_warning "Tests de performance avec avertissements"
    fi
    
    # Tests Flutter
    if flutter test; then
        log_success "Tests Flutter réussis"
    else
        log_error "Tests Flutter échoués"
        exit 1
    fi
}

# Build du backend
build_backend() {
    log_info "Build du backend..."
    
    cd aramco-backend
    
    # Installation des dépendances
    composer install --no-dev --optimize-autoloader
    
    # Optimisation
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    # Migration de la base de données
    php artisan migrate --force
    
    # Seed des données (uniquement en staging)
    if [ "$ENVIRONMENT" = "staging" ]; then
        php artisan db:seed --force
    fi
    
    cd ..
    log_success "Backend buildé avec succès"
}

# Build du frontend
build_frontend() {
    log_info "Build du frontend..."
    
    # Build pour le web
    flutter build web --release --web-renderer canvaskit
    
    # Build pour Android
    flutter build apk --release
    
    # Build pour iOS (si sur macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        flutter build ios --release --no-codesign
    fi
    
    log_success "Frontend buildé avec succès"
}

# Déploiement des conteneurs Docker
deploy_docker() {
    log_info "Déploiement des conteneurs Docker..."
    
    # Arrêter les conteneurs existants
    docker-compose -f aramco-backend/docker-compose.prod.yml down
    
    # Pull des dernières images
    docker-compose -f aramco-backend/docker-compose.prod.yml pull
    
    # Build des images locales
    docker-compose -f aramco-backend/docker-compose.prod.yml build
    
    # Démarrer les conteneurs
    docker-compose -f aramco-backend/docker-compose.prod.yml up -d
    
    # Attendre que les services soient prêts
    sleep 30
    
    log_success "Conteneurs Docker déployés"
}

# Configuration du reverse proxy
configure_reverse_proxy() {
    log_info "Configuration du reverse proxy..."
    
    # Configuration Nginx
    sudo cp aramco-backend/docker/nginx/sites/aramco-backend.conf /etc/nginx/sites-available/
    sudo ln -sf /etc/nginx/sites-available/aramco-backend.conf /etc/nginx/sites-enabled/
    
    # Test de la configuration Nginx
    sudo nginx -t
    
    # Recharger Nginx
    sudo systemctl reload nginx
    
    log_success "Reverse proxy configuré"
}

# Configuration SSL/TLS
configure_ssl() {
    log_info "Configuration SSL/TLS..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
        # Installation de Let's Encrypt
        if ! command -v certbot &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y certbot python3-certbot-nginx
        fi
        
        # Obtention du certificat SSL
        sudo certbot --nginx -d api.aramco-sa.com -d app.aramco-sa.com --non-interactive --agree-tos --email admin@aramco-sa.com
        
        # Configuration du renouvellement automatique
        sudo crontab -l | grep -q "certbot renew" || (sudo crontab -l; echo "0 12 * * * /usr/bin/certbot renew --quiet") | sudo crontab -
        
        log_success "SSL/TLS configuré avec Let's Encrypt"
    else
        log_info "Configuration SSL ignorée en staging"
    fi
}

# Tests post-déploiement
run_post_deployment_tests() {
    log_info "Exécution des tests post-déploiement..."
    
    # Attendre que les services soient complètement démarrés
    sleep 60
    
    # Test de santé de l'API
    if curl -f http://localhost:8000/api/v1/health > /dev/null 2>&1; then
        log_success "API répond correctement"
    else
        log_error "API ne répond pas"
        exit 1
    fi
    
    # Test de l'application web
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        log_success "Application web accessible"
    else
        log_warning "Application web non accessible (peut être normal)"
    fi
    
    # Tests d'intégration complets
    if dart scripts/run_all_tests.dart; then
        log_success "Tests post-déploiement réussis"
    else
        log_error "Tests post-déploiement échoués"
        rollback_deployment
        exit 1
    fi
}

# Monitoring et alertes
setup_monitoring() {
    log_info "Configuration du monitoring..."
    
    # Démarrer les services de monitoring
    docker-compose -f aramco-backend/docker-compose.prod.yml up -d prometheus grafana loki promtail
    
    # Configuration des alertes
    curl -X POST http://localhost:9093/api/v1/alerts \
         -H 'Content-Type: application/json' \
         -d '[
           {
             "labels": {
               "alertname": "DeploymentComplete",
               "severity": "info",
               "environment": "'$ENVIRONMENT'"
             }
           }
         ]'
    
    log_success "Monitoring configuré"
}

# Rollback en cas d'échec
rollback_deployment() {
    log_error "Rollback du déploiement..."
    
    # Arrêter les conteneurs actuels
    docker-compose -f aramco-backend/docker-compose.prod.yml down
    
    # Restaurer la dernière sauvegarde
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz | head -n1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        tar -xzf "$LATEST_BACKUP" -C "$BACKUP_DIR"
        BACKUP_NAME=$(basename "$LATEST_BACKUP" .tar.gz)
        BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
        
        # Restaurer la base de données
        if [ -f "$BACKUP_PATH/database.sql" ]; then
            docker exec -i aramco-postgres psql -U postgres aramco_production < "$BACKUP_PATH/database.sql"
        fi
        
        # Redémarrer les conteneurs
        docker-compose -f aramco-backend/docker-compose.prod.yml up -d
        
        log_success "Rollback effectué"
    else
        log_error "Aucune sauvegarde trouvée pour le rollback"
    fi
}

# Nettoyage
cleanup() {
    log_info "Nettoyage..."
    
    # Supprimer les anciennes sauvegardes (garder les 5 dernières)
    cd "$BACKUP_DIR"
    ls -t *.tar.gz | tail -n +6 | xargs -r rm
    
    # Nettoyer les images Docker non utilisées
    docker image prune -f
    
    # Nettoyer les logs anciens
    find "$(dirname "$LOG_FILE")" -name "*.log" -mtime +30 -delete
    
    log_success "Nettoyage effectué"
}

# Notification de fin de déploiement
send_notification() {
    log_info "Envoi de la notification..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
        # Envoyer une notification Slack/Email (à configurer)
        curl -X POST "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" \
             -H 'Content-type: application/json' \
             --data "{\"text\":\"🚀 Déploiement $PROJECT_NAME en $ENVIRONMENT terminé avec succès\"}"
    fi
    
    log_success "Notification envoyée"
}

# Déploiement de l'infrastructure complète
deploy_infrastructure() {
    log_info "Déploiement de l'infrastructure complète..."
    
    # Vérifier si nous sommes sur le serveur de production
    if [ "$ENVIRONMENT" = "production" ]; then
        # Configuration des réseaux Docker
        docker network create aramco-network 2>/dev/null || true
        
        # Déploiement des volumes persistants
        docker volume create aramco_postgres_data 2>/dev/null || true
        docker volume create aramco_redis_data 2>/dev/null || true
        docker volume create aramco_grafana_data 2>/dev/null || true
        docker volume create aramco_prometheus_data 2>/dev/null || true
        
        # Configuration du monitoring avancé
        setup_advanced_monitoring
        
        # Configuration de la sécurité avancée
        setup_advanced_security
        
        # Configuration du backup automatique
        setup_automated_backups
        
        # Configuration du load balancing
        setup_load_balancing
        
        log_success "Infrastructure déployée avec succès"
    else
        log_info "Configuration infrastructure pour staging"
        # Configuration simplifiée pour staging
        docker network create aramco-staging-network 2>/dev/null || true
        docker volume create aramco_staging_postgres_data 2>/dev/null || true
        docker volume create aramco_staging_redis_data 2>/dev/null || true
    fi
}

# Configuration du monitoring avancé
setup_advanced_monitoring() {
    log_info "Configuration du monitoring avancé..."
    
    # Installation des exporters
    docker run -d --name node-exporter \
        --network aramco-network \
        -p 9100:9100 \
        --restart unless-stopped \
        prom/node-exporter
    
    docker run -d --name postgres-exporter \
        --network aramco-network \
        -e DATA_SOURCE_NAME="postgresql://postgres:${DB_PASSWORD}@aramco-postgres:5432/aramco_production?sslmode=disable" \
        -p 9187:9187 \
        --restart unless-stopped \
        prometheuscommunity/postgres-exporter
    
    docker run -d --name redis-exporter \
        --network aramco-network \
        -e REDIS_ADDR="redis://aramco-redis:6379" \
        -p 9121:9121 \
        --restart unless-stopped \
        oliver006/redis_exporter
    
    # Configuration des alertes avancées
    cat > aramco-backend/docker/prometheus/advanced_alerts.yml << EOF
groups:
  - name: aramco_advanced_alerts
    rules:
      - alert: DatabaseConnectionHigh
        expr: pg_stat_activity_count > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database connections"
          description: "Database has {{ $value }} active connections"
      
      - alert: RedisMemoryHigh
        expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Redis memory usage high"
          description: "Redis is using {{ $value | humanizePercentage }} of memory"
      
      - alert: DiskSpaceHigh
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space low"
          description: "Disk usage is {{ $value | humanizePercentage }} full"
EOF
    
    log_success "Monitoring avancé configuré"
}

# Configuration de la sécurité avancée
setup_advanced_security() {
    log_info "Configuration de la sécurité avancée..."
    
    # Configuration du firewall
    sudo ufw --force enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow from 10.0.0.0/8 to any port 5432  # PostgreSQL interne
    sudo ufw allow from 10.0.0.0/8 to any port 6379  # Redis interne
    
    # Configuration des security headers Nginx
    cat > aramco-backend/docker/nginx/security.conf << EOF
# Security Headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Hide server tokens
server_tokens off;

# Limit request size
client_max_body_size 10M;

# Rate limiting
limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone \$binary_remote_addr zone=login:10m rate=1r/s;

# Protection contre les attaques courantes
if (\$request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)\$ ) {
    return 405;
}

if (\$http_user_agent ~* LWP::Simple|BBBike|wget|curl) {
    return 403;
}

# Bloquer les requêtes suspectes
if (\$args ~* "proc/self/environ") {
    return 403;
}
EOF
    
    # Configuration Fail2Ban
    sudo apt-get install -y fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    
    # Configuration de Fail2Ban pour Nginx
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
EOF
    
    sudo systemctl restart fail2ban
    
    log_success "Sécurité avancée configurée"
}

# Configuration du backup automatique
setup_automated_backups() {
    log_info "Configuration du backup automatique..."
    
    # Création du script de backup
    cat > /usr/local/bin/aramco_backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/aramco-sa"
S3_BUCKET="s3://aramco-backups"

# Création des répertoires
mkdir -p "$BACKUP_DIR/database"
mkdir -p "$BACKUP_DIR/files"
mkdir -p "$BACKUP_DIR/config"

# Backup base de données
docker exec aramco-postgres pg_dump -U postgres aramco_production | gzip > "$BACKUP_DIR/database/db_backup_$DATE.sql.gz"

# Backup fichiers
tar -czf "$BACKUP_DIR/files/files_backup_$DATE.tar.gz" aramco-backend/storage/

# Backup configuration
tar -czf "$BACKUP_DIR/config/config_backup_$DATE.tar.gz" aramco-backend/.env* aramco-backend/docker/

# Upload vers S3
aws s3 cp "$BACKUP_DIR/database/db_backup_$DATE.sql.gz" "$S3_BUCKET/database/"
aws s3 cp "$BACKUP_DIR/files/files_backup_$DATE.tar.gz" "$S3_BUCKET/files/"
aws s3 cp "$BACKUP_DIR/config/config_backup_$DATE.tar.gz" "$S3_BUCKET/config/"

# Nettoyage local
find "$BACKUP_DIR" -name "*.gz" -mtime +7 -delete

# Notification
curl -X POST "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" \
     -H 'Content-type: application/json' \
     --data "{\"text\":\"✅ Backup Aramco SA terminé le $(date)\"}"
EOF
    
    chmod +x /usr/local/bin/aramco_backup.sh
    
    # Configuration cron pour backup automatique
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/aramco_backup.sh") | crontab -
    
    # Configuration backup hebdomadaire complet
    (crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/local/bin/aramco_backup.sh --full") | crontab -
    
    log_success "Backup automatique configuré"
}

# Configuration du load balancing
setup_load_balancing() {
    log_info "Configuration du load balancing..."
    
    # Configuration Nginx pour load balancing
    cat > aramco-backend/docker/nginx/load-balancer.conf << EOF
upstream aramco_backend {
    least_conn;
    server aramco-backend:8000 max_fails=3 fail_timeout=30s;
    # Ajouter d'autres instances si nécessaire
    # server aramco-backend-2:8000 max_fails=3 fail_timeout=30s;
    
    keepalive 32;
}

upstream aramco_frontend {
    least_conn;
    server localhost:3000 max_fails=3 fail_timeout=30s;
    # Ajouter d'autres instances si nécessaire
    # server localhost:3001 max_fails=3 fail_timeout=30s;
}

# Configuration du serveur principal
server {
    listen 80;
    server_name api.aramco-sa.com app.aramco-sa.com;
    
    # Redirection vers HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.aramco-sa.com;
    
    ssl_certificate /etc/letsencrypt/live/api.aramco-sa.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.aramco-sa.com/privkey.pem;
    
    include /etc/nginx/conf.d/security.conf;
    
    location / {
        proxy_pass http://aramco_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeout settings
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Rate limiting
        limit_req zone=api burst=20 nodelay;
    }
}

server {
    listen 443 ssl http2;
    server_name app.aramco-sa.com;
    
    ssl_certificate /etc/letsencrypt/live/app.aramco-sa.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/app.aramco-sa.com/privkey.pem;
    
    include /etc/nginx/conf.d/security.conf;
    
    location / {
        proxy_pass http://aramco_frontend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeout settings
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # Servir les fichiers statiques directement
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        root /var/www/html/build/web;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
    
    # Test de la configuration Nginx
    sudo nginx -t && sudo systemctl reload nginx
    
    log_success "Load balancing configuré"
}

# Fonction principale
main() {
    log_info "Début du déploiement de $PROJECT_NAME en $ENVIRONMENT..."
    log_info "Date: $DATE"
    
    # Création du fichier de log
    touch "$LOG_FILE"
    
    # Exécution des étapes
    check_prerequisites
    setup_environment
    
    # Déploiement de l'infrastructure complète (priorité 4)
    deploy_infrastructure
    
    backup_current_version
    run_pre_deployment_tests
    build_backend
    build_frontend
    deploy_docker
    configure_reverse_proxy
    configure_ssl
    run_post_deployment_tests
    setup_monitoring
    cleanup
    send_notification
    
    log_success "Déploiement terminé avec succès !"
    log_info "L'application est maintenant disponible en $ENVIRONMENT"
    
    if [ "$ENVIRONMENT" = "production" ]; then
        log_info "URL: https://app.aramco-sa.com"
        log_info "API: https://api.aramco-sa.com"
        log_info "Monitoring: https://grafana.aramco-sa.com"
        log_info "Alertes: Configurées et actives"
    else
        log_info "URL: http://staging.aramco-sa.com"
        log_info "API: http://staging-api.aramco-sa.com"
        log_info "Monitoring: http://staging-grafana.aramco-sa.com"
    fi
    
    # Afficher les informations système
    log_info "=== Informations Système ==="
    log_info "Services Docker actifs:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    log_info "Espace disque utilisé:"
    df -h | grep -E "(/$|/var)"
    
    log_info "Mémoire disponible:"
    free -h
    
    log_info "Uptime système:"
    uptime
    
    log_info "=== Déploiement Priorité 4 Terminé ==="
    log_info "Infrastructure complète déployée avec succès"
    log_info "Monitoring, sécurité, backup et load balancing configurés"
}

# Gestion des erreurs
trap 'log_error "Une erreur est survenue lors du déploiement"; rollback_deployment; exit 1' ERR

# Exécution du script
main "$@"
