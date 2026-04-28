#!/bin/bash
set -e
echo "[before_install] Préparation du dossier /opt/app"
mkdir -p /opt/app
chown -R ec2-user:ec2-user /opt/app
# Installer Java si pas déjà présent (Amazon Linux 2023)
if ! command -v java &> /dev/null; then
  yum install -y java-21-amazon-corretto-headless
fi