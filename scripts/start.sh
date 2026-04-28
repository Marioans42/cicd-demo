#!/bin/bash
set -e
echo "[start] Démarrage de l'application"
cd /opt/app
nohup java -jar app.jar > /opt/app/app.log 2>&1 &
echo $! > /opt/app/app.pid
sleep 5
echo "[start] Application lancée — PID $(cat /opt/app/app.pid)"