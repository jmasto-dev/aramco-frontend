# Guide Complet de Déploiement en Production - Projet Aramco SA

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Architecture de Production](#architecture-de-production)
3. [Configuration des Environnements](#configuration-des-environnements)
4. [Processus de Déploiement](#processus-de-déploiement)
5. [Monitoring et Alertes](#monitoring-et-alertes)
6. [Sécurité](#sécurité)
7. [Sauvegarde et Restauration](#sauvegarde-et-restauration)
8. [Performance et Optimisation](#performance-et-optimisation)
9. [Dépannage](#dépannage)
10. [Maintenance](#maintenance)

## 🚀 Prérequis

### Infrastructure Requise

#### Serveur Principal (Production)
- **CPU**: Minimum 4 cœurs (8 recommandés)
- **RAM**: Minimum 16GB (32GB recommandés)
- **Stockage**: Minimum 500GB SSD (1TB recommandés)
- **Réseau**: 1Gbps avec backup
- **OS**: Ubuntu 20.04 LTS ou supérieur

#### Base de Données
- **PostgreSQL**: Version 13+ avec replication
- **Redis**: Version 6+ avec clustering
- **Stockage**: Backup automatique quotidien

#### Réseau et Sécurité
- **Domaines**: api.aramco-sa.com, app.aramco-sa.com
- **SSL**: Certificat Let's Encrypt ou wildcard
- **Firewall**: UFW ou équivalent configuré
- **CDN**: CloudFlare (optionnel)

### Logiciels Installés

```bash
# Vérification des versions requises
docker --version          # >= 20.10.0
docker-compose --version # >= 2.0.0
nginx --version           # >= 1.18.0
php --version             # >= 8.1.0
node --version            # >= 18.0.0
flutter --version         # >= 3.0.0
git --version             # >= 2.30.0
```

### Configuration Système

```bash
# Limits système pour la production
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# Optimisation du kernel
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "net.core.somaxconn=65535" >> /etc/sysctl.conf
sysctl -p
```

## 🏗️ Architecture de Production

### Diagramme d'Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │      CDN        │    │   Firewall      │
│    (Nginx)      │    │  (CloudFlare)   │    │   (UFW)         │
└─────────┬───────┘    └─────────────────┘    └─────────┬───────┘
          │                                        │
          └────────────────┬───────────────────────┘
                           │
          ┌────────────────▼────────────────┐
          │        Serveur Principal        │
          │   ┌─────────────────────────┐   │
          │   │      Nginx Reverse     │   │
          │   │        Proxy           │   │
          │   └─────────────┬───────────┘   │
          │                 │               │
          │   ┌─────────────▼───────────┐   │
          │   │   Docker Containers    │   │
          │   │  ┌─────────┬─────────┐  │   │
          │   │  │Backend  │Frontend │  │   │
          │   │  │(Laravel)│(Flutter)│  │   │
          │   │  └─────────┴─────────┘  │   │
          │   │  ┌─────────┬─────────┐  │   │
          │   │  │PostgreSQL│ Redis  │  │   │
          │   │  └─────────┴─────────┘  │   │
          │   │  ┌─────────┬─────────┐  │   │
          │   │  │Prometheus│ Grafana │  │   │
          │   │  └─────────┴─────────┘  │   │
          │   └─────────────────────────┘   │
          └─────────────────────────────────┘
                           │
          ┌────────────────▼────────────────┐
          │        Stockage Backup         │
          │      (NAS / Cloud Storage)     │
          └─────────────────────────────────┘
```

### Services Docker

```yaml
# docker-compose.prod.yml
services:
  # Backend Laravel
  aramco-backend:
    build: ./aramco-backend
    restart: unless-stopped
    environment:
      - APP_ENV=production
    volumes:
      - ./storage:/var/www/html/storage
    networks:
      - aramco-network

  # Frontend Flutter (Web)
  aramco-frontend:
    build: ./build/web
    restart: unless-stopped
    networks:
      - aramco-network

  # Base de données PostgreSQL
  aramco-postgres:
    image: postgres:14
    restart: unless-stopped
    environment:
      POSTGRES_DB: aramco_production
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - aramco-network

  # Cache Redis
  aramco-redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - aramco-network

  # Monitoring Prometheus
  prometheus:
    image: prom/prometheus:latest
    restart: unless-stopped
    volumes:
      - ./docker/prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    networks:
      - aramco-network

  # Dashboard Grafana
  grafana:
    image: grafana/grafana:latest
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./docker/grafana:/etc/grafana/provisioning
    networks:
      - aramco-network
```

## ⚙️ Configuration des Environnements

### Variables d'Environnement Production

Le fichier `.env.production` contient toutes les configurations spécifiques à la production :

```bash
# Configuration principale
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.aramco-sa.com

# Sécurité
APP_KEY=base64:GENERATE_UNIQUE_KEY
JWT_SECRET=GENERATE_UNIQUE_JWT_SECRET

# Base de données
DB_DATABASE=aramco_production
DB_PASSWORD=SECURE_PASSWORD

# Performance
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
```

### Configuration Staging

Le fichier `.env.staging` est utilisé pour l'environnement de pré-production :

```bash
# Configuration principale
APP_ENV=staging
APP_DEBUG=false
APP_URL=http://staging-api.aramco-sa.com

# Débogage activé
TELESCOPE_ENABLED=true
API_DOCS_ENABLED=true

# Test data
SEED_TEST_DATA=true
```

## 🔄 Processus de Déploiement

### 1. Pré-déploiement

```bash
# Cloner le repository
git clone https://github.com/aramco-sa/aramco-frontend.git
cd aramco-frontend

# Vérifier la branche
git checkout main
git pull origin main

# Lancer les tests
dart scripts/run_all_tests.dart
```

### 2. Déploiement Automatisé

```bash
# Exécuter le script de déploiement
chmod +x scripts/deploy_production.sh

# Déploiement en staging
./scripts/deploy_production.sh staging

# Déploiement en production
./scripts/deploy_production.sh production
```

### 3. Étapes du Déploiement

Le script effectue automatiquement :

1. **Vérification des prérequis**
2. **Configuration de l'environnement**
3. **Sauvegarde de l'ancienne version**
4. **Tests pré-déploiement**
5. **Build du backend et frontend**
6. **Déploiement des conteneurs Docker**
7. **Configuration du reverse proxy**
8. **Configuration SSL/TLS**
9. **Tests post-déploiement**
10. **Configuration du monitoring**
11. **Nettoyage**
12. **Notifications**

### 4. Rollback Automatique

En cas d'échec, le script effectue un rollback automatique :

```bash
# Arrêt des nouveaux conteneurs
docker-compose -f aramco-backend/docker-compose.prod.yml down

# Restauration de la dernière sauvegarde
LATEST_BACKUP=$(ls -t /var/backups/aramco-sa/*.tar.gz | head -n1)
tar -xzf "$LATEST_BACKUP" -C /tmp/

# Restauration de la base de données
docker exec -i aramco-postgres psql -U postgres aramco_production < /tmp/database.sql

# Redémarrage des services
docker-compose -f aramco-backend/docker-compose.prod.yml up -d
```

## 📊 Monitoring et Alertes

### Configuration Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'aramco-backend'
    static_configs:
      - targets: ['aramco-backend:8000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

### Règles d'Alerte

```yaml
# alert_rules.yml
groups:
  - name: aramco_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is {{ $value }} seconds"

      - alert: DatabaseDown
        expr: up{job="postgres"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database is down"
          description: "PostgreSQL database has been down for more than 1 minute"

      - alert: RedisDown
        expr: up{job="redis"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Redis is down"
          description: "Redis cache has been down for more than 1 minute"

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}%"
```

### Dashboard Grafana

Un dashboard préconfiguré est disponible avec :

- **Métriques de performance**: CPU, RAM, disque
- **Métriques applicatives**: requêtes, erreurs, temps de réponse
- **Métriques de base de données**: connexions, requêtes lentes
- **Alertes en temps réel**: notifications Slack/Email

## 🔒 Sécurité

### Configuration SSL/TLS

```bash
# Installation de Let's Encrypt
sudo apt-get install certbot python3-certbot-nginx

# Obtention du certificat
sudo certbot --nginx -d api.aramco-sa.com -d app.aramco-sa.com

# Renouvellement automatique
sudo crontab -l
0 12 * * * /usr/bin/certbot renew --quiet
```

### Configuration Firewall

```bash
# Configuration UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Security Headers

```nginx
# Configuration Nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### Configuration JWT

```php
// config/auth.php
'guards' => [
    'api' => [
        'driver' => 'jwt',
        'provider' => 'users',
        'hash' => false,
    ],
],

'jwt' => [
    'secret' => env('JWT_SECRET'),
    'ttl' => env('JWT_TTL', 1440),
    'refresh_ttl' => env('JWT_REFRESH_TTL', 20160),
    'algo' => 'HS256',
],
```

## 💾 Sauvegarde et Restauration

### Configuration Backup Automatique

```bash
# Script de backup
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/aramco-sa"

# Backup base de données
docker exec aramco-postgres pg_dump -U postgres aramco_production > "$BACKUP_DIR/db_backup_$DATE.sql"

# Backup fichiers
tar -czf "$BACKUP_DIR/files_backup_$DATE.tar.gz" aramco-backend/storage

# Upload vers cloud storage (AWS S3, Google Cloud, etc.)
aws s3 cp "$BACKUP_DIR/db_backup_$DATE.sql" s3://aramco-backups/database/
aws s3 cp "$BACKUP_DIR/files_backup_$DATE.tar.gz" s3://aramco-backups/files/

# Nettoyage anciens backups
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
```

### Configuration Cron

```bash
# Crontab
0 2 * * * /path/to/backup.sh
0 3 * * 0 /path/to/weekly_full_backup.sh
```

### Restauration

```bash
# Restauration base de données
docker exec -i aramco-postgres psql -U postgres aramco_production < backup.sql

# Restauration fichiers
tar -xzf files_backup.tar.gz -C aramco-backend/
```

## ⚡ Performance et Optimisation

### Configuration PHP-FPM

```ini
; php-fpm.conf
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
```

### Configuration PostgreSQL

```conf
# postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
```

### Configuration Redis

```conf
# redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

### Configuration Nginx

```nginx
# nginx.conf
worker_processes auto;
worker_connections 1024;

http {
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Cache
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
}
```

## 🔧 Dépannage

### Problèmes Courants

#### 1. Application ne démarre pas

```bash
# Vérifier les logs
docker-compose logs aramco-backend

# Vérifier l'état des conteneurs
docker ps -a

# Redémarrer les services
docker-compose restart
```

#### 2. Base de données inaccessible

```bash
# Vérifier la connexion
docker exec aramco-postgres psql -U postgres -c "\l"

# Vérifier les logs PostgreSQL
docker logs aramco-postgres

# Redémarrer PostgreSQL
docker restart aramco-postgres
```

#### 3. Performance dégradée

```bash
# Vérifier l'utilisation CPU/RAM
docker stats

# Vérifier les requêtes lentes
docker exec aramco-postgres psql -U postgres -c "SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Vider le cache Redis
docker exec aramco-redis redis-cli FLUSHALL
```

#### 4. Erreurs SSL

```bash
# Vérifier le certificat
openssl x509 -in /etc/letsencrypt/live/api.aramco-sa.com/cert.pem -text -noout

# Renouveler manuellement
sudo certbot renew --force-renewal

# Vérifier la configuration Nginx
sudo nginx -t
```

### Logs Utiles

```bash
# Logs backend
docker logs aramco-backend -f

# Logs Nginx
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# Logs PHP-FPM
tail -f /var/log/php8.1-fpm.log

# Logs système
journalctl -u docker -f
```

## 🛠️ Maintenance

### Tâches Quotidiennes

```bash
#!/bin/bash
# daily_maintenance.sh

# Nettoyage logs
find /var/log -name "*.log" -mtime +30 -delete

# Nettoyage Docker
docker system prune -f

# Vérification santé
curl -f http://localhost:8000/api/v1/health || echo "API DOWN"

# Backup
/path/to/backup.sh
```

### Tâches Hebdomadaires

```bash
#!/bin/bash
# weekly_maintenance.sh

# Mise à jour système
sudo apt update && sudo apt upgrade -y

# Mise à jour Docker
docker-compose pull

# Redémarrage services
docker-compose up -d

# Optimisation base de données
docker exec aramco-postgres psql -U postgres -c "VACUUM ANALYZE;"
```

### Tâches Mensuelles

```bash
#!/bin/bash
# monthly_maintenance.sh

# Rotation logs
logrotate -f /etc/logrotate.conf

# Nettoyage backups anciens
find /var/backups -name "*.tar.gz" -mtime +90 -delete

# Rapport performance
/path/to/performance_report.sh
```

## 📈 Monitoring de la Performance

### KPIs à Surveiller

- **Disponibilité**: > 99.9%
- **Temps de réponse**: < 500ms (95th percentile)
- **Taux d'erreur**: < 0.1%
- **Utilisation CPU**: < 80%
- **Utilisation RAM**: < 85%
- **Espace disque**: < 90%

### Alertes

- **Critiques**: Service down, base de données inaccessible
- **Avertissements**: Performance dégradée, ressources élevées
- **Information**: Déploiements, maintenance

## 🚀 Checklist de Déploiement

### Avant le Déploiement
- [ ] Tests complets passés avec succès
- [ ] Backup de l'environnement actuel
- [ ] Vérification des dépendances
- [ ] Configuration de l'environnement validée

### Pendant le Déploiement
- [ ] Monitoring actif
- [ ] Logs surveillés
- [ ] Tests de santé réguliers
- [ ] Communication avec l'équipe

### Après le Déploiement
- [ ] Tests post-déploiement validés
- [ ] Monitoring configuré
- [ ] Documentation mise à jour
- [ ] Équipe informée du succès

---

**Note**: Ce guide doit être adapté selon l'infrastructure spécifique et les exigences de l'organisation. Pour toute question ou problème, contacter l'équipe DevOps.
