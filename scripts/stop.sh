#!/bin/bash
echo "[stop] Arrêt de l'application"
if [ -f /opt/app/app.pid ]; then
  PID=$(cat /opt/app/app.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID
    sleep 3
    # Force kill si toujours là
    if ps -p $PID > /dev/null 2>&1; then
      kill -9 $PID
    fi
  fi
  rm -f /opt/app/app.pid
fi
exit 0