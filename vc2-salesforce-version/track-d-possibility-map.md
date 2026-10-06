# Track D — Master Capability Possibility Map & Lookup Index

## 1. Executive Summary

This document serves as the **Master Possibility Map & Lookup Index** for the Victoria 2 Save-Game Salesforce application, superseding `track-c-possibility-map.md`.

It integrates **265 enumerated capabilities** across 4 architecture layers:
- **Layer 1 (Single-Domain Display)**: `CAP-001` to `CAP-125` (125 capabilities, Track C baseline)
- **Layer 2 (Cross-Domain Analytics)**: `CAP-D-001` to `CAP-D-065` (65 capabilities)
- **Layer 3 (Derived Intelligence)**: `MET-D-001` to `MET-D-045` (45 capabilities)
- **Layer 4 (Platform Extensions)**: `PLAT-D-001` to `PLAT-D-030` (30 capabilities)

---

## 2. Capability Lookup Table (CAP ID → Feature ID → Layer)

### 2.1 Layer 1 Capabilities (CAP-001 to CAP-125)
*Baseline Track C single-domain display capabilities mapped to features `FEAT-01` through `FEAT-16`.*

| Cap ID Scope | Domain | Primary Feature ID | Layer | Reference Document |
|---|---|---|---|---|
| `CAP-001` – `CAP-008` | Save Envelope | `FEAT-01` (Save Header) | Layer 1 | `track-c-possibility-map.md` §2.1 |
| `CAP-009` – `CAP-018` | World Market | `FEAT-02` (Market Visualizer) | Layer 1 | `track-c-possibility-map.md` §2.2 |
| `CAP-019` – `CAP-028` | Economy Parameters | `FEAT-03` (Macro Ledger) | Layer 1 | `track-c-possibility-map.md` §2.3 |
| `CAP-029` – `CAP-042` | Province & POP | `FEAT-04` (POP Demographics) | Layer 1 | `track-c-possibility-map.md` §2.4 |
| `CAP-043` – `CAP-058` | Country Political | `FEAT-05` (Politics Explorer) | Layer 1 | `track-c-possibility-map.md` §2.5 |
| `CAP-059` – `CAP-070` | Military | `FEAT-06` (Military OOB) | Layer 1 | `track-c-possibility-map.md` §2.6 |
| `CAP-071` – `CAP-079` | AI Matrix | `FEAT-07` (AI Strategy) | Layer 1 | `track-c-possibility-map.md` §2.7 |
| `CAP-080` – `CAP-091` | Trade & Influence | `FEAT-08` (Sphere & Focus) | Layer 1 | `track-c-possibility-map.md` §2.8 |
| `CAP-092` – `CAP-098` | Diplomacy | `FEAT-09` (Diplomacy Network) | Layer 1 | `track-c-possibility-map.md` §2.9 |
| `CAP-099` – `CAP-108` | Active War & Combat | `FEAT-10` (Active War) / `FEAT-11` (Battles) | Layer 1 | `track-c-possibility-map.md` §2.10 |
| `CAP-109` – `CAP-118` | Rebels / News / Regions | `FEAT-12` (Rebels) / `FEAT-13` (News) / `FEAT-14` (Colonies) | Layer 1 | `track-c-possibility-map.md` §2.11 |
| `CAP-119` – `CAP-125` | Junctions & State Detail | `FEAT-15` (Compare) / `FEAT-16` (State Inspector) | Layer 1 | `track-c-possibility-map.md` §2.12 |

---

### 2.2 Layer 2 Cross-Domain Capabilities (CAP-D-001 to CAP-D-065)

| Cap ID | Domain Pair | Primary Feature ID | Layer | Reference Document |
|---|---|---|---|---|
| `CAP-D-001` – `CAP-D-005` | Economy × Politics | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.1 |
| `CAP-D-006` – `CAP-D-010` | Economy × Military | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.2 |
| `CAP-D-011` – `CAP-D-015` | Economy × POP | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.3 |
| `CAP-D-016` – `CAP-D-020` | Economy × War | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.4 |
| `CAP-D-021` – `CAP-D-025` | Economy × Diplomacy | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.5 |
| `CAP-D-026` – `CAP-D-030` | Economy × Colonial | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.6 |
| `CAP-D-031` – `CAP-D-035` | POP × War | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.7 |
| `CAP-D-036` – `CAP-D-040` | POP × Ideology | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.8 |
| `CAP-D-041` – `CAP-D-045` | POP × Politics | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.9 |
| `CAP-D-046` – `CAP-D-050` | Military × Diplomacy | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.10 |
| `CAP-D-051` – `CAP-D-055` | Military × AI | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.11 |
| `CAP-D-056` – `CAP-D-060` | Diplomacy × War | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.12 |
| `CAP-D-061` – `CAP-D-062` | Tech × Eco × Military | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.13 |
| `CAP-D-063` – `CAP-D-064` | Culture × Politics × War | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.14 |
| `CAP-D-065` | Influence × Colony × POP | `FEAT-17` (Cross-Domain Engine) | Layer 2 | `track-d-capability-expansion.md` §2.15 |

---

### 2.3 Layer 3 Derived Intelligence Metrics (MET-D-001 to MET-D-045)

| Metric ID Scope | Category | Primary Feature ID | Layer | Reference Document |
|---|---|---|---|---|
| `MET-D-001` – `MET-D-008` | Composite Indices (HDI, IPS, MSC) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.1 |
| `MET-D-009` – `MET-D-014` | Comparative Scores (GDP/cap, Colonial Eff) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.2 |
| `MET-D-015` – `MET-D-021` | Forecasts & Predictions (GDP, Revolt) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.3 |
| `MET-D-022` – `MET-D-026` | Network Metrics (Centrality, Density) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.4 |
| `MET-D-027` – `MET-D-031` | Anomaly Indicators (Outliers, Volatility) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.5 |
| `MET-D-032` – `MET-D-036` | Efficiency Metrics (Utilization, ROI) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.6 |
| `MET-D-037` – `MET-D-040` | Narrative Generators (Decade Chapters) | `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.7 |
| `MET-D-041` – `MET-D-045` | Risk Scores (Rebellion Risk, Default Risk)| `FEAT-18` (Derived Metric Suite) | Layer 3 | `track-d-capability-expansion.md` §3.8 |

---

### 2.4 Layer 4 Platform Extension Capabilities (PLAT-D-001 to PLAT-D-030)

| Platform Cap ID Scope | Feature Focus | Primary Feature ID | Layer | Reference Document |
|---|---|---|---|---|
| `PLAT-D-001` – `PLAT-D-003` | Real-Time Platform Events & Alerts | `FEAT-19` (Real-Time Alert Hub) | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-004` – `PLAT-D-005` | CRM Analytics / Einstein Discovery | `FEAT-18` (Derived Metric Suite) | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-006` – `PLAT-D-007` | Agentforce Conversational AI | `FEAT-20` (Agentforce Advisor) | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-008` – `PLAT-D-009` | Data Cloud Historical Archive | `FEAT-21` (Data Cloud Archive) | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-010` – `PLAT-D-011` | Salesforce Mobile Layouts & Push | `FEAT-01` / `FEAT-19` | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-012` – `PLAT-D-013` | Slack Integration & Slash Commands | `FEAT-19` (Real-Time Alert Hub) | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-014` – `PLAT-D-015` | Experience Cloud Community | `FEAT-22` (Player Community) | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-016` – `PLAT-D-018` | Tableau CRM / Native Reports | `FEAT-02` / `FEAT-05` | Layer 4 | `track-d-platform-possibilities.md` §2 |
| `PLAT-D-019` – `PLAT-D-030` | Scheduled Apex, Functions, Flow | `FEAT-19` / Platform Core | Layer 4 | `track-d-platform-possibilities.md` §2 |
