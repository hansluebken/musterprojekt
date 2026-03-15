# Ninox Skills

> Patterns fuer die Arbeit mit Ninox-Datenbanken via API und Scripting.
> Quelle: [showNxTeam](https://github.com/hansluebken/showNxTeam)

## REST API

```
Base-URL:  https://{domain}/v1
Auth:      Bearer {api_key}
```

| Methode | Endpunkt | Beschreibung |
|---------|----------|-------------|
| GET | `/teams/{teamId}/databases/{dbId}?formatScripts=T` | Schema mit lesbaren Feldnamen |
| GET | `.../tables/{tableId}/records` | Datensaetze lesen |
| POST | `.../tables/{tableId}/records` | `{ "fields": {...} }` |
| PUT | `.../tables/{tableId}/records/{recordId}` | Datensatz aktualisieren |
| DELETE | `.../tables/{tableId}/records/{recordId}` | Datensatz loeschen |

### API-Client (Node.js)

```javascript
class NinoxAPIClient {
  constructor(domain, apiKey) {
    this.baseUrl = `https://${domain}/v1`
    this.headers = { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' }
  }

  async request(path, options = {}) {
    const res = await fetch(`${this.baseUrl}${path}`, { ...options, headers: this.headers })
    if (!res.ok) throw new Error(`Ninox API ${res.status}: ${res.statusText}`)
    return res.json()
  }

  getSchema(teamId, dbId) { return this.request(`/teams/${teamId}/databases/${dbId}?formatScripts=T`) }
  getRecords(teamId, dbId, tableId) { return this.request(`/teams/${teamId}/databases/${dbId}/tables/${tableId}/records`) }
  createRecord(teamId, dbId, tableId, fields) {
    return this.request(`/teams/${teamId}/databases/${dbId}/tables/${tableId}/records`, {
      method: 'POST', body: JSON.stringify({ fields }),
    })
  }
}
```

## Scripting Kurzreferenz

### Script-Typen

| Ebene | Typen |
|-------|-------|
| Datenbank | `globalCode`, `afterOpen`, `beforeOpen` |
| Tabelle | `afterCreate`, `afterUpdate`, `afterDelete`, `beforeDelete` |
| Feld | `fn` (Formel), `onClick` (Button), `visibility`, `validation`, `constraint` |
| Rechte | `canRead`, `canWrite`, `canCreate`, `canDelete` |

### Wichtigste Konstrukte

```
let variable := wert
if bedingung then ... else ... end
for item in collection do ... end
select Tabelle where Feld = "Wert" order by Feld
do as database 'Name' ... end        # Cross-DB Zugriff
do as server ... end                  # Server-Level
function name(param) do ... end
try ... catch e do ... end
```

### Haeufig genutzte Funktionen

```
# Datensaetze: create, delete, duplicate, record, records, first, last
# Aggregate:   count, sum, avg, min, max
# Strings:     text, number, upper, lower, trim, length, substr, replace, contains, split, join
# Datum:       today, now, date, year, month, day, dateAdd, dateDiff, dateFormat
# HTTP:        http, httpGet, httpPost, httpPut, httpDelete
# UI:          alert, confirm, prompt, dialog, popupRecord, openRecord, openUrl
# User:        userId, userName, userEmail, userRoles, hasRole, isAdmin
# Util:        isnull, isempty, coalesce, parseJSON, formatJSON, debug
```

## Beziehungstypen

| Typ | Beschreibung | Erkennung im Code |
|-----|-------------|-------------------|
| N:1 | Referenzfeld | Feld-Typ `ref` |
| 1:N | Inverse Referenz | Automatisch |
| M:N | Viele-zu-Viele | Zwischentabelle |
| Cross-DB | Datenbanküebergreifend | `do as database`, `openDatabase` |

## Schema-Extraktion (showNxTeam)

```bash
python ninox_cli.py extract --team TEAM_ID --db DB_ID   # Schema extrahieren
python ninox_cli.py search "suchbegriff"                 # Scripts durchsuchen
python ninox_cli.py deps --db DB_ID                      # Abhaengigkeiten anzeigen
```
