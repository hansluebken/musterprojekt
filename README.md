# Musterprojekt

Eine einfache Web-App als Referenz-Template fuer den Workflow: **Claude Code (lokal) + GitHub + Coolify (auto-deploy)**.

## Voraussetzungen

Auf jedem Entwicklungsrechner muessen folgende Tools installiert sein:

| Tool | Zweck | Installation (macOS) |
|------|-------|---------------------|
| Git | Versionsverwaltung | `brew install git` |
| Docker Desktop | Container lokal ausfuehren | [docker.com/download](https://www.docker.com/products/docker-desktop/) |
| Node.js 20+ | (Optional) Entwicklung ohne Docker | `brew install node` |
| Claude Code | KI-Unterstuetzung | `npm install -g @anthropic-ai/claude-code` |
| GitHub CLI | Repos verwalten | `brew install gh` |

## Projekt auf einem neuen Rechner einrichten

### 1. GitHub SSH-Key einrichten (einmalig pro Rechner)

Falls noch kein SSH-Key fuer GitHub existiert:

```bash
# Key erstellen
ssh-keygen -t ed25519 -C "deine@email.de"

# Key zum SSH-Agent hinzufuegen
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Public Key anzeigen und auf GitHub hinterlegen
cat ~/.ssh/id_ed25519.pub
# -> Kopieren und unter https://github.com/settings/keys hinzufuegen
```

Testen:
```bash
ssh -T git@github.com
# Erwartete Ausgabe: "Hi hansluebken! You've successfully authenticated..."
```

### 2. Repository klonen

```bash
cd ~/Projekte   # oder dein bevorzugtes Verzeichnis
git clone git@github.com:hansluebken/musterprojekt.git
cd musterprojekt
```

### 3. Umgebungsvariablen einrichten

```bash
cp .env.example .env
```

Die `.env`-Datei nach Bedarf anpassen. Verfuegbare Variablen:

| Variable | Standard | Beschreibung |
|----------|----------|-------------|
| `NODE_ENV` | `development` | Umgebung (development/production) |
| `PORT` | `3333` | Port der App |

**Wichtig:** Die `.env`-Datei ist in `.gitignore` und wird NICHT committed. Auf jedem Rechner muss sie separat angelegt werden.

### 4. App lokal starten

```bash
docker compose up --build
```

Die App laeuft dann unter: **http://localhost:3333**

Health-Check: http://localhost:3333/health

### 5. Claude Code starten (optional)

```bash
cd ~/Projekte/musterprojekt
claude
```

## Entwicklungsworkflow (Zwei-Rechner-Setup)

Wenn du auf mehreren Rechnern arbeitest (z.B. Buero + Zuhause), ist folgender Ablauf wichtig:

### Vor dem Arbeiten: Stand synchronisieren

```bash
cd ~/Projekte/musterprojekt
git pull
```

### Arbeiten

```bash
# App starten
docker compose up --build

# Aenderungen vornehmen (direkt oder mit Claude Code)
claude

# Lokal testen im Browser
# http://localhost:3333
```

Dank Volume-Mount (`./src:/app/src`) werden Aenderungen am Quellcode sofort im Container sichtbar (Hot-Reload ueber `node --watch`).

### Nach dem Arbeiten: Aenderungen sichern

```bash
git add .
git commit -m "Beschreibung der Aenderung"
git push
```

Nach dem Push deployt **Coolify automatisch** die neue Version auf den Server.

### Auf dem anderen Rechner weitermachen

```bash
cd ~/Projekte/musterprojekt
git pull                      # Neuesten Stand holen
docker compose up --build     # Lokal starten
```

## Architektur

```
┌──────────────────────────┐         ┌──────────────────────────────┐
│  Entwicklungsrechner     │         │  4hl.dev (Server)            │
│  (Buero oder Zuhause)    │         │                              │
│                          │         │  Coolify                     │
│  Claude Code             │         │  ├── Dashboard (:8888)       │
│  ├── Code schreiben      │  git    │  ├── Traefik (Reverse Proxy) │
│  ├── Lokal testen        │  push   │  ├── Auto-Deploy bei Push    │
│  └── Commit & Push       │───────► │  └── SSL (Let's Encrypt)     │
│                          │         │                              │
│  Docker (lokal)          │  SSH    │  Docker-Container            │
│  └── docker compose up   │───────► │  └── musterprojekt.4hl.dev   │
│                          │         │                              │
│  GitHub                  │         │  Projekte: /home/kuenstler/  │
│  └── hansluebken/...     │         │  Coolify:  /data/coolify/    │
└──────────────────────────┘         └──────────────────────────────┘
```

## Server-Zugang

| Was | Wert |
|-----|------|
| SSH | `ssh -p 4321 kuenstler@4hl.dev` |
| SSH-Key | `~/.ssh/hansprobook` |
| Coolify Dashboard | https://coolify.4hl.dev |
| App-URL | https://musterprojekt.4hl.dev |
| Server-User | `kuenstler` (in docker-Gruppe, kein root noetig) |

## Projektstruktur

```
├── CLAUDE.md               # Projektkontext fuer Claude Code
├── PRD.md                  # Product Requirements Document
├── README.md               # Diese Datei
├── Dockerfile              # Multi-Stage Container-Build
├── docker-compose.yml      # Lokale Entwicklung
├── docker-compose.prod.yml # Referenz fuer Produktion
├── .env.example            # Umgebungsvariablen-Vorlage
├── .gitignore
├── package.json
├── src/
│   └── index.js            # App-Einstiegspunkt (Express)
├── rules/                  # Regeln fuer Claude Code & Entwicklung
│   ├── coding_standards.md # Linting, Naming, API-Design, Git-Workflow
│   └── projekt_regeln.md   # Deployment, Docker, Dokumentationspflichten
├── skills/                 # Entwicklungs-Patterns & Vorlagen
│   ├── development.md      # Express, Docker, DB, Test-Patterns
│   └── ninox.md             # Ninox API, Scripting, Schema-Extraktion
├── scripts/
│   ├── new-project.sh      # Neues Projekt aus Template erstellen
│   ├── deploy-check.sh     # Prueft ob Server erreichbar
│   └── logs.sh             # Holt Container-Logs vom Server
└── docs/
    └── server-setup.md     # Ausfuehrliche Server-Dokumentation
```

## Contextmanagement fuer Claude Code

Dieses Projekt nutzt ein strukturiertes Contextmanagement, damit Claude Code bei jedem Projekt die gleichen Grundlagen kennt:

```
CLAUDE.md          → WAS ist das Projekt? (Stack, Struktur, Befehle)
PRD.md             → WAS soll es koennen? (Features, Regeln, Datenmodell)
rules/             → WIE wird entwickelt? (Standards, Konventionen, Regeln)
skills/            → WELCHE Patterns? (Code-Vorlagen, Best Practices)
docs/              → WARUM so? (Architektur, Server-Setup, Entscheidungen)
```

### So funktioniert es

1. **`CLAUDE.md`** wird automatisch beim Start von Claude Code gelesen
2. **`rules/`** definiert verbindliche Standards (Naming, Linting, Git-Workflow, API-Design)
3. **`skills/`** liefert konkrete Code-Patterns und Vorlagen
4. **`docs/`** enthaelt ausfuehrliche Hintergrund-Dokumentation

### Neues Projekt aus dem Template erstellen

Beim Erstellen eines neuen Projekts (via `./scripts/new-project.sh`) werden `rules/` und `skills/` automatisch mitkopiert. Dann projektspezifisch anpassen:

- `CLAUDE.md` → Stack, Struktur, URLs anpassen
- `rules/coding_standards.md` → Ggf. Framework-spezifische Regeln ergaenzen
- `skills/development.md` → Projektspezifische Patterns hinzufuegen (z.B. `skills/backend.md`, `skills/frontend.md`)

### Inspiriert von

Dieses Contextmanagement-Konzept ist abgeleitet vom [PRD-RMNC0001](https://github.com/hansluebken/PRD-RMNC0001) Projekt, das fuer ein grosses ERP-System folgende Struktur nutzt:

| Verzeichnis | Inhalt im RMNC-Projekt |
|-------------|----------------------|
| `CLAUDE.md` | Stack, Struktur, Cross-DB-Abhaengigkeiten |
| `rules/` | Coding Standards (Ruff, ESLint, DB-Konventionen, Git-Workflow) |
| `skills/` | Backend (FastAPI), Frontend (React/TS), Migration (Ninox) |
| `features/` | 14 Feature-Spezifikationen mit Datenmodellen und APIs |

## Nützliche Befehle

```bash
# Lokal starten
docker compose up --build

# Lokal stoppen
docker compose down

# Server-Status pruefen
ssh -p 4321 kuenstler@4hl.dev "docker ps | grep musterprojekt"

# Server-Logs ansehen
ssh -p 4321 kuenstler@4hl.dev "docker logs musterprojekt-app 2>&1 | tail -50"

# Neues Projekt aus diesem Template erstellen
./scripts/new-project.sh
```

## Secrets und Umgebungsvariablen

| Umgebung | Wo konfigurieren? |
|----------|-------------------|
| Lokal | `.env`-Datei (nicht im Git) |
| Produktion | Coolify Dashboard → Environment Variables |

**Niemals** Secrets in den Code oder ins Git schreiben.

## Weiterführende Dokumentation

- [Server-Setup & Workflow](docs/server-setup.md) - Ausfuehrliche Dokumentation zu Coolify, DNS, Ports und Troubleshooting
