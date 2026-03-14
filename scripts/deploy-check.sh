#!/bin/bash
# Prüft ob der Server erreichbar ist und die App laeuft

SERVER="4hl.dev"
SSH_USER="user"  # anpassen

echo "=== Server-Erreichbarkeit ==="
ssh -o ConnectTimeout=5 ${SSH_USER}@${SERVER} "echo 'SSH: OK'" 2>/dev/null || echo "SSH: FEHLER"

echo ""
echo "=== Docker-Container ==="
ssh ${SSH_USER}@${SERVER} "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null

echo ""
echo "=== Health-Check ==="
curl -s --max-time 5 https://musterprojekt.${SERVER}/health || echo "App nicht erreichbar"
