#!/bin/bash

# Script de démarrage pour l'application Spring Boot sur EC2

APP_NAME="simple-spring-app"
APP_JAR="simple-spring-app-1.0-SNAPSHOT.jar"
APP_DIR="/home/ec2-user/app"
LOG_DIR="/var/log/spring-app"
PID_FILE="/var/run/${APP_NAME}.pid"

# Créer les répertoires si nécessaire
sudo mkdir -p $LOG_DIR
sudo chown ec2-user:ec2-user $LOG_DIR

# Fonction pour démarrer l'application
start() {
    echo "Démarrage de $APP_NAME..."

    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null 2>&1; then
            echo "$APP_NAME est déjà en cours d'exécution (PID: $PID)"
            exit 1
        fi
    fi

    cd $APP_DIR
    nohup java -jar $APP_JAR > $LOG_DIR/application.log 2>&1 &
    echo $! > $PID_FILE
    echo "$APP_NAME démarré avec le PID: $!"
}

# Fonction pour arrêter l'application
stop() {
    echo "Arrêt de $APP_NAME..."

    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
            echo "$APP_NAME arrêté"
            rm -f $PID_FILE
        else
            echo "$APP_NAME n'est pas en cours d'exécution"
            rm -f $PID_FILE
        fi
    else
        echo "$APP_NAME n'est pas en cours d'exécution"
    fi
}

# Fonction pour redémarrer l'application
restart() {
    stop
    sleep 5
    start
}

# Fonction pour vérifier le statut
status() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null 2>&1; then
            echo "$APP_NAME est en cours d'exécution (PID: $PID)"
        else
            echo "$APP_NAME n'est pas en cours d'exécution"
        fi
    else
        echo "$APP_NAME n'est pas en cours d'exécution"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
esac