#!/bin/bash
# Prüft ob der Server erreichbar ist und die App laeuft

SERVER="4hl.dev"
SSH_USER="kuenstler"
SSH_PORT="4321"
SSH_KEY="~/.ssh/hansprobook"

echo "=== Server-Erreichbarkeit ==="
ssh -o ConnectTimeout=5 -p ${SSH_PORT} -i ${SSH_KEY} ${SSH_USER}@${SERVER} "echo 'SSH: OK'" 2>/dev/null || echo "SSH: FEHLER"

echo ""
echo "=== Docker-Container ==="
ssh -p ${SSH_PORT} -i ${SSH_KEY} ${SSH_USER}@${SERVER} "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null

echo ""
echo "=== Health-Check ==="
curl -s --max-time 5 https://musterprojekt.${SERVER}/health || echo "App nicht erreichbar"
