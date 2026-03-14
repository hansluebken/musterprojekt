# Projekt: Musterprojekt

## Überblick
Eine einfache Web-App als Referenz für das Setup: Claude Code (lokal) + Coolify (4hl.dev).

## Server & Deployment
- **Server:** 4hl.dev
- **SSH:** `ssh user@4hl.dev`
- **Deployment:** Coolify (Git-Push auf `main` → auto-deploy)
- **Coolify-Dashboard:** https://coolify.4hl.dev (ggf. anpassen)
- **App-URL:** https://musterprojekt.4hl.dev (ggf. anpassen)

## Tech-Stack
- Backend: Node.js mit Express
- Docker + Docker Compose
- Reverse Proxy: Coolify/Traefik (auf dem Server)

## Projektstruktur
```
├── CLAUDE.md            # Diese Datei – Kontext für Claude Code
├── Dockerfile           # Container-Build
├── docker-compose.yml   # Lokale Entwicklung
├── docker-compose.prod.yml  # Referenz für Produktion (Coolify nutzt eigene Config)
├── .env.example         # Umgebungsvariablen-Vorlage
├── .gitignore
├── package.json
├── src/
│   └── index.js         # App-Einstiegspunkt
└── scripts/
    ├── deploy-check.sh  # Prüft ob Server erreichbar
    └── logs.sh          # Holt Container-Logs vom Server
```

## Entwicklungsworkflow
1. Lokal entwickeln und testen: `docker compose up`
2. Änderungen committen und pushen
3. Coolify deployt automatisch

## Secrets / Umgebungsvariablen
- NIEMALS Secrets in den Code schreiben
- Lokal: `.env` Datei (ist in .gitignore)
- Produktion: In Coolify unter "Environment Variables" konfigurieren

## Nützliche Befehle
```bash
# Lokal starten
docker compose up --build

# Server-Logs prüfen
ssh user@4hl.dev "docker logs musterprojekt-app 2>&1 | tail -50"

# Server-Status
ssh user@4hl.dev "docker ps | grep musterprojekt"
```

## Konventionen
- Commit-Messages auf Deutsch, kurz und prägnant
- Branches: `feature/xxx`, `fix/xxx`
- Kein Force-Push auf `main`
