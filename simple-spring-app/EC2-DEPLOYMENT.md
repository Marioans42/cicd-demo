# Guide de Déploiement sur AWS EC2

## Prérequis
- Instance EC2 avec Amazon Linux 2 ou Ubuntu
- Ports 22 (SSH) et 8080 (application) ouverts dans le Security Group
- Connexion SSH configurée

## 1. Préparation de l'instance EC2

### Installer Java 21
```bash
# Amazon Linux 2
sudo yum update -y
sudo yum install -y java-21-amazon-corretto

# Ubuntu
sudo apt update
sudo apt install -y openjdk-21-jdk
```

### Vérifier l'installation
```bash
java -version
```

## 2. Déploiement de l'application

### Créer les répertoires
```bash
sudo mkdir -p /home/ec2-user/app
sudo mkdir -p /var/log/spring-app
sudo chown ec2-user:ec2-user /home/ec2-user/app
sudo chown ec2-user:ec2-user /var/log/spring-app
```

### Transférer les fichiers
```bash
# Depuis votre machine locale
scp -i votre-cle.pem target/simple-spring-app-1.0-SNAPSHOT.jar ec2-user@YOUR-EC2-IP:/home/ec2-user/app/
scp -i votre-cle.pem startup.sh ec2-user@YOUR-EC2-IP:/home/ec2-user/app/
```

### Rendre le script exécutable
```bash
chmod +x /home/ec2-user/app/startup.sh
```

## 3. Démarrer l'application

```bash
cd /home/ec2-user/app
./startup.sh start
```

## 4. Vérifier l'application

### Vérifier le statut
```bash
./startup.sh status
```

### Tester les endpoints
```bash
# Page d'accueil
curl http://localhost:8080/

# Health check
curl http://localhost:8080/health

# Informations système
curl http://localhost:8080/info
```

### Accès externe
```bash
curl http://YOUR-EC2-PUBLIC-IP:8080/
```

## 5. Gestion de l'application

### Arrêter l'application
```bash
./startup.sh stop
```

### Redémarrer l'application
```bash
./startup.sh restart
```

### Consulter les logs
```bash
tail -f /var/log/spring-app/application.log
```

## 6. Configuration du démarrage automatique (Optionnel)

### Créer un service systemd
```bash
sudo tee /etc/systemd/system/spring-app.service > /dev/null <<EOF
[Unit]
Description=Simple Spring Boot Application
After=network.target

[Service]
Type=forking
User=ec2-user
ExecStart=/home/ec2-user/app/startup.sh start
ExecStop=/home/ec2-user/app/startup.sh stop
ExecReload=/home/ec2-user/app/startup.sh restart
PIDFile=/var/run/simple-spring-app.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

### Activer le service
```bash
sudo systemctl daemon-reload
sudo systemctl enable spring-app
sudo systemctl start spring-app
sudo systemctl status spring-app
```

## 7. Endpoints disponibles

| Endpoint | Description |
|----------|-------------|
| `/` | Page d'accueil avec informations de l'application |
| `/health` | Health check de l'application |
| `/info` | Informations système et application |
| `/actuator/health` | Health check détaillé (Spring Actuator) |
| `/actuator/info` | Informations actuator |

## 8. Sécurisation (Recommandations)

### Mise à jour du Security Group
- Limiter l'accès au port 8080 aux IP nécessaires uniquement
- Utiliser un Load Balancer pour l'exposition publique

### Configuration SSL (Optionnel)
Pour la production, configurer un reverse proxy nginx avec SSL :

```bash
sudo yum install -y nginx
```

Configuration nginx :
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 9. Monitoring et Logs

### Visualiser les métriques
```bash
curl http://localhost:8080/actuator/metrics
```

### Rotation des logs
Configurer logrotate pour gérer les logs :

```bash
sudo tee /etc/logrotate.d/spring-app > /dev/null <<EOF
/var/log/spring-app/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF
```

## Dépannage

### L'application ne démarre pas
1. Vérifier les logs : `tail -f /var/log/spring-app/application.log`
2. Vérifier Java : `java -version`
3. Vérifier les ports : `netstat -tlnp | grep 8080`

### L'application n'est pas accessible
1. Vérifier le Security Group AWS
2. Vérifier le firewall local : `sudo iptables -L`
3. Tester en local : `curl localhost:8080`

### Performance
- Ajuster la mémoire JVM : `-Xmx512m` dans le script startup.sh
- Monitorer avec : `top`, `htop`, `free -h`