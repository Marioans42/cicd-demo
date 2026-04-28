#!/bin/bash
set -e
echo "[validate] Validation du service"
for i in {1..12}; do
  if curl -fs http://localhost:8080/actuator/health | grep -q '"status":"UP"'; then
    echo "[validate] Service UP"
    exit 0
  fi
  echo "[validate] Tentative $i/12 — service pas encore prêt..."
  sleep 5
done
echo "[validate] Service KO après 60s"
exit 1