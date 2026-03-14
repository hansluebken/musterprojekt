# Server-Setup & Workflow-Dokumentation

## Architektur

```
┌─────────────────────┐         ┌──────────────────────────────┐
│   Mac (lokal)       │         │   4hl.dev (Server)           │
│                     │         │                              │
│  Claude Code        │         │  Coolify                     │
│  ├── Code schreiben │  git    │  ├── Dashboard (:8888)       │
│  ├── Lokal testen   │ push    │  ├── Traefik (Reverse Proxy) │
│  └── Commit & Push  │───────► │  ├── Auto-Deploy bei Push    │
│                     │         │  └── SSL-Zertifikate (Let's  │
│  GitHub CLI (gh)    │         │       Encrypt)               │
│  Docker (lokal)     │  SSH    │                              │
│                     │───────► │  Docker-Container            │
│                     │         │  ├── app.4hl.dev             │
│                     │         │  ├── api.4hl.dev             │
│                     │         │  └── ...                     │
└─────────────────────┘         └──────────────────────────────┘
```

## Zugangsdaten

| Was | Wert |
|-----|------|
| SSH | `ssh -p 4321 -i ~/.ssh/hansprobook kuenstler@4hl.dev` |
| Coolify Dashboard | https://4hl.dev:8888 |
| GitHub Account | hansluebken |
| Coolify API Token | `~/.coolify-token` (muss einmalig erstellt werden) |

## Neues Projekt erstellen

### Automatisch (empfohlen)

```bash
cd ~/Organisatorisches/musterprojekt
./scripts/new-project.sh
```

Das Script:
1. Fragt nach Name, Port, Domain
2. Kopiert das Musterprojekt als Template
3. Ersetzt alle Platzhalter
4. Erstellt GitHub-Repo
5. Erstellt Coolify-Projekt + App via API
6. Startet das erste Deployment

### Manuell

1. Repo von musterprojekt kopieren
2. In Coolify: Neues Projekt → Public Repository → GitHub-URL
3. Build Pack: Dockerfile, Domain setzen, Port eintragen

## Coolify API Token erstellen

1. Öffne https://4hl.dev:8888
2. Gehe zu **Settings → API Tokens**
3. Erstelle einen neuen Token (Name: "claude-code")
4. Speichere ihn:
   ```bash
   echo 'dein-token-hier' > ~/.coolify-token
   chmod 600 ~/.coolify-token
   ```

## Typischer Entwicklungsworkflow

```
1. cd ~/projekte/mein-projekt
2. claude                        # Claude Code starten
3. "Baue Feature X"              # Claude schreibt Code
4. docker compose up --build     # Lokal testen
5. "Commit und Push"             # Claude committed & pusht
6. Coolify deployt automatisch   # ← passiert auf dem Server
7. https://mein-projekt.4hl.dev  # Live!
```

## Belegte Ports auf dem Server

| Port | Dienst |
|------|--------|
| 80/443 | Coolify/Traefik (Reverse Proxy) |
| 3000 | eisenhower-backend |
| 5173 | eisenhower-frontend |
| 8080 | Traefik Dashboard |
| 8888 | Coolify Dashboard |
| 9091 | Authelia |

**Tipp:** Neue Projekte sollten Ports > 3300 verwenden. Das `new-project.sh` Script vergibt automatisch einen zufälligen Port.

## DNS-Setup für neue Subdomains

Damit `mein-projekt.4hl.dev` funktioniert, muss ein DNS-Eintrag existieren:
- **Wildcard:** `*.4hl.dev → IP von 4hl.dev` (ideal, dann funktionieren alle Subdomains automatisch)
- **Einzeln:** `mein-projekt.4hl.dev → IP von 4hl.dev` (falls kein Wildcard)

Prüfen:
```bash
dig mein-projekt.4hl.dev
```

## Troubleshooting

### App nicht erreichbar nach Deploy
```bash
# Container-Status prüfen
ssh -p 4321 kuenstler@4hl.dev "docker ps | grep mein-projekt"

# Logs ansehen
ssh -p 4321 kuenstler@4hl.dev "docker logs CONTAINER_NAME 2>&1 | tail -100"

# Coolify Deployment-Logs
# → Dashboard → Projekt → Deployments → letztes Deployment anklicken
```

### DNS löst nicht auf
```bash
# Wildcard-DNS prüfen
dig +short test123.4hl.dev

# Falls leer: DNS-Eintrag beim Provider anlegen
```

### Port-Konflikt
```bash
# Belegte Ports auf Server prüfen
ssh -p 4321 kuenstler@4hl.dev "docker ps --format '{{.Ports}}' | sort -u"
```
