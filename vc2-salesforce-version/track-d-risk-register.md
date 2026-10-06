# Track D — Extended Risk Register & Evaluation

## 1. Executive Summary

This document re-evaluates all 8 initial technical risks identified in Track C (`RSK-01` through `RSK-08`) and incorporates 10 new advanced capability and platform risks (`RSK-09` through `RSK-18`) introduced by Track D's Layer 2, Layer 3, and Layer 4 capabilities.

---

## 2. Re-evaluated Track C Risks (RSK-01 to RSK-08)

| Risk ID | Risk Title | Category | Track C Level | Track D Level | Re-evaluation & Mitigation Strategy |
|---|---|---|---|---|---|
| `RSK-01` | **Metadata Deployment Defects** | Data Model | **CRITICAL** | **LOW (Resolved)** | Fixed in Track E (58/58 defects remediated; 136 objects verified deployable). |
| `RSK-02` | **POP Record SOQL/Heap Limit Breach** | Governor Limits | **HIGH** | **HIGH** | 100k+ `Pop__c` records per save. Mitigation: Enforce batch chunking (`SaveImportBatch`, scope=200) and query pre-aggregated rollups. |
| `RSK-03` | **Multi-Save Time Series CPU Limit** | Governor Limits | **MEDIUM** | **MEDIUM** | Enforced 12-snapshot hard cap in Apex controller with `@cacheable(true)`. |
| `RSK-04` | **Raw Text Save File Parsing Heap Limit** | Ingestion | **HIGH** | **HIGH** | Pure Apex parsing disabled. Parsing remains strictly in Python / external DTO generator. |
| `RSK-05` | **Field-Level Security & Permission Gaps** | Security | **MEDIUM** | **LOW (Resolved)** | Solved via auto-generated `Economy_Analyzer_User` and `Economy_Analyzer_Admin` permission sets. |
| `RSK-06` | **271/116 Direct Country Lookups Limit** | Data Model | **CRITICAL** | **LOW (Resolved)** | Solved in Track B/E by converting to `Save_Game_Country_Ref__c` and `Country_Country_Ref__c` junction objects. |
| `RSK-07` | **LWC DOM Re-render Degradation** | Frontend | **MEDIUM** | **MEDIUM** | Use Virtual Scrolling / Pagination for large tables (factories, provinces, military OOB). |
| `RSK-08` | **Protected Economy Object Integrity Failure** | Architecture | **CRITICAL** | **LOW (Verified)** | Hash `976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38` verified bit-for-bit unchanged. |

---

## 3. New Track D Capabilities & Platform Risks (RSK-09 to RSK-18)

| Risk ID | Risk Title | Category | Severity | Probability | Risk Level | Mitigation Strategy |
|---|---|---|---|---|---|---|
| `RSK-09` | **ML Model Training Data Availability** | Einstein Discovery | High | Medium | **MEDIUM** | Einstein Discovery requires $\ge 10,000$ historical rows for accurate ML training. Mitigation: Use synthetic historical dataset or fallback to deterministic formula scoring (`MET-D-015`). |
| `RSK-10` | **Agentforce / GPT Hallucination Risk** | AI / Agentforce | High | High | **HIGH** | Agentforce LLMs may hallucinate exact treasury or brigade numbers. Mitigation: Enforce strict Grounding Prompt Templates mapping to `SaveAnalysisController` Apex DTO outputs. |
| `RSK-11` | **Data Cloud License & Storage Cost Scale** | Data Cloud | Medium | High | **HIGH** | Storing millions of cross-campaign POP records in Data Cloud introduces high license costs. Mitigation: Enforce 5-campaign retention policy for inactive players. |
| `RSK-12` | **External Object Sync Latency** | Integration | Medium | Medium | **MEDIUM** | Querying cross-save archives via OData External Objects causes LWC UI spinner lag. Mitigation: Implement client-side caching in LWC and Apex memory cache. |
| `RSK-13` | **Slack Workspace Governance & Notification Spam** | Integration | Low | High | **MEDIUM** | High-frequency Platform Events (e.g. daily combat updates) spam Slack channels. Mitigation: Limit Slack posts strictly to major milestones (Great Wars, Crisis, Empire Formations). |
| `RSK-14` | **Public Experience Cloud Data Leakage** | Security | High | Low | **MEDIUM** | Public campaign sharing portal exposes unindexed save file metadata. Mitigation: Enforce strict Guest User Security Policies and read-only DTO views. |
| `RSK-15` | **Cross-Save Player Privacy & PII Leakage** | Security | Medium | Low | **LOW** | Player Steam usernames or custom save notes stored in `Player__c`. Mitigation: Anonymize or hash player tags upon ingest if public sharing is enabled. |
| `RSK-16` | **Mobile Push Notification Rate Limits** | Mobile | Low | Medium | **LOW** | Exceeding daily mobile push notification governor limits during batch ingestion testing. Mitigation: Consolidate push alerts to single batch completion event. |
| `RSK-17` | **Formula Field Compile Size Limit Breach** | Salesforce Limits | Medium | Medium | **MEDIUM** | Deep Layer 3 metrics (`MET-D-001`, `MET-D-003`) exceed 5,000 character formula compile size limits. Mitigation: Compute complex derived metrics inside pure Apex (`EconomyCalculationEngine.cls`) rather than custom formula fields. |
| `RSK-18` | **Platform Event High-Volume Daily Quota Exhaustion** | Integration | Medium | Low | **LOW** | Publishing events on every minor price change exhausts daily event allocation. Mitigation: Publish events only when anomaly delta exceeds threshold ($\ge 20\%$). |
