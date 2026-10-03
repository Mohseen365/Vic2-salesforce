# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 8 (Security, Hardening & Watcher Utility) is **VERIFIED AND COMPLETE**.
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

## Delivered Permission Sets & Platform Event Inventory (Phase 8)

1. **`Economy_Analyzer_User` Permission Set:**
   - Standard user read-only permission set.
   - Read access to all 8 custom snapshot and master SObjects.
   - Access to facade and selector Apex classes (`EconomyAnalysisController`, `EconomyAnalysisService`, `EconomyAnalysisSelector`, `CountrySelector`, `ProductSelector`, `EconomyCalculationEngine`).

2. **`Economy_Analyzer_Admin` Permission Set:**
   - Administrative permission set with full CRUD and Modify All permissions.
   - Grants import endpoint invocation access (`EconomyImportRestResource`, `EconomyImportService`, `EconomyImportBatch`).

3. **`Economy_Import_Event__e` Platform Event:**
   - Fields: `Analysis_Id__c` (Text 18), `Status__c` (Text 20: `RECEIVED`, `PROCESSING`, `CALCULATING`, `COMPLETED`, `FAILED`), `Diagnostic_Message__c` (Text 255), `Record_Count__c` (Number 18,0).
   - Publish points: `EconomyImportService` and `EconomyImportBatch` publish status events during import transitions with non-blocking error handling.

4. **`c-save-game-watcher-status` (`saveGameWatcherStatus`) LWC:**
   - Real-time watcher status component replacing legacy JavaFX `WatchersController`.
   - Subscribes to `/event/Economy_Import_Event__e` via `lightning/empApi`.
   - Emits custom `statuschange` events, displays SLDS status pills and toasts on `COMPLETED` and `FAILED`.
   - Mounted in `c-economy-analyzer-shell` header to auto-refresh wired Apex data on completion.

---

## Delivered LWC Component Inventory (Phases 5, 6, 7 & 8)

1. **`c-economy-analyzer-shell` (`economyAnalyzerShell`)**:
   - Root workspace container mapping `WindowController`.
   - Mounts `c-save-game-watcher-status` in header toolbar.
   - Analysis switcher `lightning-combobox` populated via `@wire(getRecentAnalyses)`.
   - Tabset hosting Global Overview, Country Explorer (`c-country-dashboard`), Product Market (`c-product-list-view` / `c-product-dashboard`), Analytics & Visualizations (`c-economic-charts-container`), and Compare Saves tabs.

2. **`c-economy-analysis-header` (`economyAnalysisHeader`)**:
   - Application header banner mapping `Main`.
   - `@wire(getAnalysisSummary, { analysisId: '$analysisId' })` displaying `AnalysisSummaryDTO` metrics.
   - KPI tiles: Total World GDP, Global Population, World Imports, World Exports.
   - Status badge reflecting `Import_Status__c` (`COMPLETED`, `PROCESSING`, `CALCULATING`, `RECEIVED`, `FAILED`).
   - `@api handleRefresh()` method safely triggering `refreshApex`.

3. **`c-country-dashboard` (`countryDashboard`)**:
   - Country explorer dashboard mapping `CountryController`.
   - `@wire(getCountrySummaries, { analysisId: '$analysisId' })` populating country selection combobox with auto-selection.
   - KPI cards for GDP, GDP Rank, GDP Per Capita, Population, Workforce, Employment, Unemployment Rate, Imports, Exports, Gold Income.
   - `@wire(getCountryProductSummaries, { countryEconomyId: '$selectedCountryEconomyId' })` driving `lightning-datatable` trade breakdown.

4. **`c-product-list-view` (`productListView`)**:
   - Commodity list table view mapping `ProductListController`.
   - `@wire(getProductSummaries, { analysisId: '$analysisId' })` rendering `lightning-datatable` of all products.

5. **`c-product-dashboard` (`productDashboard`)**:
   - Commodity detail view mapping `ProductController`.
   - `@wire(getProductSummary, { analysisId: '$analysisId', productEconomyId: '$productEconomyId' })` rendering detail KPI cards.

6. **`c-economic-charts-container` (`economicChartsContainer`)**:
   - Responsive SVG-native LWC charting container (Phase 7).

---

## Confirmed Legacy Quirks & Engine Implementation Details

1. **Supply vs. Demand vs. Max Demand Transparency:** Explicitly distinguished across separate KPI cards and datatable columns.
2. **GDP Per Capita Scaling Multiplier (`100,000`):** Preserved in Phase 1 Formula Field `Country_Economy__c.GDP_Per_Capita__c`.
3. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `Gold_Income__c` and added directly to country GDP; `precious_metal` product skips world market exports (`Export_Value__c = 0.0`).
4. **Ranking Tie-Breaker:** GDP sorting is deterministic: primary sort `GDP__c` descending, tie-breaker `Country_Tag__c` ascending.
5. **Idempotency Strategy:** Single-pass upserts on `Unique_Snapshot_Key__c` across analysis headers and child snapshot objects prevent duplicate records on re-import.
6. **Economic Semantics Safeguard:** Zero economic calculation formulas or DTO shapes were modified during Phase 8 security hardening.

---

## Rules for Phase 9 (Export Functionality)

- Reuse existing DTO definitions (`AnalysisSummaryDTO`, `CountrySummaryDTO`, `ProductSummaryDTO`, `CountryProductSummaryDTO`, `ProvinceSummaryDTO`).
- Maintain zero external JavaScript dependencies and enforce client-side CSV generation patterns in LWC.
- Keep Global Overview and Compare Saves placeholder tabs intact until designated phases.
