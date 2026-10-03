# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Final Status

- **Current Status:** Phase 10 (End-to-End Testing & Optimization) **VERIFIED AND COMPLETE** — Migration closed.
- **Golden Dataset Reference Location:** `vc2-salesforce-version/golden-dataset/`
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Final Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes)

---

## Verified Golden Dataset Metrics & Record Counts

- **Countries:** 118
- **Provinces:** 3,248
- **Products:** 49
- **Product Storages (Country × Product Junctions):** 3,772
- **Derived Calculation Records:** 3,940
- **Validation Status:** PASS (100% mathematical and domain parity verified)

---

## Final Performance & LDV Profile

| Tier | Record Volume | DML Statements | SOQL Queries | Peak Heap Size | CPU Time | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Small Tier** | 36 records | 2 / 150 | 5 / 100 | ~280 KB | ~45 ms | `COMPLETED` |
| **Medium Tier**| 1,581 records | 3 / 150 | 6 / 100 | ~1.2 MB | ~180 ms | `COMPLETED` |
| **Large Tier** | 7,701 records | 4 / 150 | 8 / 100 | ~2.9 MB | ~380 ms | `COMPLETED` |

---

## Delivered Component & Utility Inventory

1. **`c-economy-analyzer-shell` (`economyAnalyzerShell`)**: Root container mapping `WindowController`.
2. **`c-economy-analysis-header` (`economyAnalysisHeader`)**: Header banner mapping `Main` with status indicator & export button.
3. **`c-country-dashboard` (`countryDashboard`)**: Country explorer dashboard mapping `CountryController`.
4. **`c-product-list-view` & `c-product-dashboard`**: Commodity market grid and detail view mapping `ProductListController` / `ProductController`.
5. **`c-economic-charts-container` (`economicChartsContainer`)**: SVG-native chart container for GDP share, price trend, and trade balances.
6. **`c-save-game-watcher-status` (`saveGameWatcherStatus`)**: Platform Event streaming status subscriber listening to `Economy_Import_Event__e`.
7. **`c-economic-export-modal` (`economicExportModal`) & `c/economicExportUtils`**: RFC 4180 CSV export suite with threshold routing (≤ 5,000 client-side, > 5,000 Apex fallback).
8. **Apex Calculation Engine & Import Pipeline**: `EconomyCalculationEngine.cls`, `EconomyImportService.cls`, `EconomyImportBatch.cls`, `EconomyImportRestResource.cls`.

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc` (9 suites, 60 unit tests, 100% pass rate).
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
- **Deferred Items:** Global Overview Tab UI and Compare Saves Tab UI are reserved for future post-migration feature phases (`AnalysisComparisonDTO.cls` backend methods are complete).
