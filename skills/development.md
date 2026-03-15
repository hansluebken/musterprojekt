# Development Skills

> Patterns und Vorlagen fuer die Entwicklung. Projektspezifische Skills koennen in weiteren Dateien ergaenzt werden (z.B. `skills/backend.md`, `skills/frontend.md`).

## Express.js Backend (Node.js)

### Projekt-Setup
```bash
npm init -y
npm install express dotenv
```

### Basis-Server
```javascript
// src/index.js
const express = require('express')
const app = express()

const PORT = process.env.PORT || 3333

app.use(express.json())

// Health-Check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// API-Routes einbinden
// app.use('/api/v1/users', require('./routes/users'))

app.listen(PORT, () => {
  console.log(`Server laeuft auf Port ${PORT}`)
})
```

### Route-Pattern
```javascript
// src/routes/beispiel.js
const router = require('express').Router()

// GET /api/v1/beispiel
router.get('/', async (req, res) => {
  try {
    const { page = 1, size = 20 } = req.query
    // const items = await service.list({ page, size })
    res.json({ data: [], page: Number(page), size: Number(size) })
  } catch (err) {
    res.status(500).json({ error: 'INTERNAL_ERROR', message: err.message })
  }
})

// GET /api/v1/beispiel/:id
router.get('/:id', async (req, res) => {
  try {
    // const item = await service.getById(req.params.id)
    // if (!item) return res.status(404).json({ error: 'NOT_FOUND' })
    res.json({ data: null })
  } catch (err) {
    res.status(500).json({ error: 'INTERNAL_ERROR', message: err.message })
  }
})

// POST /api/v1/beispiel
router.post('/', async (req, res) => {
  try {
    // const item = await service.create(req.body)
    res.status(201).json({ data: null })
  } catch (err) {
    res.status(400).json({ error: 'VALIDATION_ERROR', message: err.message })
  }
})

module.exports = router
```

### Middleware-Pattern
```javascript
// src/middleware/error-handler.js
function errorHandler(err, req, res, next) {
  console.error(err.stack)
  res.status(err.status || 500).json({
    error: err.code || 'INTERNAL_ERROR',
    message: err.message || 'Interner Serverfehler',
  })
}

// src/middleware/validate.js
function validate(schema) {
  return (req, res, next) => {
    const { error } = schema.validate(req.body)
    if (error) {
      return res.status(400).json({
        error: 'VALIDATION_ERROR',
        message: error.details[0].message,
      })
    }
    next()
  }
}
```

## Docker

### Multi-Stage Dockerfile
```dockerfile
# -- Build Stage --
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# -- Run Stage --
FROM node:20-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json ./
USER appuser
EXPOSE 3333
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3333/health || exit 1
CMD ["node", "src/index.js"]
```

### Docker Compose (Entwicklung)
```yaml
services:
  app:
    build: .
    ports:
      - "${PORT:-3333}:${PORT:-3333}"
    environment:
      - NODE_ENV=development
      - PORT=${PORT:-3333}
    volumes:
      - ./src:/app/src    # Hot-Reload
    restart: unless-stopped
```

## Datenbank-Anbindung (optional)

### PostgreSQL mit pg
```bash
npm install pg
```

```javascript
// src/db.js
const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
}
```

### SQLite mit better-sqlite3 (fuer einfache Projekte)
```bash
npm install better-sqlite3
```

```javascript
// src/db.js
const Database = require('better-sqlite3')
const db = new Database(process.env.DB_PATH || './data/app.db')
db.pragma('journal_mode = WAL')
module.exports = db
```

## Testen

### Jest Setup
```bash
npm install --save-dev jest supertest
```

```javascript
// tests/health.test.js
const request = require('supertest')
const app = require('../src/app') // Express-App exportieren

describe('GET /health', () => {
  it('gibt Status ok zurueck', async () => {
    const res = await request(app).get('/health')
    expect(res.status).toBe(200)
    expect(res.body.status).toBe('ok')
  })
})
```

## Nuetzliche npm-Pakete

| Paket | Zweck |
|-------|-------|
| `express` | Web-Framework |
| `dotenv` | Umgebungsvariablen aus `.env` |
| `cors` | Cross-Origin Requests |
| `helmet` | Sicherheits-Header |
| `morgan` | HTTP-Logging |
| `joi` / `zod` | Eingabe-Validierung |
| `pg` | PostgreSQL-Client |
| `better-sqlite3` | SQLite-Client |
| `jest` | Test-Framework |
| `supertest` | HTTP-Tests |
