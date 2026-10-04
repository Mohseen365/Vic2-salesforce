# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phase 11 Complete — Export Parity Live; Shell Tabs Fully Wired.**
- **Phase 11 Report Pointer:** [`phase-11-completion-report.md`](./phase-11-completion-report.md)
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
- **Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes and CSV export formats)

---

## Phase 11 LWC Component & Export Scope Inventory

### LWC Component Inventory (`force-app/main/default/lwc/`)
1. `c-economy-analyzer-shell` (`economyAnalyzerShell`): Analysis switcher toolbar, watcher status, header, export modal, and 8-tab workspace tabset.
2. `c-economy-analysis-header` (`economyAnalysisHeader`): Save file header metadata, global world KPIs, and Export button (PATTERN A).
3. `c-global-economy-dashboard` (`globalEconomyDashboard`): Global Overview KPI cards, Top-10 Country table, Top-10 Product table, embedded chart container (Phase 11 filled).
4. `c-country-dashboard` (`countryDashboard`): Country-level KPI cards and CountryxProduct trade datatable.
5. `c-product-list-view` (`productListView`): Searchable commodity market datatable.
6. `c-product-dashboard` (`productDashboard`): Commodity detail KPI cards and country contribution sub-table.
7. `c-state-dashboard` (`stateDashboard`): State KPI cards and datatable bound to `getStateSummaries`.
8. `c-factory-dashboard` (`factoryDashboard`): Factory KPI cards and datatable bound to `getFactorySummaries`.
9. `c-artisan-dashboard` (`artisanDashboard`): Artisan KPI cards and datatable bound to `getArtisanSummaries`.
10. `c-economic-charts-container` (`economicChartsContainer`): SVG-native visualizations.
11. `c-analysis-compare` (`analysisCompare`): Base/Compare pickers, world summary block, country and product delta datatables (Phase 11 filled).
12. `c-save-game-watcher-status` (`saveGameWatcherStatus`): Real-time Platform Event watcher status pill.
13. `c-economic-export-modal` (`economicExportModal`): Export dialog supporting 9 CSV scopes, row count preview, and client/Apex routing (Phase 11 re-introduced).
14. `c-economic-export-utils` (`economicExportUtils`): RFC 4180 client-side CSV builder module with 49-good commodity unpivot (Phase 11 re-introduced).

### Export Scope Inventory & Client vs Apex Threshold
- **Threshold:** 5,000 rows.
- **Client-Side Engine:** `Summary` (1 row), `Products` (48 rows), `Goods` (48 rows), `CountryProducts` (<=5000 rows).
- **Apex Fallback Stream:** `Countries` (49-good unpivot), `Provinces` (2,703 rows), `States` (124 rows), `Factories` (714 rows), `Artisans` (4,406 rows).
- **Filename Convention:** `<SaveFileName>_<scope>_<IngameDate>.csv`

### Re-Introduction Log
- `c-economic-export-modal`: Re-introduced fresh in Phase 11, bound to active `analysisId` and header Export button.
- `economicExportUtils`: Re-introduced fresh in Phase 11, implementing RFC 4180 escaping and per-scope builders.
- `EconomyAnalysisController.exportCsv`: Re-introduced in Phase 11 as server-side streaming fallback for LDV datasets.

---

## Rules for Phase 12 (Performance & Governor Verification)

1. **LDV Test Suite Extension:** Phase 12 must extend the LDV test suite to cover all 9 export scopes, `Global Overview` queries, and `Compare Saves` queries without removing existing test cases.
2. **Preserve Export Code:** Phase 12 must not modify Phase 11 export code beyond what a measured governor limit or performance gap requires.
3. **Merge Discipline (Section 0):** All changes in Phase 12 must combine additively with existing behavior.
4. **Zero Scope Creep:** Keep all changes local without `git push`.

---

## Maintenance & Test Execution Guidelines

- **Run Apex Test Suite:** Execute all Apex unit tests (`EconomyAnalysisSelectorTest`, `EconomyAnalysisControllerTest`, `EconomyAnalysisServiceTest`, `DTOsTest`, `EconomyImportIdempotencyTest`, etc.).
- **Run LWC Jest Test Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Parity & CSV Test Suite:** `python3 vc2-salesforce-version/e2e/parity/test_compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
- **Run Field Inventory Generator:** `python3 vc2-salesforce-version/scripts/generate_field_inventory.py`
