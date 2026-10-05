# Track D — Extended Feature Roadmap & Consolidation

## 1. Executive Summary

This document consolidates all capabilities identified across Track C (`CAP-001` through `CAP-125`) and Track D (`CAP-D-001` through `CAP-D-065`, `MET-D-001` through `MET-D-045`, and `PLAT-D-001` through `PLAT-D-030`) into a unified master feature catalogue and extended execution roadmap.

### Consolidated Metrics
- **Total Enumerated Capabilities**: **265 Capabilities** across 4 architecture layers:
  - **Layer 1 (Single-Domain Display)**: 125 capabilities (`CAP-001`–`CAP-125`)
  - **Layer 2 (Cross-Domain Analytics)**: 65 capabilities (`CAP-D-001`–`CAP-D-065`)
  - **Layer 3 (Derived Intelligence)**: 45 metrics (`MET-D-001`–`MET-D-045`)
  - **Layer 4 (Platform Extensions)**: 30 features (`PLAT-D-001`–`PLAT-D-030`)
- **Total Features After Consolidation**: **22 Features** (`FEAT-01` through `FEAT-22`).
  - Track C Base Features: `FEAT-01` to `FEAT-16`
  - Track D Advanced Features: `FEAT-17` to `FEAT-22`

### Recommended Build Order (Top 10 Ranked)
1. `FEAT-01`: Unified Save Game Header & Settings Bar
2. `FEAT-05`: Country Politics & Reform Dashboard
3. `FEAT-06`: Military Order of Battle (OOB) Explorer
4. `FEAT-17`: Cross-Domain Macro Intelligence Engine
5. `FEAT-08`: Sphere of Influence & Focus Tracker
6. `FEAT-12`: Rebel Insurgency & Occupation Monitor
7. `FEAT-18`: Derived Metric & Anomaly Intelligence Suite
8. `FEAT-02`: Global Commodity Market Visualizer
9. `FEAT-19`: Real-Time Event & Anomaly Alert Hub
10. `FEAT-15`: Multi-Save Time Series Comparison Suite

---

## 2. Consolidated Feature Catalogue (22 Features)

| Feature ID | Feature Name | Domain Coverage | Layer Coverage | Effort | Value | Risk | Depends On | Reuses Asset |
|---|---|---|---|---|---|---|---|---|
| `FEAT-01` | Save Header & Settings Bar | Save Envelope | Layer 1 | S | HIGH | LOW | Phase 0 | `c-economy-analysis-header` |
| `FEAT-02` | Market Visualizer | World Market | Layer 1 | M | HIGH | LOW | `FEAT-01` | `c-product-list-view` |
| `FEAT-03` | Macro Parameter Ledger | Parameters | Layer 1 | S | MEDIUM | LOW | `FEAT-01` | `EconomyCalculationEngine` |
| `FEAT-04` | POP Demographics Explorer | Province / POP | Layer 1 | XL | HIGH | HIGH | `FEAT-01` | `EconomyImportBatch` |
| `FEAT-05` | Country Politics Dashboard | Politics | Layer 1 | M | HIGH | LOW | `FEAT-01` | `c-country-dashboard` |
| `FEAT-06` | Military OOB Explorer | Military | Layer 1 | M | HIGH | MEDIUM | `FEAT-01` | `c-economic-charts-container` |
| `FEAT-07` | AI Strategy Matrix | AI | Layer 1 | M | MEDIUM | LOW | `FEAT-05`, `FEAT-09` | New LWC Matrix |
| `FEAT-08` | Sphere & Focus Tracker | Influence / Trade | Layer 1 | M | HIGH | LOW | `FEAT-05` | `c-country-dashboard` |
| `FEAT-09` | Diplomatic Treaty Network | Diplomacy | Layer 1 | S | MEDIUM | LOW | `FEAT-05` | `CountrySelector` |
| `FEAT-10` | Active War Monitor | War | Layer 1 | L | HIGH | MEDIUM | `FEAT-06` | New Conflict View |
| `FEAT-11` | Battle History Timeline | War | Layer 1 | M | MEDIUM | LOW | `FEAT-10` | `c-multi-save-trend` |
| `FEAT-12` | Rebel Monitor | Rebels / News | Layer 1 | S | HIGH | LOW | `FEAT-01` | `c-country-dashboard` |
| `FEAT-13` | Newspaper Reader | News | Layer 1 | S | LOW | LOW | `FEAT-01` | Simple News LWC |
| `FEAT-14` | Crisis & Colonial Manager | Colonies | Layer 1 | M | HIGH | LOW | `FEAT-08` | `c-global-economy-dashboard` |
| `FEAT-15` | Multi-Save Comparison Suite | All | Layer 1 | M | HIGH | MEDIUM | `FEAT-01`, `FEAT-05` | `c-analysis-compare` |
| `FEAT-16` | State Industrial Inspector | State / Factory | Layer 1 | M | MEDIUM | LOW | `FEAT-01` | `c-state-dashboard` |
| `FEAT-17` | **Cross-Domain Macro Intelligence Engine** | Eco × Pol × Mil × Pop | Layer 2 | M | HIGH | MEDIUM | `FEAT-01`, `FEAT-05`, `FEAT-06` | `SaveAnalysisController` |
| `FEAT-18` | **Derived Metric & Anomaly Suite** | All Domains | Layer 3 | M | HIGH | LOW | `FEAT-17` | Pure Calculation Engine |
| `FEAT-19` | **Real-Time Anomaly Alert Hub** | Integration / Platform | Layer 4 | S | HIGH | LOW | `FEAT-18` | Platform Events |
| `FEAT-20` | **Agentforce Campaign Advisor** | AI / Platform | Layer 4 | L | HIGH | MEDIUM | `FEAT-18` | Agentforce / Prompt Templates |
| `FEAT-21` | **Data Cloud Long-Term Archive** | Storage / Analytics | Layer 4 | XL | HIGH | HIGH | `FEAT-15` | Data Cloud Custom Entities |
| `FEAT-22` | **Experience Cloud Player Community** | External Community | Layer 4 | L | MEDIUM | LOW | `FEAT-01` | LWC Shared Views |

---

## 3. Extended Prioritisation Matrix (Value $\times$ Effort)

```
                       HIGH VALUE                             MEDIUM VALUE                  LOW VALUE
             +--------------------------------------+------------------------------+--------------------------+
  S EFFORT   | FEAT-01: Save Header                 | FEAT-03: Macro Ledger        | FEAT-13: Newspaper Reader|
  (Quick     | FEAT-12: Rebel Monitor               | FEAT-09: Diplomacy Network   |                          |
   Wins)     | FEAT-19: Real-Time Alert Hub         |                              |                          |
             +--------------------------------------+------------------------------+--------------------------+
  M EFFORT   | FEAT-05: Politics Explorer           | FEAT-07: AI Strategy Matrix  |                          |
  (Core      | FEAT-06: Military OOB                | FEAT-11: Battle History      |                          |
   Build)    | FEAT-17: Cross-Domain Macro Engine   | FEAT-16: State Inspector     |                          |
             | FEAT-18: Derived Metric Suite        |                              |                          |
             | FEAT-08: Sphere & Focus Tracker      |                              |                          |
             | FEAT-02: Market Visualizer           |                              |                          |
             | FEAT-14: Crisis & Colonial Manager   |                              |                          |
             | FEAT-15: Multi-Save Compare Suite    |                              |                          |
             +--------------------------------------+------------------------------+--------------------------+
  L / XL     | FEAT-10: Active War Monitor          | FEAT-22: Experience Community|                          |
  (Strategic | FEAT-04: POP Demographics Explorer   |                              |                          |
   Bets)     | FEAT-20: Agentforce Campaign Advisor |                              |                          |
             | FEAT-21: Data Cloud Long-Term Archive|                              |                          |
             +--------------------------------------+------------------------------+--------------------------+
```

---

## 4. Extended Dependency Graph

```
[Phase 0: Data Model Remediation]
              |
              v
[FEAT-01: Save Header & Settings Bar]
   |          |             |              |             |
   |          v             v              v             v
   |     [FEAT-05: Pol] [FEAT-06: Mil] [FEAT-02: Mkt] [FEAT-12: Reb]
   |          |             |
   |          +------+------+
   |                 |
   |                 v
   |     [FEAT-17: Cross-Domain Macro Engine]
   |                 |
   |                 v
   |     [FEAT-18: Derived Metric & Anomaly Suite]
   |            /    |    \
   |           /     |     \
   |          v      v      v
   |    [FEAT-19] [FEAT-20] [FEAT-10: Active War Monitor]
   |   (Alerts)  (Agentforce)       |
   |                                v
   |                          [FEAT-11: Battles]
   |
   +---------------------------------------+
   |                  |                    |
   v                  v                    v
[FEAT-03: Macro]  [FEAT-15: Compare]  [FEAT-16: State]
                      |
                      v
             [FEAT-21: Data Cloud]
```

---

## 5. Layer-by-Layer Highlights

1. **Layer 1 (Track C — Present-Tense Display)**: Answers "what is happening right now?" by displaying raw save file entities (e.g. ruling party, active wars, commodity prices).
2. **Layer 2 (Track D — Cross-Domain Analytics)**: Answers "how do two systems interact?" by intersecting domain pairs (e.g. tax rate vs GDP growth, military casualties vs soldier POP size depletion).
3. **Layer 3 (Track D — Derived Intelligence)**: Answers "what do the numbers mean and predict?" by calculating synthetic indices (HDI, Bankruptcy Risk, Rebellion Probability, GDP Forecasts).
4. **Layer 4 (Track D — Platform Extensions)**: Answers "how can enterprise Salesforce tech extend the experience?" via Platform Events, Agentforce conversational AI, Data Cloud archives, and Slack notifications.

---

## 6. Do Not Build List (Consolidated)

The following capabilities remain explicitly excluded from execution:

1. **Direct In-Memory Save File Binary/Text Writer**: Severe corruption risk to original `.v2` game saves.
2. **Real-Time 3D Particle Combat Canvas**: Excessive browser DOM memory consumption without analytical value.
3. **Un-aggregated Raw POP Management Table**: Displaying 100,000+ individual `Pop__c` rows directly in LWC will crash browser rendering. All POP views must consume pre-aggregated DTO rollups.
4. **Pure Apex Regex Text Save Parser**: Parsing 50MB raw text files in Apex exceeds 12MB async heap limit. Parsing must remain in Python/Functions.
5. **Real-Time High-Frequency Multiplayer Synchronizer**: Victoria 2 is daily tick-based, not continuous millisecond streaming. Synchronizing ticks sub-second causes platform limit exhaustion.

---

## 7. Open Questions for Project Owner

1. **Priority Alignment**: Should initial Phase 1 execution focus on Layer 1 quick wins (`FEAT-01`, `FEAT-05`, `FEAT-06`) or immediately build the Layer 2/3 Cross-Domain Engine (`FEAT-17`, `FEAT-18`)?
2. **Agentforce Integration Scope**: Is Agentforce conversational AI (`FEAT-20`) desired for player-facing single-player exploration?
3. **Data Storage Strategy**: Will multi-save time series analytics rely on Custom Object storage with snapshot retention limits or require Data Cloud (`FEAT-21`)?
