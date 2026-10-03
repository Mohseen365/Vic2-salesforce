# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 9 (Export Functionality) is **VERIFIED AND COMPLETE**.
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

## Delivered Export Architecture & Utility Inventory (Phase 9)

1. **`c-economic-export-modal` (`economicExportModal`) LWC:**
   - Interactive SLDS export dialog mapping legacy `ExportController` / `CsvExporter`.
   - Scope Selector: `Summary`, `Countries`, `Products`, `CountryProducts`, `Provinces`.
   - Format Selector: `CSV` (RFC 4180).
   - Preview row count indicator with routing threshold: client-side generation for ≤ 5,000 rows, server-side Apex stream for > 5,000 rows.
   - Trigger browser download with auto-revoked blob URL and SLDS toasts.

2. **`c/economicExportUtils` (`economicExportUtils.js`) Service Module:**
   - Pure, RFC 4180-compliant CSV generator (`toCsv`, `escapeCsvValue`).
   - Scope builder functions: `buildAnalysisCsv`, `buildCountriesCsv`, `buildProductsCsv`, `buildCountryProductsCsv`, `buildProvincesCsv`.
   - Filename generator helper: `${saveFileName}_${scope}_${ingameDate}.csv`.

3. **Apex CSV Fallback Engine:**
   - Method: `EconomyAnalysisController.exportCsv(analysisId, scope)`
   - Full security enforcement (`with sharing`, `WITH SECURITY_ENFORCED`, FLS checks).

---

## Delivered LWC Component Inventory (Phases 5, 6, 7, 8 & 9)

1. **`c-economy-analyzer-shell` (`economyAnalyzerShell`)**:
   - Root workspace container mapping `WindowController`.
   - Mounts `c-save-game-watcher-status` and `c-economic-export-modal`.
   - Handles `openexport` events from header and child dashboards.

2. **`c-economy-analysis-header` (`economyAnalysisHeader`)**:
   - Header banner mapping `Main`.
   - KPI tiles and status badges with Export button firing `openexport` (scope: `Summary`).

3. **`c-country-dashboard` (`countryDashboard`)**:
   - Country explorer dashboard mapping `CountryController`.
   - Includes Export Countries button firing `openexport` (scope: `Countries`).

4. **`c-product-dashboard` (`productDashboard`)**:
   - Commodity detail view mapping `ProductController`.
   - Includes Export Products button firing `openexport` (scope: `Products`).

5. **`c-save-game-watcher-status` (`saveGameWatcherStatus`)**:
   - Platform Event listener driving real-time status updates (Phase 8).

6. **`c-economic-charts-container` (`economicChartsContainer`)**:
   - SVG-native LWC charting container (Phase 7).

---

## Confirmed Legacy Quirks & Engine Implementation Details

1. **Supply vs. Demand vs. Max Demand Transparency:** Explicitly distinguished across separate KPI cards and datatable columns.
2. **GDP Per Capita Scaling Multiplier (`100,000`):** Preserved in Phase 1 Formula Field `Country_Economy__c.GDP_Per_Capita__c`.
3. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `Gold_Income__c` and added directly to country GDP; `precious_metal` product skips world market exports (`Export_Value__c = 0.0`).
4. **Ranking Tie-Breaker:** GDP sorting is deterministic: primary sort `GDP__c` descending, tie-breaker `Country_Tag__c` ascending.
5. **Idempotency Strategy:** Single-pass upserts on `Unique_Snapshot_Key__c` across analysis headers and child snapshot objects prevent duplicate records on re-import.
6. **Economic Semantics Safeguard:** Zero economic calculation formulas or DTO shapes were modified during Phase 9 export implementation.

---

## Rules for Phase 10 (End-to-End Testing & Optimization)

- Maintain 100% test pass rate across all Apex test classes and LWC Jest suites.
- Perform end-to-end integration verification and Large Data Volume (LDV) profiling.
- Keep Global Overview and Compare Saves placeholder tabs intact until designated phases.
