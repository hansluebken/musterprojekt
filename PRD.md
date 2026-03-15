# PRD: Musterprojekt

> Product Requirements Document – beschreibt WAS die Software koennen soll.

## 1. Projektuebersicht

| Feld | Wert |
|------|------|
| **Projektname** | Musterprojekt |
| **Version** | 0.1.0 |
| **Status** | Entwurf |
| **Erstellt** | DATUM |
| **Autor** | NAME |

### Kurzbeschreibung

<!-- 2-3 Saetze: Was macht die Software? Fuer wen? Welches Problem loest sie? -->

### Ziele

<!-- Was soll erreicht werden? -->
- [ ] Ziel 1
- [ ] Ziel 2
- [ ] Ziel 3

### Nicht-Ziele (Out of Scope)

<!-- Was gehoert explizit NICHT dazu? -->
-

## 2. Benutzerrollen

| Rolle | Beschreibung | Berechtigungen |
|-------|-------------|----------------|
| Admin | Voller Zugriff | Alles |
| Standard | Normaler Benutzer | Lesen, Schreiben |

## 3. Features

### Feature 1: [Name]

**Beschreibung:** <!-- Was soll das Feature tun? -->

**Akzeptanzkriterien:**
- [ ] Kriterium 1
- [ ] Kriterium 2

**Prioritaet:** Hoch / Mittel / Niedrig

---

### Feature 2: [Name]

**Beschreibung:**

**Akzeptanzkriterien:**
- [ ] Kriterium 1

**Prioritaet:** Hoch / Mittel / Niedrig

---

<!-- Weitere Features nach dem gleichen Muster ergaenzen -->

## 4. Datenmodell

<!-- Wichtigste Entitaeten und ihre Beziehungen -->

```
Entitaet_A (1) ──── (N) Entitaet_B
    │
    └── Feld_1: Typ (Beschreibung)
    └── Feld_2: Typ (Beschreibung)
```

## 5. API-Endpunkte

| Methode | Endpunkt | Beschreibung | Auth |
|---------|----------|-------------|------|
| GET | `/api/v1/...` | ... | Ja |
| POST | `/api/v1/...` | ... | Ja |

## 6. Geschaeftsregeln

<!-- Wichtige Logik und Regeln, die die Software einhalten muss -->

| Nr. | Regel | Beschreibung |
|-----|-------|-------------|
| BR-01 | | |
| BR-02 | | |

## 7. UI/UX Anforderungen

<!-- Grobe Beschreibung der Oberflaeche, wichtige Screens -->

### Hauptansicht

<!-- Beschreibung oder ASCII-Skizze -->

### Weitere Ansichten

-

## 8. Technische Anforderungen

| Anforderung | Wert |
|-------------|------|
| Performance | Antwortzeit < X ms |
| Verfuegbarkeit | X% Uptime |
| Browser | Chrome, Firefox, Safari (aktuell) |
| Mobile | Responsive / Nein |

## 9. Externe Integrationen

<!-- Schnittstellen zu anderen Systemen -->

| System | Art | Beschreibung |
|--------|-----|-------------|
| | REST API | |
| | Webhook | |

## 10. Migration / Datenuebertragung

<!-- Falls Daten aus einem bestehenden System uebernommen werden muessen -->

- **Quelle:**
- **Umfang:**
- **Strategie:**

## 11. Offene Fragen

<!-- Ungeklaerte Punkte, die noch entschieden werden muessen -->

- [ ] Frage 1?
- [ ] Frage 2?

## 12. Meilensteine

| Phase | Beschreibung | Zieldatum |
|-------|-------------|-----------|
| MVP | Grundfunktionen | |
| v1.0 | Erste vollstaendige Version | |
| v2.0 | Erweiterungen | |
