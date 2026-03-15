#!/bin/bash
set -euo pipefail

#############################################################
# new-project.sh – Neues Projekt aus Musterprojekt erstellen
#
# Automatisiert:
#  1. Kopiert Musterprojekt als Template
#  2. Ersetzt alle Platzhalter (Name, Port, Domain)
#  3. Erstellt GitHub-Repo
#  4. Erstellt Coolify-Projekt + App via API
#  5. Erster Commit & Push → Auto-Deployment
#
# Voraussetzung: COOLIFY_API_TOKEN als Env-Var oder in ~/.coolify-token
#############################################################

# --- Konfiguration ---
SERVER="4hl.dev"
SSH_USER="kuenstler"
SSH_PORT="4321"
SSH_KEY="~/.ssh/hansprobook"
COOLIFY_URL="https://4hl.dev:8888"
GITHUB_USER="hansluebken"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# --- Farben ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}ℹ${NC}  $1"; }
ok()    { echo -e "${GREEN}✓${NC}  $1"; }
warn()  { echo -e "${YELLOW}⚠${NC}  $1"; }
error() { echo -e "${RED}✗${NC}  $1"; exit 1; }

# --- Coolify API Token laden ---
load_coolify_token() {
  if [ -n "${COOLIFY_API_TOKEN:-}" ]; then
    return 0
  elif [ -f ~/.coolify-token ]; then
    COOLIFY_API_TOKEN=$(cat ~/.coolify-token | tr -d '[:space:]')
    export COOLIFY_API_TOKEN
  else
    warn "Kein Coolify API Token gefunden."
    warn "Erstelle einen unter: ${COOLIFY_URL} → Settings → API Tokens"
    warn "Dann: echo 'dein-token' > ~/.coolify-token && chmod 600 ~/.coolify-token"
    echo ""
    read -p "Token jetzt eingeben (oder Enter zum Überspringen): " token
    if [ -n "$token" ]; then
      echo "$token" > ~/.coolify-token
      chmod 600 ~/.coolify-token
      COOLIFY_API_TOKEN="$token"
      export COOLIFY_API_TOKEN
      ok "Token gespeichert in ~/.coolify-token"
    else
      COOLIFY_API_TOKEN=""
    fi
  fi
}

# --- Coolify API Call ---
coolify_api() {
  local method="$1"
  local endpoint="$2"
  local data="${3:-}"

  if [ -z "${COOLIFY_API_TOKEN:-}" ]; then
    return 1
  fi

  local args=(
    -s -k
    -X "$method"
    -H "Authorization: Bearer ${COOLIFY_API_TOKEN}"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
  )

  if [ -n "$data" ]; then
    args+=(-d "$data")
  fi

  curl "${args[@]}" "${COOLIFY_URL}/api/v1${endpoint}"
}

# --- Interaktive Eingabe ---
echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  Neues Projekt aus Musterprojekt erstellen${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# Projektname
read -p "Projektname (z.B. mein-tool): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
  error "Projektname darf nicht leer sein"
fi
# Bereinigen: Kleinbuchstaben, Bindestriche
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

# Zielverzeichnis
DEFAULT_DIR="$(dirname "$TEMPLATE_DIR")/${PROJECT_NAME}"
read -p "Zielverzeichnis [${DEFAULT_DIR}]: " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-$DEFAULT_DIR}"

# Port
DEFAULT_PORT=$((3333 + RANDOM % 1000))
read -p "App-Port [${DEFAULT_PORT}]: " APP_PORT
APP_PORT="${APP_PORT:-$DEFAULT_PORT}"

# Domain
DEFAULT_DOMAIN="${PROJECT_NAME}.${SERVER}"
read -p "Domain [${DEFAULT_DOMAIN}]: " APP_DOMAIN
APP_DOMAIN="${APP_DOMAIN:-$DEFAULT_DOMAIN}"

# Beschreibung
read -p "Kurzbeschreibung: " PROJECT_DESC
PROJECT_DESC="${PROJECT_DESC:-${PROJECT_NAME} – deployed via Coolify}"

echo ""
echo -e "${YELLOW}── Zusammenfassung ──${NC}"
echo "  Projekt:    ${PROJECT_NAME}"
echo "  Verzeichnis: ${TARGET_DIR}"
echo "  Port:       ${APP_PORT}"
echo "  Domain:     ${APP_DOMAIN}"
echo "  GitHub:     ${GITHUB_USER}/${PROJECT_NAME}"
echo ""
read -p "Fortfahren? [Y/n] " confirm
if [[ "${confirm:-Y}" =~ ^[Nn] ]]; then
  echo "Abgebrochen."
  exit 0
fi

echo ""

# ============================================================
# SCHRITT 1: Projekt kopieren
# ============================================================
info "Erstelle Projekt aus Template..."

if [ -d "$TARGET_DIR" ]; then
  error "Verzeichnis ${TARGET_DIR} existiert bereits!"
fi

mkdir -p "$TARGET_DIR"

# Dateien kopieren (ohne .git und node_modules)
rsync -a \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='.env' \
  "${TEMPLATE_DIR}/" "${TARGET_DIR}/"

ok "Template kopiert nach ${TARGET_DIR}"

# ============================================================
# SCHRITT 2: Platzhalter ersetzen
# ============================================================
info "Ersetze Platzhalter..."

cd "$TARGET_DIR"

# package.json
sed -i '' "s/\"name\": \"musterprojekt\"/\"name\": \"${PROJECT_NAME}\"/" package.json
sed -i '' "s/Musterprojekt fuer Claude Code + Coolify Workflow/${PROJECT_DESC}/" package.json

# src/index.js
sed -i '' "s/name: 'Musterprojekt'/name: '${PROJECT_NAME}'/" src/index.js
sed -i '' "s/|| 3333/|| ${APP_PORT}/" src/index.js

# Dockerfile
sed -i '' "s/EXPOSE 3333/EXPOSE ${APP_PORT}/" Dockerfile
sed -i '' "s/localhost:3333/localhost:${APP_PORT}/" Dockerfile

# docker-compose.yml
sed -i '' "s/\"3333:3333\"/\"${APP_PORT}:${APP_PORT}\"/" docker-compose.yml

# docker-compose.prod.yml
sed -i '' "s/\"3333:3333\"/\"${APP_PORT}:${APP_PORT}\"/" docker-compose.prod.yml
sed -i '' "s/musterprojekt\.4hl\.dev/${APP_DOMAIN}/" docker-compose.prod.yml
sed -i '' "s/musterprojekt/${PROJECT_NAME}/g" docker-compose.prod.yml

# .env.example
sed -i '' "s/PORT=3333/PORT=${APP_PORT}/" .env.example

# CLAUDE.md
sed -i '' "s/# Projekt: Musterprojekt/# Projekt: ${PROJECT_NAME}/" CLAUDE.md
sed -i '' "s/Eine einfache Web-App als Referenz.*/${PROJECT_DESC}/" CLAUDE.md
sed -i '' "s|https://musterprojekt\.4hl\.dev|https://${APP_DOMAIN}|g" CLAUDE.md
sed -i '' "s|https://coolify\.4hl\.dev|${COOLIFY_URL}|g" CLAUDE.md
sed -i '' "s/musterprojekt-app/${PROJECT_NAME}-app/g" CLAUDE.md
sed -i '' "s/grep musterprojekt/grep ${PROJECT_NAME}/g" CLAUDE.md

# README.md
sed -i '' "s/# Musterprojekt/# ${PROJECT_NAME}/" README.md
sed -i '' "s/musterprojekt\.4hl\.dev/${APP_DOMAIN}/g" README.md
sed -i '' "s|github.com/hansluebken/musterprojekt|github.com/${GITHUB_USER}/${PROJECT_NAME}|g" README.md
sed -i '' "s/musterprojekt-app/${PROJECT_NAME}-app/g" README.md
sed -i '' "s/grep musterprojekt/grep ${PROJECT_NAME}/g" README.md
sed -i '' "s/localhost:3333/localhost:${APP_PORT}/g" README.md
sed -i '' "s/PORT=3333/PORT=${APP_PORT}/" README.md
sed -i '' "s|\"3333\"|\"${APP_PORT}\"|g" README.md

# Scripts
sed -i '' "s/CONTAINER=\"musterprojekt-app\"/CONTAINER=\"${PROJECT_NAME}-app\"/" scripts/logs.sh
sed -i '' "s|musterprojekt\.\${SERVER}|${APP_DOMAIN}|" scripts/deploy-check.sh

# .env erstellen
cp .env.example .env
sed -i '' "s/development/development/" .env

# new-project.sh aus dem neuen Projekt entfernen (wird nicht gebraucht)
rm -f scripts/new-project.sh

ok "Alle Platzhalter ersetzt"

# ============================================================
# SCHRITT 3: Git + GitHub
# ============================================================
info "Initialisiere Git-Repository..."

git init -q
git add -A
git commit -q -m "Initialer Commit – ${PROJECT_NAME}

Erstellt aus musterprojekt-Template.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

ok "Git initialisiert und erster Commit erstellt"

info "Erstelle GitHub-Repository..."

gh repo create "${GITHUB_USER}/${PROJECT_NAME}" \
  --public \
  --description "${PROJECT_DESC}" \
  --source . \
  --push \
  --remote origin \
  2>/dev/null && ok "GitHub-Repo erstellt: https://github.com/${GITHUB_USER}/${PROJECT_NAME}" \
  || warn "GitHub-Repo konnte nicht erstellt werden (existiert evtl. schon)"

# ============================================================
# SCHRITT 4: Coolify-Deployment
# ============================================================
echo ""
load_coolify_token

if [ -n "${COOLIFY_API_TOKEN:-}" ]; then
  info "Richte Coolify-Deployment ein..."

  # Server-UUID holen
  SERVER_UUID=$(coolify_api GET "/servers" | python3 -c "
import sys, json
servers = json.load(sys.stdin)
for s in servers:
    if s.get('ip') in ['localhost', '127.0.0.1', '$(dig +short 4hl.dev 2>/dev/null || echo 4hl.dev)']:
        print(s['uuid'])
        break
else:
    if servers:
        print(servers[0]['uuid'])
" 2>/dev/null || echo "")

  if [ -z "$SERVER_UUID" ]; then
    warn "Konnte Server-UUID nicht ermitteln"
  else
    ok "Server gefunden: ${SERVER_UUID}"

    # Projekt erstellen
    PROJECT_RESPONSE=$(coolify_api POST "/projects" "{\"name\": \"${PROJECT_NAME}\", \"description\": \"${PROJECT_DESC}\"}" 2>/dev/null || echo "")
    PROJECT_UUID=$(echo "$PROJECT_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('uuid',''))" 2>/dev/null || echo "")

    if [ -n "$PROJECT_UUID" ]; then
      ok "Coolify-Projekt erstellt: ${PROJECT_UUID}"

      # App erstellen (Public Repo)
      APP_RESPONSE=$(coolify_api POST "/applications/public" "{
        \"project_uuid\": \"${PROJECT_UUID}\",
        \"server_uuid\": \"${SERVER_UUID}\",
        \"environment_name\": \"production\",
        \"git_repository\": \"https://github.com/${GITHUB_USER}/${PROJECT_NAME}\",
        \"git_branch\": \"main\",
        \"build_pack\": \"dockerfile\",
        \"ports_exposes\": \"${APP_PORT}\",
        \"name\": \"${PROJECT_NAME}\",
        \"domains\": \"https://${APP_DOMAIN}\"
      }" 2>/dev/null || echo "")

      APP_UUID=$(echo "$APP_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('uuid',''))" 2>/dev/null || echo "")

      if [ -n "$APP_UUID" ]; then
        ok "Coolify-App erstellt: ${APP_UUID}"

        # Deployment starten
        coolify_api GET "/deploy?uuid=${APP_UUID}" >/dev/null 2>&1 \
          && ok "Deployment gestartet!" \
          || warn "Deployment konnte nicht gestartet werden"
      else
        warn "App konnte nicht erstellt werden. Antwort: ${APP_RESPONSE}"
      fi
    else
      warn "Projekt konnte nicht erstellt werden. Antwort: ${PROJECT_RESPONSE}"
    fi
  fi
else
  echo ""
  warn "Coolify-Deployment übersprungen (kein API Token)."
  echo "  Manuell einrichten:"
  echo "  1. Öffne ${COOLIFY_URL}"
  echo "  2. Neues Projekt → '${PROJECT_NAME}'"
  echo "  3. Resource → Public Repo → https://github.com/${GITHUB_USER}/${PROJECT_NAME}"
  echo "  4. Build Pack: Dockerfile"
  echo "  5. Domain: https://${APP_DOMAIN}"
  echo "  6. Port: ${APP_PORT}"
fi

# ============================================================
# FERTIG
# ============================================================
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Projekt '${PROJECT_NAME}' erstellt!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo "  📁 Verzeichnis:  ${TARGET_DIR}"
echo "  🌐 GitHub:       https://github.com/${GITHUB_USER}/${PROJECT_NAME}"
echo "  🚀 App-URL:      https://${APP_DOMAIN}"
echo "  🔧 Port:         ${APP_PORT}"
echo ""
echo "  Nächste Schritte:"
echo "    cd ${TARGET_DIR}"
echo "    claude         # Claude Code öffnen und loslegen"
echo ""
