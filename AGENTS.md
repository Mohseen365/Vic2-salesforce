# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 5 (LWC Country Dashboard) is **VERIFIED AND COMPLETE**.
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

## Phase 5 Delivered LWC Component Inventory

1. **`c-economy-analyzer-shell` (`economyAnalyzerShell`)**:
   - Root application container mapping `WindowController`.
   - Analysis switcher `lightning-combobox` populated via `@wire(getRecentAnalyses)`.
   - Tabset hosting Global Overview, Country Explorer (`c-country-dashboard`), Product Market, and Compare Saves tabs.
   - Propagates `selectedAnalysisId` down to child header and country dashboard components.

2. **`c-economy-analysis-header` (`economyAnalysisHeader`)**:
   - Application header banner mapping `Main`.
   - `@wire(getAnalysisSummary, { analysisId: '$analysisId' })` displaying `AnalysisSummaryDTO` metrics.
   - KPI tiles: Total World GDP, Global Population, World Imports, World Exports.
   - Status badge reflecting `Import_Status__c` (`COMPLETED`, `PROCESSING`, `CALCULATING`, `RECEIVED`, `FAILED`).
   - Renders diagnostic message banner on `FAILED` status and pending recalculation warning with manual refresh button (`refreshApex`).

3. **`c-country-dashboard` (`countryDashboard`)**:
   - Country explorer dashboard mapping `CountryController`.
   - `@wire(getCountrySummaries, { analysisId: '$analysisId' })` populating country selection combobox with auto-selection.
   - KPI cards for GDP, GDP Rank, GDP Per Capita, Population, Workforce, Employment, Unemployment Rate, Imports, Exports, Gold Income.
   - `@wire(getCountryProductSummaries, { countryEconomyId: '$selectedCountryEconomyId' })` driving `lightning-datatable` trade breakdown.
   - Commodity search filter input dynamically filtering datatable rows.

4. **`EconomyAnalysisController.cls` (Apex Facade)**:
   - `@AuraEnabled(cacheable=true)` facade layer exposing cached read operations with 100% test coverage.
   - `getRecentAnalyses(limitCount)`, `getAnalysisSummary(analysisId)`, `getCountrySummaries(analysisId)`, `getCountrySummary(analysisId, countryEconomyId)`, `getCountryProductSummaries(countryEconomyId)`.

---

## Engine & Import Pipeline API Surface

- **`EconomyImportRestResource.cls`**:
  - `POST /services/apexrest/economy/import` → Ingests `EconomyImportRequestDTO` and returns `EconomyImportResponseDTO`.
- **`EconomyImportService.cls`**:
  - `public static EconomyImportResponseDTO processImport(EconomyImportRequestDTO request)`
  - `public static EconomyImportResponseDTO processImport(EconomyImportRequestDTO request, Boolean forceBatch)`
- **`EconomyImportBatch.cls`**:
  - `Database.Batchable<sObject>` chunking framework for large snapshots exceeding 2,000 child records.
- **`EconomyAnalysisController.cls`**:
  - Facade controller for LWC `@wire` adapters.
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

## Rules for Phase 6 (LWC Product & Market Dashboard)

- Extend `@AuraEnabled(cacheable=true)` facade methods in `EconomyAnalysisController.cls` for product endpoints (`getProductSummaries`, `getProductSummary`).
- Reuse established LWC patterns: `@wire` adapters, SLDS KPI cards, `lightning-datatable` search filtering, and `registerApexTestWireAdapter` in Jest tests.
- All selectors and controllers enforce `with sharing` and `Security.stripInaccessible`.
