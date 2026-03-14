#!/bin/bash
# Holt die letzten Logs vom Server

SERVER="4hl.dev"
SSH_USER="user"  # anpassen
CONTAINER="musterprojekt-app"  # anpassen (Coolify-Container-Name prüfen)
LINES="${1:-50}"

echo "=== Letzte ${LINES} Log-Zeilen von ${CONTAINER} ==="
ssh ${SSH_USER}@${SERVER} "docker logs ${CONTAINER} 2>&1 | tail -${LINES}"
