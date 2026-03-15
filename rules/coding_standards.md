# Coding Standards

> Allgemeine Regeln fuer alle Projekte. Projektspezifische Ergaenzungen gehoeren in die jeweilige CLAUDE.md.

## Linting & Formatierung

### Node.js / JavaScript
```json
// .eslintrc.json (Empfehlung)
{
  "extends": ["eslint:recommended"],
  "env": { "node": true, "es2022": true },
  "parserOptions": { "ecmaVersion": 2022 }
}
```

### Python (falls verwendet)
```toml
# pyproject.toml
[tool.ruff]
line-length = 120
target-version = "py312"
```

### Prettier (falls Frontend)
```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100
}
```

## Namenskonventionen

| Kontext | Stil | Beispiel |
|---------|------|----------|
| Dateien/Ordner | kebab-case | `user-service.js` |
| Variablen/Funktionen (JS) | camelCase | `getUserById` |
| Klassen/Komponenten | PascalCase | `UserService` |
| Datenbank-Tabellen | snake_case, Plural | `users`, `order_items` |
| Datenbank-Spalten | snake_case | `created_at`, `first_name` |
| Umgebungsvariablen | UPPER_SNAKE_CASE | `DATABASE_URL` |
| CSS-Klassen | kebab-case | `main-header` |
| API-Endpunkte | kebab-case, Plural | `/api/v1/user-profiles` |

## API-Design

- RESTful mit Versionierung: `/api/v1/...`
- Ressourcen im Plural: `/users`, `/orders`
- Standard-HTTP-Methoden: GET, POST, PUT/PATCH, DELETE
- Pagination: `?page=1&size=20`
- Soft-Delete bevorzugen (Spalte `deleted_at`)
- Fehlerantworten einheitlich:
  ```json
  {
    "error": "NOT_FOUND",
    "message": "Benutzer nicht gefunden",
    "status": 404
  }
  ```

## Datenbank

- Jede Tabelle hat: `id` (Primary Key), `created_at`, `updated_at`
- Foreign Keys immer mit `_id` Suffix: `user_id`, `order_id`
- Indizes auf haeufig gesuchte Spalten und Foreign Keys
- Migrationen versioniert (Alembic, Knex, Prisma o.ae.)
- Eine Migration pro Feature/Aenderung

## Git-Workflow

### Branches
```
feature/kurze-beschreibung    # Neues Feature
fix/kurze-beschreibung        # Bugfix
refactor/kurze-beschreibung   # Refactoring
docs/kurze-beschreibung       # Dokumentation
```

### Commit-Messages
- Auf **Deutsch**, kurz und praegnant
- Beschreibend: Was wurde geaendert und warum
- Beispiele:
  - `Benutzer-Authentifizierung hinzugefuegt`
  - `Fehler bei Datumsberechnung behoben`
  - `API-Endpunkte fuer Bestellungen erstellt`

### Regeln
- Kein Force-Push auf `main`
- Feature-Branches aus `main` erstellen
- Nach Merge: Branch loeschen

## Tests

- Mindestens fuer Business-Logik und API-Endpunkte
- Test-Framework je nach Stack:
  - Node.js: Jest oder Vitest
  - Python: pytest
- Testdaten ueber Factories/Fixtures, nicht hardcoded
- Keine Produktionsdaten in Tests

## Sicherheit

- **Keine Secrets im Code** — immer ueber Umgebungsvariablen
- Eingaben validieren (Schemas: Joi, Zod, Pydantic)
- SQL-Injection verhindern (ORM oder Prepared Statements)
- CORS nur fuer erlaubte Origins
- Abhaengigkeiten regelmaessig aktualisieren
