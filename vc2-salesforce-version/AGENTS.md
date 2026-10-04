# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phase 10 Complete — LWC Dashboards Live.**
- **Phase 10 Report Pointer:** [`phase-10-completion-report.md`](./phase-10-completion-report.md)
- **Phase 9 Report Pointer:** [`PARITY_HARNESS_EXTENSION_REPORT.md`](./PARITY_HARNESS_EXTENSION_REPORT.md)
- **Phase 8 Report Pointer:** [`phase-8-completion-report.md`](./phase-8-completion-report.md)
- **Phase 7 Report Pointer:** [`IDEMPOTENCY_REPORT.md`](./IDEMPOTENCY_REPORT.md)
- **Import Contract Specification:** [`IMPORT_CONTRACT.md`](./IMPORT_CONTRACT.md)
- **Field Inventory Reference:** [`field-inventory.md`](./field-inventory.md)
- **Semantic Contract Reference:** [`SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Golden Dataset Location:** `golden-dataset/` & `golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`golden-dataset/manifest.json`](./golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all unioned entity scopes)

---

## Phase 10 LWC Dashboard Inventory & Shell Structure

### LWC Component Inventory (`force-app/main/default/lwc/`)
1. `c-economy-analyzer-shell` (`economyAnalyzerShell`): Analysis switcher toolbar, watcher status, header, export modal, and 8-tab workspace tabset.
2. `c-economy-analysis-header` (`economyAnalysisHeader`): Save file header metadata and global world KPIs.
3. `c-country-dashboard` (`countryDashboard`): Country-level KPI cards and CountryxProduct trade datatable.
4. `c-product-list-view` (`productListView`): Searchable commodity market datatable.
5. `c-product-dashboard` (`productDashboard`): Commodity detail KPI cards and country contribution sub-table.
6. `c-state-dashboard` (`stateDashboard`): State KPI cards and datatable bound to `getStateSummaries`.
7. `c-factory-dashboard` (`factoryDashboard`): Factory KPI cards and datatable bound to `getFactorySummaries`.
8. `c-artisan-dashboard` (`artisanDashboard`): Artisan KPI cards and datatable bound to `getArtisanSummaries`.
9. `c-economic-charts-container` (`economicChartsContainer`): SVG-native visualizations (GDP distribution, trade balance, supply/demand).
10. `c-save-game-watcher-status` (`saveGameWatcherStatus`): Real-time Platform Event watcher status pill.
11. `c-economic-export-modal` (`economicExportModal`): Export dialog.
12. `c-economic-export-utils` (`economicExportUtils`): Client-side CSV export utility.

### Shell Tab Order
`Global Overview` → `Country Explorer` → `Product Market` → `State Explorer` → `Factory Explorer` → `Artisan Explorer` → `Analytics & Visualizations` → `Compare Saves`

---

## Rules for Phase 11 (CSV Export Parity & Deferred UI Closure)

1. **Phase 11 Tab Population:** Fill the `Global Overview` (`c-global-economy-dashboard`) and `Compare Saves` (`c-analysis-compare`) tab placeholders.
2. **Merge Discipline (Section 0):** Extend shell and export modal using PATTERN A. Do not remove or replace existing tabs 2–7 or existing export scopes.
3. **Zero Scope Creep:** Keep all changes local without `git push`.

---

## Maintenance & Test Execution Guidelines

- **Run Apex Test Suite:** Execute all Apex unit tests (`EconomyAnalysisSelectorTest`, `EconomyAnalysisControllerTest`, `EconomyAnalysisServiceTest`, `DTOsTest`, `EconomyImportIdempotencyTest`, etc.).
- **Run LWC Jest Test Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Parity Test Suite:** `python3 vc2-salesforce-version/e2e/parity/test_compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
- **Run Field Inventory Generator:** `python3 vc2-salesforce-version/scripts/generate_field_inventory.py`
