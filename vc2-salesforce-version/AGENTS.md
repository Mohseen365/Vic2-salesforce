# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 6 (LWC Product & Market Dashboard) is **VERIFIED AND COMPLETE**.
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

## Delivered LWC Component Inventory (Phases 5 & 6)

1. **`c-economy-analyzer-shell` (`economyAnalyzerShell`)**:
   - Root workspace container mapping `WindowController`.
   - Analysis switcher `lightning-combobox` populated via `@wire(getRecentAnalyses)`.
   - Tabset hosting Global Overview, Country Explorer (`c-country-dashboard`), Product Market (`c-product-list-view` / `c-product-dashboard`), and Compare Saves tabs.
   - Dynamically swaps between Product List View and Product Dashboard on commodity selection.

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

4. **`c-product-list-view` (`productListView`)**:
   - Commodity list table view mapping `ProductListController`.
   - `@wire(getProductSummaries, { analysisId: '$analysisId' })` rendering `lightning-datatable` of all products.
   - Columns: Product Code, Product Name, Price, Base Price, Total World Supply, Real Demand, Max Demand, Inflation %, Overproduction %.
   - Commodity search filter input matching product codes/names and row action button emitting `productselect` event.

5. **`c-product-dashboard` (`productDashboard`)**:
   - Commodity detail view mapping `ProductController`.
   - `@wire(getProductSummary, { analysisId: '$analysisId', productEconomyId: '$productEconomyId' })` rendering detail KPI cards.
   - KPI cards for Price, Base Price, Inflation Rate (with SLDS badge), Overproduction Rate (with SLDS badge), World Supply, Real Demand, and Max Demand.
   - `@wire(getCountryProductSummariesByProduct, { productEconomyId: '$productEconomyId' })` rendering country breakdown sub-table.
   - "Back to Commodity List" button emitting `back` event.

6. **`EconomyAnalysisController.cls` (Apex Facade)**:
   - `@AuraEnabled(cacheable=true)` facade layer exposing cached read operations with 100% test coverage.
   - Methods: `getRecentAnalyses`, `getAnalysisSummary`, `getCountrySummaries`, `getCountrySummary`, `getCountryProductSummaries`, `getProductSummaries`, `getProductSummary`, `getCountryProductSummariesByProduct`.

---

## Confirmed Legacy Quirks & Engine Implementation Details

1. **Supply vs. Demand vs. Max Demand Transparency:** Explicitly distinguished across separate KPI cards and datatable columns.
2. **GDP Per Capita Scaling Multiplier (`100,000`):** Preserved in Phase 1 Formula Field `Country_Economy__c.GDP_Per_Capita__c`.
3. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `Gold_Income__c` and added directly to country GDP; `precious_metal` product skips world market exports (`Export_Value__c = 0.0`).
4. **Ranking Tie-Breaker:** GDP sorting is deterministic: primary sort `GDP__c` descending, tie-breaker `Country_Tag__c` ascending.
5. **Idempotency Strategy:** Single-pass upserts on `Unique_Snapshot_Key__c` across analysis headers and child snapshot objects prevent duplicate records on re-import.

---

## Rules for Phase 7 (Analytics & Visualizations)

- Integrate Chart.js or LWC-native SVG visualizations for GDP shares, trade balances, and overproduction distributions in `c-economic-charts-container`.
- Consume existing DTO endpoints (`CountrySummaryDTO`, `ProductSummaryDTO`, `AnalysisSummaryDTO`).
- Maintain `with sharing` and FLS compliance across all new components.
