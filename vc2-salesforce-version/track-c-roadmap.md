# Track C — Prioritised Data Model Feature Roadmap

## 1. Executive Summary

This document establishes the strategic, dependency-ordered feature implementation roadmap derived from the 136-object Victoria 2 Save-Game Salesforce Data Model.

### Key Metrics
- **Total Features Catalogued**: 16 distinct features covering 125 enumerated capabilities.
- **Data Model Readiness Status**: 🛑 **BLOCKED** — 15 deployment-blocking metadata defects in `salesforce_model_expanded.txt` must be remediated prior to feature execution.
- **Effort Tier Distribution**:
  - **S (Small $\le 1$ sprint)**: 4 features (25%)
  - **M (Medium 2–4 sprints)**: 10 features (62.5%)
  - **L (Large 5–10 sprints)**: 1 feature (6.25%)
  - **XL (Extra Large $>10$ sprints)**: 1 feature (6.25%)
- **Value Tier Distribution**:
  - **HIGH Value**: 10 features (62.5%)
  - **MEDIUM Value**: 5 features (31.25%)
  - **LOW Value**: 1 feature (6.25%)

---

## 2. Data Model Readiness & Remediation Prerequisites

Feature development **cannot commence** until Phase 0 Metadata Remediation is executed on `salesforce_model_expanded.txt` (see `track-c-data-model-audit.md`).

### Prerequisite Phase 0 Fixes (Must Precede Feature 1):
1. Strip direct `<Country_Ref__c>` lookups (271 on `Save_Game__c`, 116 on `Country_Save_State__c`) and enforce `Save_Game_Country_Ref__c` & `Country_Country_Ref__c` junction objects.
2. Remove double suffix artifacts (`Country_Save_State_Save_State__c` and `Province_Save_State_Save_State__c`).
3. Revert 43 bulk-renamed `News_Scope_Value__c` fields back to `Value__c`.
4. Remove legacy `Pop__c.Ideology__c` and `Pop__c.Issues__c` lookup fields.

---

## 3. Prioritisation Matrix (Value $\times$ Effort)

```
                       HIGH VALUE                   MEDIUM VALUE                LOW VALUE
             +----------------------------+----------------------------+--------------------------+
  S EFFORT   | FEAT-01: Save Header       | FEAT-03: Macro Ledger      | FEAT-13: Newspaper Reader|
  (Quick     | FEAT-12: Rebel Insurgency  | FEAT-09: Diplomacy Network |                          |
   Wins)     |                            |                            |                          |
             +----------------------------+----------------------------+--------------------------+
  M EFFORT   | FEAT-05: Politics Explorer | FEAT-07: AI Strategy Matrix|                          |
  (Core      | FEAT-06: Military OOB      | FEAT-11: Battle History    |                          |
   Build)    | FEAT-08: Sphere & Focus    | FEAT-16: State Inspector   |                          |
             | FEAT-02: Market Visualizer |                            |                          |
             | FEAT-14: Crisis & Colonies |                            |                          |
             | FEAT-15: Save Compare Suite|                            |                          |
             +----------------------------+----------------------------+--------------------------+
  L / XL     | FEAT-10: Active War Mon.   |                            |                          |
  (Strategic | FEAT-04: POP Demographics  |                            |                          |
   Bets)     |                            |                            |                          |
             +----------------------------+----------------------------+--------------------------+
```

---

## 4. Recommended Build Order (Top 16 Ranked)

### Rank 1: `FEAT-01` — Unified Save Game Header & Settings Bar
- **Effort**: `S` | **Value**: `HIGH` | **Risk**: `LOW`
- **Rationale**: Core foundational workspace header providing active snapshot metadata, date, player tag, and gameplay rules.
- **Dependencies**: Data Model Remediation (Phase 0).
- **Asset Reuse**: Extends `c-economy-analysis-header` and `AnalysisSummaryDTO`.

### Rank 2: `FEAT-05` — Country Politics & Reform Dashboard
- **Effort**: `M` | **Value**: `HIGH` | **Risk**: `LOW`
- **Rationale**: Core political intelligence engine exposing ruling party, government form, Upper House breakdown, tax policy, and active movements.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Extends `c-country-dashboard` and `CountrySelector`.

### Rank 3: `FEAT-06` — Military Order of Battle (OOB) & Brigade Explorer
- **Effort**: `M` | **Value**: `HIGH` | **Risk**: `MEDIUM`
- **Rationale**: High-value military view showing land armies, navies, generals, unit compositions, and standing strength.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Reuses `c-economic-charts-container` for composition rendering.

### Rank 4: `FEAT-08` — Sphere of Influence & National Focus Tracker
- **Effort**: `M` | **Value**: `HIGH` | **Risk**: `LOW`
- **Rationale**: Critical Great Power gameplay analytics detailing influence scores, sphere status, and foreign investments.
- **Dependencies**: `FEAT-05`.
- **Asset Reuse**: Extends `c-country-dashboard`.

### Rank 5: `FEAT-12` — Rebel Insurgency & Occupation Monitor
- **Effort**: `S` | **Value**: `HIGH` | **Risk**: `LOW`
- **Rationale**: Quick-win security dashboard tracking rebel faction strength, culture, demands, and occupied provinces.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Extends `c-country-dashboard`.

### Rank 6: `FEAT-02` — Global Commodity Market Visualizer
- **Effort**: `M` | **Value**: `HIGH` | **Risk**: `LOW`
- **Rationale**: Expands existing market table into a full world market supply/demand and commodity price trend analyzer.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Extends `c-product-list-view` and `ProductSelector`.

### Rank 7: `FEAT-14` — Great Power Crisis & Colonial Expansion Manager
- **Effort**: `M` | **Value**: `HIGH` | **Risk**: `LOW`
- **Rationale**: Global crisis manager tracking crisis location, backer nations, tension levels, and colonial expansion potential.
- **Dependencies**: `FEAT-08`.
- **Asset Reuse**: Extends `c-global-economy-dashboard`.

### Rank 8: `FEAT-15` — Multi-Save Time Series Comparison Suite
- **Effort**: `M` | **Value**: `HIGH` | **Risk**: `MEDIUM`
- **Rationale**: Extends save comparison engine across political, military, and demographic metrics across 3–12 save game snapshots.
- **Dependencies**: `FEAT-01`, `FEAT-05`, `FEAT-06`.
- **Asset Reuse**: Extends `c-analysis-compare` and `c-multi-save-trend`.

### Rank 9: `FEAT-10` — Active War & Military Conflict Monitor
- **Effort**: `L` | **Value**: `HIGH` | **Risk**: `MEDIUM`
- **Rationale**: Real-time war tracking engine displaying ongoing conflicts, war goals, primary participants, warscore, casualties, and siege progress.
- **Dependencies**: `FEAT-06`.
- **Asset Reuse**: Requires new `ActiveWarSelector` and conflict LWC view.

### Rank 10: `FEAT-04` — POP Demographics & Need Fulfillment Explorer
- **Effort**: `XL` | **Value**: `HIGH` | **Risk**: `HIGH`
- **Rationale**: Deepest demographic breakdown (type, culture, religion, needs, cash reserves). High technical risk due to LDV (100,000+ POP records per save file).
- **Dependencies**: `FEAT-01`, `SaveImportBatch` infrastructure.
- **Asset Reuse**: Requires `EconomyImportBatch` chunking pattern (scope size 200).

### Rank 11: `FEAT-03` — Macro Economy & Parameter Ledger
- **Effort**: `S` | **Value**: `MEDIUM` | **Risk**: `LOW`
- **Rationale**: Parameter inspector for overseas penalties, budget balance history, and unit costs.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Reuses `EconomyCalculationEngine`.

### Rank 12: `FEAT-09` — Diplomatic Network & Treaty Explorer
- **Effort**: `S` | **Value**: `MEDIUM` | **Risk**: `LOW`
- **Rationale**: Network view showing alliances, puppet/vassal relationships, and casus belli expiration dates.
- **Dependencies**: `FEAT-05`.
- **Asset Reuse**: Reuses `CountrySelector`.

### Rank 13: `FEAT-07` — AI Strategic Threat & Relationship Matrix
- **Effort**: `M` | **Value**: `MEDIUM` | **Risk**: `LOW`
- **Rationale**: AI strategy view exposing rivalries, antagonisms, befriending targets, and threat perceptions.
- **Dependencies**: `FEAT-05`, `FEAT-09`.
- **Asset Reuse**: Requires new matrix LWC.

### Rank 14: `FEAT-11` — Battle History & War Loss Timeline
- **Effort**: `M` | **Value**: `MEDIUM` | **Risk**: `LOW`
- **Rationale**: Historical battle timeline logging past engagements, commander traits, and cumulative casualties.
- **Dependencies**: `FEAT-10`.
- **Asset Reuse**: Extends `c-multi-save-trend`.

### Rank 15: `FEAT-16` — State Industrial & Construction Inspector
- **Effort**: `M` | **Value**: `MEDIUM` | **Risk**: `LOW`
- **Rationale**: Detailed state inspector tracking state buildings, construction progress, factory stockpiles, and profit histories.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Extends `c-state-dashboard` and `c-factory-dashboard`.

### Rank 16: `FEAT-13` — In-Game Newspaper Reader
- **Effort**: `S` | **Value**: `LOW` | **Risk**: `LOW`
- **Rationale**: Low-priority flavor feature rendering generated in-game newspaper headlines and articles.
- **Dependencies**: `FEAT-01`.
- **Asset Reuse**: Simple LWC card component.

---

## 5. Dependency Graph

```
[Phase 0: Data Model Remediation]
              |
              v
[FEAT-01: Save Header & Settings]
   |          |             |              |             |
   |          v             v              v             v
   |     [FEAT-05: Pol] [FEAT-06: Mil] [FEAT-02: Mkt] [FEAT-12: Reb]
   |          |             |
   |     +----+----+        v
   |     |         |    [FEAT-10: Active War]
   |     v         v        |
   |  [FEAT-08] [FEAT-09]   v
   |     |         |    [FEAT-11: Battles]
   |     v         v
   |  [FEAT-14] [FEAT-07]
   |
   +---------------------------------------+
   |                  |                    |
   v                  v                    v
[FEAT-03: Macro]  [FEAT-15: Compare]  [FEAT-16: State]
                      ^
                      |
[FEAT-04: POP Demographics (Requires SaveImportBatch LDV)]
```

---

## 6. Foundational Infrastructure Required

Before building feature ranks 2–16, the following Apex and LWC infrastructure modules must be created:

1. **`SaveImportBatch.cls`**: Batchable Apex class capable of chunking 100,000+ record save payloads into 200-record sub-transactions to avoid Governor Heap and DML limits.
2. **`SaveAnalysisController.cls`**: Facade controller managing `@AuraEnabled(cacheable=true)` data retrieval across political, military, and diplomatic selectors.
3. **`SaveCountrySelector.cls`**: Extended SOQL selector retrieving `Country_Save_State__c` fields alongside political and military child records.
4. **`c-save-game-analyzer-shell`**: Multi-tab LWC workspace wrapper expanding the current shell to host Politics, Military, War, POPs, and Diplomacy tabs.

---

## 7. Do Not Build List (Explicitly Excluded Features)

The following features were evaluated and **rejected** from the roadmap due to disproportionate effort, extreme platform limit risks, or poor user value:

1. **Direct In-Memory Save File Editor / Writer**:
   - *Rationale*: Modifying Victoria 2 binary/text save files inside Salesforce is outside the scope of an analytical engine and introduces severe corruption risks to original game saves.
2. **Real-Time Animated Combat / Particle Visualizer**:
   - *Rationale*: Rendering 3D unit movements and tactical combat animations in LWC consumes excessive DOM memory without providing analytical value beyond stat summary tables.
3. **Raw POP Micro-Management Workspace**:
   - *Rationale*: Exposing raw, non-aggregated editing tables for 100,000+ individual `Pop__c` records will cause browser DOM freeze and exceed Salesforce heap/SOQL row limits. All POP data must be consumed via aggregated rollups.
4. **Full Paradox Scripting Parser in Pure Apex**:
   - *Rationale*: Parsing 50MB raw text save files inside Apex triggers String/Heap limits (6MB sync / 12MB async). Save file parsing MUST remain in Python (`Save_Game_Analyzer`) and be ingested via REST DTO payloads.

---

## 8. Open Questions for Project Owner

1. **Ingestion Scope**: Should future save ingestion import the full 136-object payload in a single REST payload or use asynchronous domain-chunked uploads?
2. **POP Data Retention Policy**: Should micro-level `Pop__c` records be purged after calculating country/province aggregations to conserve Salesforce data storage?
3. **Multi-Save Cap**: Is the 12-snapshot cap enforced in the economy track sufficient for multi-save time series analysis across political and military metrics?
