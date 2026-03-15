# Projekt: Musterprojekt

## Überblick
Eine einfache Web-App als Referenz für das Setup: Claude Code (lokal) + Coolify (4hl.dev).

## Server & Deployment
- **Server:** 4hl.dev
- **SSH:** `ssh -p 4321 kuenstler@4hl.dev` (Key: ~/.ssh/hansprobook)
- **Deployment:** Coolify (Git-Push auf `main` → auto-deploy)
- **Coolify-Dashboard:** https://coolify.4hl.dev (ggf. anpassen)
- **App-URL:** https://musterprojekt.4hl.dev (ggf. anpassen)

## Tech-Stack
- Backend: Node.js mit Express
- Docker + Docker Compose
- Reverse Proxy: Coolify/Traefik (auf dem Server)

## Projektstruktur
```
├── CLAUDE.md               # Diese Datei – Kontext für Claude Code
├── PRD.md                  # Product Requirements – WAS soll die Software können?
├── README.md               # Einrichtung & Workflow für Entwickler
├── Dockerfile              # Multi-Stage Container-Build
├── docker-compose.yml      # Lokale Entwicklung
├── docker-compose.prod.yml # Referenz für Produktion (Coolify nutzt eigene Config)
├── .env.example            # Umgebungsvariablen-Vorlage
├── .gitignore
├── package.json
├── src/
│   └── index.js            # App-Einstiegspunkt
├── rules/                  # Regeln für Claude Code
│   ├── coding_standards.md # Linting, Naming, API-Design, Git-Workflow
│   └── projekt_regeln.md   # Deployment, Docker, Dokumentationspflichten
├── skills/                 # Entwicklungs-Patterns für Claude Code
│   ├── development.md      # Express, Docker, DB, Test-Patterns
│   └── ninox.md             # Ninox API, Scripting, Schema-Extraktion
├── scripts/
│   ├── new-project.sh      # ⭐ Neues Projekt aus Template erstellen
│   ├── deploy-check.sh     # Prüft ob Server erreichbar
│   └── logs.sh             # Holt Container-Logs vom Server
└── docs/
    └── server-setup.md     # Workflow-Dokumentation
```

## Contextmanagement

**Wichtig:** Lies bei der ersten Aufgabe `PRD.md` sowie die Dateien in `rules/` und `skills/`, um Anforderungen, Standards und Code-Patterns zu kennen.

| Verzeichnis | Zweck |
|-------------|-------|
| `PRD.md` | Anforderungen, Features, Datenmodell, Geschaeftsregeln |
| `rules/coding_standards.md` | Naming, Linting, API-Design, Git-Workflow |
| `rules/projekt_regeln.md` | Deployment, Docker, Dokumentationspflichten |
| `skills/development.md` | Express, Docker, DB, Test-Patterns |
| `skills/ninox.md` | Ninox API & Scripting Referenz |
| `docs/server-setup.md` | Server, Coolify, DNS, Ports, Troubleshooting |

## Neues Projekt erstellen
```bash
./scripts/new-project.sh
# Fragt interaktiv nach: Name, Port, Domain
# Erstellt automatisch: Repo, GitHub, Coolify-Deployment
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
ssh -p 4321 kuenstler@4hl.dev "docker logs musterprojekt-app 2>&1 | tail -50"

# Server-Status
ssh -p 4321 kuenstler@4hl.dev "docker ps | grep musterprojekt"
```

## Konventionen
- Commit-Messages auf Deutsch, kurz und prägnant
- Branches: `feature/xxx`, `fix/xxx`
- Kein Force-Push auf `main`
