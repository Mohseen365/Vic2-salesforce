# 16. Save Game Import Architecture and Ingestion Pipeline

## Overview
This document specifies the end-to-end import pipeline for ingesting Victoria 2 `.v2` save game files into Salesforce via REST API, off-heap parsing, and batch persistence.

---

## Ingestion Architecture Pipeline Diagram

```text
[HTTP POST /services/apexrest/economy/import]
       │
       ▼
[EconomyImportRestResource.cls] ──> Validate Header & DTO Version (1.0.0)
       │
       ▼
[EconomyImportService.cls]
       ├── 1. Upsert Analysis Header (Economy_Analysis__c)
       ├── 2. Upsert Master Entities (Country__c, Product__c, State__c, Province__c)
       ├── 3. Upsert Core Country & Product Snapshots
       ├── 4. Invoke Domain Engine (EconomyCalculationEngine.cls)
       └── 5. Dispatch Child Factory & Artisan Snapshots
                 ├── If records <= 200: Synchronous Persistence
                 └── If records > 200: Enqueue EconomyImportBatch.cls (Scope 200)
       │
       ▼
[Economy_Import_Event__e] ──> Real-time status streamed to LWC watcher via EMP API
```

---

## Lifecycle State Machine
`RECEIVED` → `PROCESSING` → `CALCULATING` → `COMPLETED` (or `FAILED`)
- **`RECEIVED`**: Import request received, header created.
- **`PROCESSING`**: Master reference data auto-provisioned and core snapshot records upserted.
- **`CALCULATING`**: Engine calculates world trade totals, country GDP ranks, and per-capita metrics.
- **`COMPLETED`**: All child factory/artisan records persisted and final diagnostic messages written.
- **`FAILED`**: Exception caught, transaction rolled back safely, failure diagnostic saved.
