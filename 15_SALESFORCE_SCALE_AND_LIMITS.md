# 15. Salesforce Scale, Performance, and Governor Limits Analysis

## Overview
This document analyzes system scalability across 1, 10, 100, and 1,000 uploaded save games and details governor limit safeguards.

---

## Record Volume Projections

| Object | Records per 1 Save | Records per 10 Saves | Records per 100 Saves | Records per 1,000 Saves | Storage at 1,000 Saves (2KB/rec) |
| ------ | ------------------ | -------------------- | --------------------- | ----------------------- | -------------------------------- |
| `Economy_Analysis__c` | 1 | 10 | 100 | 1,000 | 2 MB |
| `Country_Economy__c` | ~220 | 2,200 | 22,000 | 220,000 | 440 MB |
| `Product_Economy__c` | ~49 | 490 | 4,900 | 49,000 | 98 MB |
| `Country_Product_Economy__c` | ~10,000 | 100,000 | 1,000,000 | 10,000,000 | 20 GB |
| `Factory_Economy__c` | ~700 | 7,000 | 70,000 | 700,000 | 1.4 GB |
| `Artisan_Economy__c` | ~4,400 | 44,000 | 440,000 | 4,400,000 | 8.8 GB |

---

## Governor Limit Safeguards Architecture

1. **Async Queue Threshold (GATE-3):** When factory or artisan counts exceed 200 records, persistence shifts to `EconomyImportBatch.cls` with scope size = 200 to guarantee DML statement and heap size limits are never breached.
2. **Indexed External IDs:** All child snapshot records enforce `Unique_Snapshot_Key__c` marked as Indexed External ID for fast bulk upserts and SOQL filtering.
3. **SOQL Projection Optimization:** Selector queries in `EconomyAnalysisSelector.cls` restrict selected fields to specific UI components, avoiding `SELECT *` patterns.
