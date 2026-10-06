# Victoria 2 Save-Game Salesforce Application — Master Consolidated Planning Document

---

## 1. Executive Summary & Project Context

This document serves as the **Master Consolidated Planning Document** for the Victoria 2 Save-Game Salesforce application. It supersedes and unifies all previous possibility maps, capability expansions, risk registers, roadmaps, asset inventories, formula references, field inventories, and architectural guidelines from Tracks A, B, C, D, and E.

### 1.1 Core Objectives
- **Fidelity & Parity**: Maintain 100% mathematical and behavioral parity with the legacy Java application (`vic2_economy_analyzer`) for economic calculations, while expanding analytical depth to the full Clausewitz save-game structure.
- **Enterprise Salesforce Architecture**: Leverage enterprise-grade Salesforce features (LWC, Apex Batch, Platform Events, Data Cloud, Agentforce) while strictly respecting governor limits and data model integrity.
- **Comprehensive Capability Scope**: Enumerate **265 capabilities** across 4 architecture layers and **22 consolidated features** (`FEAT-01` through `FEAT-22`).

### 1.2 Baseline Verification & Asset State
- **Golden Dataset**: `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`).
- **Protected Economy Artifacts Integrity**: The 13 protected economy objects and their core engine (`EconomyCalculationEngine.cls`) are verified bit-for-bit unchanged. Deterministic SHA-256 baseline hash: `976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38`.
- **Data Model Scope**: **139 Custom Objects** delivered (13 protected economy artifacts + 126 save entities and junction objects like `Save_Game_Country_Ref__c` and `Country_Country_Ref__c`).
- **Single-User Operating Context**: System Administrator with `View All Data` and `Modify All Data`. Permission sets (`Economy_Analyzer_User`, `Economy_Analyzer_Admin`) provisioned for auditability and future role extension.

---

## 2. Authoritative Formula Reference & Architecture Gates (Phase 0)

Where discrepancies exist between legacy Java implementations and preliminary documentation, the **legacy Java source code is authoritative**.

### 2.1 Authoritative Resolution of Architecture Gates
- **Gate 1 (Overproduction Formula):**
  - Legacy Java (`Product.java`): `supply / demand * 100`.
  - Salesforce Target: `(Total_World_Supply__c / Real_Demand__c) * 100` when `Real_Demand__c > 0`; otherwise `0.0`.
- **Gate 2 (GDP Contribution & Country GDP):**
  - Product GDP (pieces) = `max(sold_units - intermediate_consumption_units, 0)`.
  - Product GDP (£) = `product_gdp_units * product.price`.
  - Country Total GDP (£) = `sum(ProductStorage.getGdpPounds()) + goldIncome`.
  - `goldIncome` = direct treasury revenue from precious metal RGOs (`last_income / 1000`).
- **Gate 3 (Parser Architecture):**
  - 15MB–120MB `.v2` files cannot be parsed natively in Apex due to governor limits. 
  - **Option A (Mandatory)**: Off-heap external Python EUG parser extracts normalized DTO payloads and POSTs structured JSON payloads to the Salesforce REST endpoint (`POST /services/apexrest/economy/import`).

### 2.2 Comprehensive Formula & Calculation Matrix
| Entity | Field / Metric | Legacy Formula / Logic | Division-by-Zero Safeguard | Salesforce Execution Location |
| :--- | :--- | :--- | :--- | :--- |
| **Product** | Inflation % | `(price / basePrice) * 100` | `basePrice == 0` -> `0.0` | Formula Field (`Product_Economy__c`) |
| **Product** | Overproduction % | `(supply / demand) * 100` | `demand == 0` -> `0.0` | Apex Service / Formula |
| **Country** | Population | `sum(popSize * 4)` | None | Apex Service Engine |
| **Country** | Workforce RGO | `sum(popSize)` for `farmers, labourers, slaves, serfs` | None | Apex Service Engine |
| **Country** | Workforce Factory | `sum(popSize)` for `craftsmen, clerks` | None | Apex Service Engine |
| **Country** | Unemployment Rate RGO % | `((workforceRGO - employmentRGO) / workforceRGO) * 100` | `workforceRGO == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
| **Country** | Unemployment Rate Factory % | `((workforceFactory - employmentFactory) / workforceFactory) * 100` | `workforceFactory == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
| **Country** | GDP per Capita (£/100k) | `(gdp / population) * 100000` | `population == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
| **Country** | GDP Share % | `(gdp / totalCountry.gdp) * 100` | `totalCountry.gdp == 0` -> `0.0` | Apex Service / Formula |
| **ProductStorage** | GDP (£) | `max(sold - intermediateConsumption, 0) * product.price` | None | Apex Service Engine |

---

## 3. Master Capability Index (265 Capabilities across 4 Layers)

The application integrates **265 enumerated capabilities**:

### 3.1 Layer 1: Single-Domain Display (`CAP-001` to `CAP-125`)
Baseline Track C single-domain display capabilities mapped to features `FEAT-01` through `FEAT-16`:
- `CAP-001` – `CAP-008`: Save Envelope (`FEAT-01`)
- `CAP-009` – `CAP-018`: World Market Visualizer (`FEAT-02`)
- `CAP-019` – `CAP-028`: Economy Parameters / Macro Ledger (`FEAT-03`)
- `CAP-029` – `CAP-042`: Province & POP Demographics (`FEAT-04`)
- `CAP-043` – `CAP-058`: Country Politics & Reforms (`FEAT-05`)
- `CAP-059` – `CAP-070`: Military Order of Battle (`FEAT-06`)
- `CAP-071` – `CAP-079`: AI Strategy Matrix (`FEAT-07`)
- `CAP-080` – `CAP-091`: Trade & Influence / Sphere & Focus (`FEAT-08`)
- `CAP-092` – `CAP-098`: Diplomacy Network (`FEAT-09`)
- `CAP-099` – `CAP-108`: Active War & Combat / Battles (`FEAT-10` / `FEAT-11`)
- `CAP-109` – `CAP-118`: Rebels / News / Colonies (`FEAT-12` / `FEAT-13` / `FEAT-14`)
- `CAP-119` – `CAP-125`: Multi-Save Compare / State Inspector (`FEAT-15` / `FEAT-16`)

### 3.2 Layer 2: Cross-Domain Analytics (`CAP-D-001` to `CAP-D-065`)
65 cross-domain analytical interactions (`FEAT-17` Cross-Domain Macro Engine):
- `CAP-D-001` – `CAP-D-005`: Economy × Politics (Tax impact, reform industrial efficiency, party economic policy, tariff elasticity, debt radicalism)
- `CAP-D-006` – `CAP-D-010`: Economy × Military (Maintenance ratio, mobilization sustainability, good competition, occupation damage, cost efficiency)
- `CAP-D-011` – `CAP-D-015`: Economy × POP (Literacy productivity, wealth inequality, social mobility, unemployment deprivation, artisan/factory competition)
- `CAP-D-016` – `CAP-D-020`: Economy × War (GDP war decline, blockade impact, war exhaustion fiscal engine, war good price spikes, reconstruction cost)
- `CAP-D-021` – `CAP-D-025`: Economy × Diplomacy (Sphere market capture, foreign investment influence, trade dependency, diplomatic isolation, customs union tariff loss)
- `CAP-D-026` – `CAP-D-030`: Economy × Colonial (Colonial ROI, resource supply chain, colonial migration push, naval cost efficiency, luxury access)
- `CAP-D-031` – `CAP-D-035`: POP × War (Casualty pop depletion, occupation militancy, war ideology shift, veteran rebellion risk, blockade pop deprivation)
- `CAP-D-036` – `CAP-D-040`: POP × Ideology (Literacy ideology correlation, consciousness reform demand, strata fascism growth, religious militancy, military pay drift)
- `CAP-D-041` – `CAP-D-045`: POP × Politics (Upper House alignment, movement legislative force, enfranchisement electoral shift, press freedom militancy, voting power index)
- `CAP-D-046` – `CAP-D-050`: Military × Diplomacy (Access alliance precursor, coalition brigade power balance, military deterrence, naval power projection, border deployment threat)
- `CAP-D-051` – `CAP-D-055`: Military × AI (AI personality military composition, army movement target correlation, threat mobilization trigger, naval focus analyzer, casualty recruitment response)
- `CAP-D-056` – `CAP-D-060`: Diplomacy × War (Call-to-arms honor rate, war goal penalty, casus belli utilization, truce expiration war trigger, coalition expansion rate)
- `CAP-D-061` – `CAP-D-062`: Tech × Eco × Military (Tech military cost multiplier, tech industrial output bonus)
- `CAP-D-063` – `CAP-D-064`: Culture × Politics × War (Cultural war rebellion risk, cultural assimilation rate)
- `CAP-D-065`: Influence × Colony × POP (Sphere colonial migration suppressor)

### 3.3 Layer 3: Derived Intelligence Metrics (`MET-D-001` to `MET-D-045`)
45 computed metrics, forecasts, and anomaly indicators (`FEAT-18` Derived Metric Suite):
- `MET-D-001` – `MET-D-008`: Composite Indices (HDI, IPS, MSC, CMI, CUS, NSI, GPS, FHR)
- `MET-D-009` – `MET-D-014`: Comparative Scores (GDP/cap benchmark, colonial efficiency ratio, tax efficiency, military intensity, influence-per-diplomat, RGO productivity)
- `MET-D-015` – `MET-D-021`: Forecasts & Predictions (Linear GDP trend, rebellion escalation probability, crisis escalation score, war outcome predictor, sovereign bankruptcy risk, population growth projection, tech research completion date)
- `MET-D-022` – `MET-D-026`: Network Metrics (Diplomatic centrality index, sphere density, trade network betweenness, alliance cluster coefficient, casus belli centrality)
- `MET-D-027` – `MET-D-031`: Anomaly Indicators (Factory productivity outlier, tech/eco mismatch, abnormal demoted POP spike, unusual price volatility, rebel militancy surge alert)
- `MET-D-032` – `MET-D-036`: Efficiency Metrics (Factory capacity utilization, RGO output yield, tax collection efficiency, war-cost per enemy brigade loss, colonial ROI ratio)
- `MET-D-037` – `MET-D-040`: Narrative Generators (Decade history chapter summary, industrial revolution milestone, empire peak turning point, Great War narrative summary)
- `MET-D-041` – `MET-D-045`: Risk Scores (National rebellion risk index, sovereign insolvency risk, diplomatic isolation vulnerability, strategic military resource vulnerability, refugee & emigration pressure)

### 3.4 Layer 4: Platform Extensions (`PLAT-D-001` to `PLAT-D-030`)
30 enterprise Salesforce integration and extension capabilities:
- `PLAT-D-001` – `PLAT-D-003`: Real-Time Events & Alerts (Import anomaly alerts, Great War outbreak notifications, sovereign default warning events)
- `PLAT-D-004` – `PLAT-D-005`: CRM Analytics / Einstein Discovery (GDP growth predictive model, rebellion risk machine learning model)
- `PLAT-D-006` – `PLAT-D-007`: Agentforce Conversational AI (Natural language campaign advisor, strategic AI target recommender)
- `PLAT-D-008` – `PLAT-D-009`: Data Cloud Historical Archive (Multi-campaign historical data warehouse, multiplayer tournament analytics hub)
- `PLAT-D-010` – `PLAT-D-011`: Salesforce Mobile Layouts & Push (Mobile save overview app, mobile push notifications on import complete)
- `PLAT-D-012` – `PLAT-D-013`: Slack Integration (Slack milestone channel posts, slash command campaign query `/v2-stats`)
- `PLAT-D-014` – `PLAT-D-015`: Experience Cloud (Community player dashboard sharing, public campaign comparison portal)
- `PLAT-D-016` – `PLAT-D-018`: Tableau CRM & Native Reports (Tableau interactive trade flow map, native Salesforce snapshot reports & executive dashboard)
- `PLAT-D-019` – `PLAT-D-030`: Platform Core & Advanced (Scheduled monthly campaign digest, file-connect `.v2` archival, serverless Salesforce Functions pre-processing, shield encryption, flow-driven custom metric alerts, bulk ingestion API 2.0, streaming API market live feed, Lightning Out embedded dashboard, multi-game platform unification, AWS S3 backup flow, Chatter campaign discussion feed)

---

## 4. Consolidated Feature Catalogue (22 Features)

| Feature ID | Feature Name | Domain Coverage | Layer Coverage | Effort | Value | Risk |
|---|---|---|---|---|---|---|
| `FEAT-01` | Save Header & Settings Bar | Save Envelope | Layer 1 | S | HIGH | LOW |
| `FEAT-02` | Market Visualizer | World Market | Layer 1 | M | HIGH | LOW |
| `FEAT-03` | Macro Parameter Ledger | Parameters | Layer 1 | S | MEDIUM | LOW |
| `FEAT-04` | POP Demographics Explorer | Province / POP | Layer 1 | XL | HIGH | HIGH |
| `FEAT-05` | Country Politics Dashboard | Politics | Layer 1 | M | HIGH | LOW |
| `FEAT-06` | Military OOB Explorer | Military | Layer 1 | M | HIGH | MEDIUM |
| `FEAT-07` | AI Strategy Matrix | AI | Layer 1 | M | MEDIUM | LOW |
| `FEAT-08` | Sphere & Focus Tracker | Influence / Trade | Layer 1 | M | HIGH | LOW |
| `FEAT-09` | Diplomatic Treaty Network | Diplomacy | Layer 1 | S | MEDIUM | LOW |
| `FEAT-10` | Active War Monitor | War | Layer 1 | L | HIGH | MEDIUM |
| `FEAT-11` | Battle History Timeline | War | Layer 1 | M | MEDIUM | LOW |
| `FEAT-12` | Rebel Monitor | Rebels / News | Layer 1 | S | HIGH | LOW |
| `FEAT-13` | Newspaper Reader | News | Layer 1 | S | LOW | LOW |
| `FEAT-14` | Crisis & Colonial Manager | Colonies | Layer 1 | M | HIGH | LOW |
| `FEAT-15` | Multi-Save Comparison Suite | All | Layer 1 | M | HIGH | MEDIUM |
| `FEAT-16` | State Industrial Inspector | State / Factory | Layer 1 | M | MEDIUM | LOW |
| `FEAT-17` | **Cross-Domain Macro Intelligence Engine** | Eco × Pol × Mil × Pop | Layer 2 | M | HIGH | MEDIUM |
| `FEAT-18` | **Derived Metric & Anomaly Suite** | All Domains | Layer 3 | M | HIGH | LOW |
| `FEAT-19` | **Real-Time Anomaly Alert Hub** | Integration / Platform | Layer 4 | S | HIGH | LOW |
| `FEAT-20` | **Agentforce Campaign Advisor** | AI / Platform | Layer 4 | L | HIGH | MEDIUM |
| `FEAT-21` | **Data Cloud Long-Term Archive** | Storage / Analytics | Layer 4 | XL | HIGH | HIGH |
| `FEAT-22` | **Experience Cloud Player Community** | External Community | Layer 4 | L | MEDIUM | LOW |

---

## 5. Existing Asset Inventory & Reusability Index

### 5.1 Key Apex Assets (41 Classes)
- **High Reusability**: `EconomyImportBatch.cls` (batch chunking for LDV POP records), `EconomyImportRestResource.cls` (REST API framework), `AnalysisComparisonDTO.cls` (universal delta comparison), `CountryTrendDTO.cls` (multi-snapshot time series container), `EconomyGovernorLimitTest.cls`, `EconomyLdvValidationTest.cls`.
- **Medium Reusability**: `EconomyCalculationEngine.cls` (pure engine pattern for derived calculations), `CountrySelector.cls`, `EconomyAnalysisController.cls` (facade pattern), `EconomyImportService.cls`.
- **Low Reusability**: Economy-specific selectors, domain services, and summary DTOs.

### 5.2 Key LWC Assets (15 Bundles)
- **High Reusability**: `c-economy-analyzer-shell` (repurposed as save game workspace shell), `c-economic-charts-container` (SVG-native universal chart renderer), `c-multi-save-trend` (time series chart), `c-analysis-compare` (delta comparison view), `c-economic-export-modal` & `c-economic-export-utils` (client-side CSV generation), `c-save-game-watcher-status` (empApi real-time progress monitor).

---

## 6. Comprehensive Risk Register (`RSK-01` to `RSK-18`)

| Risk ID | Risk Title | Category | Severity | Probability | Risk Level | Mitigation Strategy |
|---|---|---|---|---|---|---|
| `RSK-01` | **Metadata Deployment Defects** | Data Model | CRITICAL | Low | **LOW (Resolved)** | Remediated in Track E (58/58 defects fixed; 136 objects verified deployable). |
| `RSK-02` | **POP Record SOQL/Heap Limit Breach** | Governor Limits | High | High | **HIGH** | Enforce batch chunking (`SaveImportBatch`, scope=200) and query pre-aggregated rollups. |
| `RSK-03` | **Multi-Save Time Series CPU Limit** | Governor Limits | Medium | Medium | **MEDIUM** | Enforced 12-snapshot hard cap in Apex controller with `@cacheable(true)`. |
| `RSK-04` | **Raw Text Save File Parsing Heap Limit** | Ingestion | High | High | **HIGH** | Pure Apex parsing disabled. Parsing strictly in Python / external DTO generator. |
| `RSK-05` | **Field-Level Security & Permission Gaps** | Security | Medium | Low | **LOW (Resolved)** | Solved via auto-generated `Economy_Analyzer_User` and `Economy_Analyzer_Admin` permission sets. |
| `RSK-06` | **Direct Country Lookups Limit** | Data Model | CRITICAL | Low | **LOW (Resolved)** | Converted to `Save_Game_Country_Ref__c` and `Country_Country_Ref__c` junction objects. |
| `RSK-07` | **LWC DOM Re-render Degradation** | Frontend | Medium | Medium | **MEDIUM** | Use Virtual Scrolling / Pagination for large tables (factories, provinces, military OOB). |
| `RSK-08` | **Protected Economy Object Integrity Failure** | Architecture | CRITICAL | Low | **LOW (Verified)** | Hash `976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38` verified bit-for-bit unchanged. |
| `RSK-09` | **ML Model Training Data Availability** | Einstein Discovery | High | Medium | **MEDIUM** | Use synthetic historical dataset or fallback to deterministic formula scoring (`MET-D-015`). |
| `RSK-10` | **Agentforce / GPT Hallucination Risk** | AI / Agentforce | High | High | **HIGH** | Enforce strict Grounding Prompt Templates mapping to `SaveAnalysisController` Apex DTO outputs. |
| `RSK-11` | **Data Cloud License & Storage Cost Scale** | Data Cloud | Medium | High | **HIGH** | Enforce 5-campaign retention policy for inactive players. |
| `RSK-12` | **External Object Sync Latency** | Integration | Medium | Medium | **MEDIUM** | Implement client-side caching in LWC and Apex memory cache. |
| `RSK-13` | **Slack Workspace Governance & Notification Spam** | Integration | Low | High | **MEDIUM** | Limit Slack posts strictly to major milestones (Great Wars, Crisis, Empire Formations). |
| `RSK-14` | **Public Experience Cloud Data Leakage** | Security | High | Low | **MEDIUM** | Enforce strict Guest User Security Policies and read-only DTO views. |
| `RSK-15` | **Cross-Save Player Privacy & PII Leakage** | Security | Medium | Low | **LOW** | Anonymize or hash player tags upon ingest if public sharing is enabled. |
| `RSK-16` | **Mobile Push Notification Rate Limits** | Mobile | Low | Medium | **LOW** | Consolidate push alerts to single batch completion event. |
| `RSK-17` | **Formula Field Compile Size Limit Breach** | Salesforce Limits | Medium | Medium | **MEDIUM** | Compute complex derived metrics inside pure Apex rather than custom formula fields. |
| `RSK-18` | **Platform Event Daily Quota Exhaustion** | Integration | Medium | Low | **LOW** | Publish events only when anomaly delta exceeds threshold ($\ge 20\%$). |

---

## 7. Consolidated "Do Not Build" List

The following capabilities remain **strictly excluded** from execution:
1. **Direct In-Memory Save File Binary/Text Writer**: Severe corruption risk to original `.v2` game saves.
2. **Real-Time 3D Particle Combat Canvas**: Excessive browser DOM memory consumption without analytical value.
3. **Un-aggregated Raw POP Management Table**: Displaying 100,000+ individual `Pop__c` rows directly in LWC will crash browser rendering. All POP views must consume pre-aggregated DTO rollups.
4. **Pure Apex Regex Text Save Parser**: Parsing 50MB raw text files in Apex exceeds 12MB async heap limit. Parsing must remain in Python/Functions.
5. **Real-Time High-Frequency Multiplayer Synchronizer**: Victoria 2 is daily tick-based, not continuous streaming. Sub-second tick synchronization causes platform limit exhaustion.

---

## 8. Recommended Build Order & Next Steps

1. **Top 5 Priority Features**:
   - `FEAT-01`: Unified Save Game Header & Settings Bar
   - `FEAT-05`: Country Politics & Reform Dashboard
   - `FEAT-06`: Military Order of Battle (OOB) Explorer
   - `FEAT-17`: Cross-Domain Macro Intelligence Engine
   - `FEAT-08`: Sphere of Influence & Focus Tracker
2. **Execution Gate**: With metadata defects resolved in Track E and permission sets provisioned, development may proceed directly into Layer 1 UI workspace integration (`FEAT-01`) followed by Layer 2 Cross-Domain Analytics (`FEAT-17`).
