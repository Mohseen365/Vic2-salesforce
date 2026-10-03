# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 4 (Import & Integration Pipeline) is **VERIFIED AND COMPLETE**.
- **Golden Dataset Reference Location:** `vc2-salesforce-version/golden-dataset/`
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)

---

## Verified Golden Dataset Metrics & Record Counts

- **Countries:** 118
- **Provinces:** 3,248
- **Products:** 49
- **Product Storages (Country × Product Junctions):** 3,772
- **Derived Calculation Records:** 3,940
- **Validation Status:** PASS (Integrity and byte-for-byte output determinism verified)

---

## Resolved Architecture Gates & Formulas

1. **Product Overproduction Formula:**
   - Authoritative Formula: `(Total_World_Supply__c / Real_Demand__c) * 100` (when `Real_Demand__c > 0`, else `0.0`).
   - Source Method: `Product.getOverproduced()`

2. **GDP Contribution & Country GDP Formula:**
   - Authoritative Formula: `sold_units = soldDomestic + thrownToMarket * actualSoldWorld / worldmarketPool`.
   - `ProductStorage GDP (£) = max(sold_units - intermediate_consumption, 0) * product.price`.
   - `Country Total GDP (£) = sum(ProductStorage.getGdpPounds()) + goldIncome`.
   - Source Methods: `ProductStorage.innerCalculations()`, `Country.innerCalculations()`

3. **Parser Architecture & Import Endpoint:**
   - Authoritative Endpoint: `POST /services/apexrest/economy/import` (`EconomyImportRestResource.cls`).
   - Architecture: Option A (External Off-Heap EUG Parser Service transmitting normalized JSON DTOs to Salesforce REST endpoint `EconomyImportService`).
   - Status Lifecycle: `RECEIVED` → `PROCESSING` → `CALCULATING` → `COMPLETED` (or `FAILED` with `Import_Diagnostic_Message__c`).
   - Master Data Resolution: Dynamic creation of unknown master `Country__c`, `Product__c`, and `Province__c` records during import per Audit Section Q.

---

## Engine & Import Pipeline API Surface

- **`EconomyImportRestResource.cls`**:
  - `POST /services/apexrest/economy/import` → Ingests `EconomyImportRequestDTO` and returns `EconomyImportResponseDTO`.
- **`EconomyImportService.cls`**:
  - `public static EconomyImportResponseDTO processImport(EconomyImportRequestDTO request)`
  - `public static EconomyImportResponseDTO processImport(EconomyImportRequestDTO request, Boolean forceBatch)`
- **`EconomyImportBatch.cls`**:
  - `Database.Batchable<sObject>` chunking framework for large snapshots exceeding 2,000 child records.
- **`EconomyAnalysisService.cls`**:
  - `public static void recalculateAnalysis(Id analysisId)`
  - `public static AnalysisSummaryDTO getAnalysisSummary(Id analysisId)`
  - `public static CountrySummaryDTO getCountrySummary(Id analysisId, Id countryEconomyId)`
  - `public static List<CountrySummaryDTO> getCountrySummaries(Id analysisId)`
  - `public static ProductSummaryDTO getProductSummary(Id analysisId, Id productEconomyId)`
  - `public static List<ProductSummaryDTO> getProductSummaries(Id analysisId)`
  - `public static List<CountryProductSummaryDTO> getCountryProductSummaries(Id countryEconomyId)`
  - `public static AnalysisComparisonDTO compareAnalyses(Id baseAnalysisId, Id compareAnalysisId)`

---

## Confirmed Legacy Quirks & Engine Implementation Details

1. **GDP Per Capita Scaling Multiplier (`100,000`):** Preserved in Phase 1 Formula Field `Country_Economy__c.GDP_Per_Capita__c`.
2. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `Gold_Income__c` and added directly to country GDP; `precious_metal` product skips world market exports (`Export_Value__c = 0.0`).
3. **World Market Allocation Order:** Engine reads stored post-hoc quantities (`Sold_Domestic__c`, `Thrown_To_Market__c`, `Actual_Sold_World__c`, `Worldmarket_Pool__c`) without simulation.
4. **Ranking Tie-Breaker:** GDP sorting is deterministic: primary sort `GDP__c` descending, tie-breaker `Country_Tag__c` ascending.
5. **Idempotency Strategy:** Single-pass upserts on `Unique_Snapshot_Key__c` across analysis headers and child snapshot objects prevent duplicate records on re-import.

---

## Rules for Phase 5 (LWC Country Dashboard)

- UI components consume DTOs returned by `EconomyAnalysisService` / `@AuraEnabled` controllers (`AnalysisSummaryDTO`, `CountrySummaryDTO`, `CountryProductSummaryDTO`).
- Reflect import status (`Import_Status__c`) in UI header/status notifications.
- All selectors enforce `with sharing` and `Security.stripInaccessible`.
