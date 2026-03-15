# Projektregeln

> Organisatorische Regeln fuer alle Projekte im 4hl.dev-Setup.

## Deployment

- **Ziel-Server:** 4hl.dev (Coolify + Traefik)
- **Workflow:** Git-Push auf `main` → Coolify deployt automatisch
- Kein manuelles Deployment auf dem Server
- Jedes Projekt bekommt eine eigene Subdomain: `projektname.4hl.dev`

## Docker

- Jedes Projekt hat ein eigenes `Dockerfile`
- Multi-Stage Builds verwenden (Build + Run)
- Container laufen **nicht als root** (eigenen User anlegen)
- Health-Checks definieren
- `.dockerignore` pflegen

## Umgebungsvariablen

| Umgebung | Quelle |
|----------|--------|
| Lokal | `.env`-Datei (in `.gitignore`) |
| Produktion | Coolify Dashboard → Environment Variables |

- `.env.example` im Repo pflegen (ohne echte Werte)
- Neue Variablen immer in `.env.example` dokumentieren

## Dokumentation

Jedes Projekt muss enthalten:

| Datei | Zweck |
|-------|-------|
| `CLAUDE.md` | Projektkontext fuer Claude Code (Stack, Struktur, Befehle) |
| `README.md` | Einrichtung, Workflow, Architektur fuer Entwickler |
| `.env.example` | Dokumentation aller Umgebungsvariablen |

## Projektstruktur (Minimum)

```
├── CLAUDE.md               # Claude Code Kontext
├── README.md               # Entwickler-Dokumentation
├── Dockerfile              # Container-Build
├── docker-compose.yml      # Lokale Entwicklung
├── .env.example            # Umgebungsvariablen-Vorlage
├── .gitignore
├── package.json            # (oder pyproject.toml, etc.)
├── src/                    # Quellcode
├── rules/                  # Coding Standards & Projektregeln
│   ├── coding_standards.md
│   └── projekt_regeln.md
├── skills/                 # Entwicklungs-Skills fuer Claude Code
│   └── development.md
├── scripts/                # Hilfs-Skripte
└── docs/                   # Weitere Dokumentation
```

## Ports

- Ports > 3300 verwenden (niedrigere sind belegt)
- Port in `.env.example`, `Dockerfile` und `docker-compose.yml` konsistent halten
- Belegte Ports siehe `docs/server-setup.md`
