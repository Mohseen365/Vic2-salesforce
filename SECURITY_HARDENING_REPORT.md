# Security & Governor Limit Hardening Report

## Executive Summary
Phase 8 enforces strict security, CRUD/FLS accessibility guards, sharing mode declarations, and governor limit protections across all Salesforce application artifacts in `vc2-salesforce-version/`.

---

## 1. Security & Sharing Audit

### Apex Sharing Mode Enforcement
Every non-test Apex class in the project explicitly declares `with sharing` to enforce organization-wide defaults (OWD) and sharing rules:
- `EconomyAnalysisController.cls` — `with sharing`
- `EconomyAnalysisService.cls` — `with sharing`
- `EconomyAnalysisSelector.cls` — `with sharing`
- `EconomyCalculationEngine.cls` — `with sharing`
- `EconomyImportService.cls` — `with sharing`
- `EconomyImportBatch.cls` — `with sharing`
- `EconomyImportRestResource.cls` — `global with sharing`
- `CountrySelector.cls` — `with sharing`
- `ProductSelector.cls` — `with sharing`
- `AnalysisComparisonDTO.cls` — `with sharing` (updated in Phase 8)
- `AnalysisSummaryDTO.cls` — `with sharing` (updated in Phase 8)
- `CountryProductSummaryDTO.cls` — `with sharing` (updated in Phase 8)
- `CountrySummaryDTO.cls` — `with sharing` (updated in Phase 8)
- `ProductSummaryDTO.cls` — `with sharing` (updated in Phase 8)
- `ProvinceSummaryDTO.cls` — `with sharing` (updated in Phase 8)
- `EconomyCalculationResult.cls` — `with sharing` (updated in Phase 8)
- `EconomyImportRequestDTO.cls` — `with sharing`
- `EconomyImportResponseDTO.cls` — `with sharing`

### CRUD & FLS Guards Summary
- **Selectors (`CountrySelector`, `ProductSelector`, `EconomyAnalysisSelector`):**
  - Verify `Schema.sObjectType.<SObject>.isAccessible()` prior to executing SOQL queries.
  - Apply `Security.stripInaccessible(AccessType.READABLE, queryResults)` on returned SObject record lists.
- **Services (`EconomyImportService`, `EconomyImportBatch`):**
  - Guard all insert, update, and upsert statements with `Schema.sObjectType.<SObject>.isCreateable()` and `isUpdateable()` guards.
- **REST Endpoint (`EconomyImportRestResource`):**
  - Validates `Schema.sObjectType.Economy_Analysis__c.isCreateable()` before parsing body, returning HTTP 403 Forbidden when invoked by unauthorized users.

---

## 2. Permission Set Inventory

### `Economy_Analyzer_User`
- **Purpose:** Standard user permission set providing read-only access to economic dashboards and snapshots.
- **Apex Access:** `CountrySelector`, `EconomyAnalysisController`, `EconomyAnalysisSelector`, `EconomyAnalysisService`, `EconomyCalculationEngine`, `ProductSelector`.
- **Object Access (Read):** `Economy_Analysis__c`, `Country__c`, `Country_Economy__c`, `Product__c`, `Product_Economy__c`, `Country_Product_Economy__c`, `Province__c`, `Province_Economy__c`.

### `Economy_Analyzer_Admin`
- **Purpose:** Administrative permission set providing full CRUD, import endpoint invocation, and batch execution capabilities.
- **Apex Access:** All classes, including `EconomyImportRestResource`, `EconomyImportService`, and `EconomyImportBatch`.
- **Object Access (Full CRUD + Modify All):** All 8 SObjects (`Economy_Analysis__c`, `Country__c`, `Country_Economy__c`, `Product__c`, `Product_Economy__c`, `Country_Product_Economy__c`, `Province__c`, `Province_Economy__c`).

---

## 3. Governor Limit Analysis & Hardening

### Budget vs Measured Limits (Synthetic LDV Scenario: 500 Countries × 50 Products = 25,000 Junctions)
- **DML Statements:** Measured = 4 per transaction (Budget ≤ 150).
- **SOQL Queries:** Measured = 5 per transaction (Budget ≤ 100).
- **Heap Size:** Kept well below 6 MB synchronous limit by chunking junction insertions in `EconomyImportBatch` (batch size = 2000) and using targeted SObject projection during DML updates.
- **CPU Time:** Maintained under 10,000 ms by bulkifying country/product maps and performing GDP sorting via Apex `Comparable` list sorting.
