#!/bin/bash
# Holt die letzten Logs vom Server

SERVER="4hl.dev"
SSH_USER="kuenstler"
SSH_PORT="4321"
SSH_KEY="~/.ssh/hansprobook"
CONTAINER="musterprojekt-app"  # anpassen (Coolify-Container-Name prüfen)
LINES="${1:-50}"

echo "=== Letzte ${LINES} Log-Zeilen von ${CONTAINER} ==="
ssh -p ${SSH_PORT} -i ${SSH_KEY} ${SSH_USER}@${SERVER} "docker logs ${CONTAINER} 2>&1 | tail -${LINES}"
