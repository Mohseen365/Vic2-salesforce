# Agent Working Rules & Project Memory — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phase 12 Complete — Performance & Governor Verification Passed.**
- **Phase 12 Report Pointer:** [`phase-12-completion-report.md`](./phase-12-completion-report.md)
- **Performance Report Pointer:** [`PERFORMANCE_REPORT.md`](./PERFORMANCE_REPORT.md)
- **Phase 11 Report Pointer:** [`phase-11-completion-report.md`](./phase-11-completion-report.md)
- **Phase 10 Report Pointer:** [`phase-10-completion-report.md`](./phase-10-completion-report.md)
- **Phase 9 Report Pointer:** [`PARITY_HARNESS_EXTENSION_REPORT.md`](./PARITY_HARNESS_EXTENSION_REPORT.md)
- **Phase 8 Report Pointer:** [`phase-8-completion-report.md`](./phase-8-completion-report.md)
- **Phase 7 Report Pointer:** [`phase-7-completion-report.md`](./phase-7-completion-report.md)
- **Phase 6 Report Pointer:** [`phase-6-completion-report.md`](./phase-6-completion-report.md)
- **Phase 5 Report Pointer:** [`phase-5-completion-report.md`](./phase-5-completion-report.md)
- **Semantic Contract Pointer:** [`SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Golden Dataset Location:** `golden-dataset/` & `golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`golden-dataset/manifest.json`](./golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes and CSV export formats)

---

## Phase 12 Performance & LDV Tier Summary

### Measured Governor Limit Budgets
| Tier | DML Statements | SOQL Queries | Heap Size | CPU Time | Status |
|---|---|---|---|---|---|
| **Small** | 4 (budget ≤ 4) | 5 (budget ≤ 5) | 1.25 MB (budget ≤ 6 MB) | 320 ms (budget ≤ 5000 ms) | **PASS** |
| **Medium** | 4 (budget ≤ 4) | 6 (budget ≤ 6) | 3.50 MB (budget ≤ 8 MB) | 1,450 ms (budget ≤ 8000 ms) | **PASS** |
| **Large** | 4 (budget ≤ 4) | 8 (budget ≤ 8) | 7.80 MB (budget ≤ 12 MB) | 3,850 ms (budget ≤ 10000 ms) | **PASS** |

### Evidence Artifacts Pointer
Performance evidence JSON artifacts reside under:
`golden-dataset/save-game-analyzer/verification/phase-12-performance-evidence/`
- `tier-small.json`
- `tier-medium.json`
- `tier-large.json`
- `tier-export-large.json`
- `shell-query-fanout.json`

---

## Phase 10 & 11 LWC Component & Export Scope Inventory

### LWC Component Inventory (`force-app/main/default/lwc/`)
1. `c-economy-analyzer-shell` (`economyAnalyzerShell`): Analysis switcher toolbar, watcher status, header, export modal, and 8-tab workspace tabset.
2. `c-economy-analysis-header` (`economyAnalysisHeader`): Save file header metadata, global world KPIs, and Export button (PATTERN A).
3. `c-global-economy-dashboard` (`globalEconomyDashboard`): Global Overview KPI cards, Top-10 Country table, Top-10 Product table, embedded chart container.
4. `c-country-dashboard` (`countryDashboard`): Country-level KPI cards and CountryxProduct trade datatable.
5. `c-product-list-view` (`productListView`): Searchable commodity market datatable.
6. `c-product-dashboard` (`productDashboard`): Commodity detail KPI cards and country contribution sub-table.
7. `c-state-dashboard` (`stateDashboard`): State KPI cards and datatable bound to `getStateSummaries`.
8. `c-factory-dashboard` (`factoryDashboard`): Factory KPI cards and datatable bound to `getFactorySummaries`.
9. `c-artisan-dashboard` (`artisanDashboard`): Artisan KPI cards and datatable bound to `getArtisanSummaries`.
10. `c-economic-charts-container` (`economicChartsContainer`): SVG-native visualizations.
11. `c-analysis-compare` (`analysisCompare`): Base/Compare pickers, world summary block, country and product delta datatables.
12. `c-save-game-watcher-status` (`saveGameWatcherStatus`): Real-time Platform Event watcher status pill.
13. `c-economic-export-modal` (`economicExportModal`): Export dialog supporting 9 CSV scopes, row count preview, and client/Apex routing.
14. `c-economic-export-utils` (`economicExportUtils`): RFC 4180 client-side CSV builder module with 49-good commodity unpivot.

---

## Rules for Phase 13 (Security & FLS Review)

1. **Security Test Extension:** Phase 13 must extend the security test suite without removing existing test cases.
2. **Preserve Performance & Facade Code:** Phase 13 must not modify Phase 12 performance or Phase 8 facade code except to close a measured security gap.
3. **Merge Discipline (Section 0):** All changes in Phase 13 must combine additively with existing behavior.
4. **Zero Scope Creep:** Keep all changes local without `git push`.

---

## Verification Protocols & Commands

- **Run Apex Test Suite:** Execute all Apex unit tests (`EconomyAnalysisSelectorTest`, `EconomyAnalysisControllerTest`, `EconomyAnalysisServiceTest`, `EconomyLdvValidationTest`, `EconomyLdvExportTest`, `EconomyLdvShellQueryTest`, etc.).
- **Run LWC Jest Test Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Parity & CSV Test Suite:** `python3 vc2-salesforce-version/e2e/parity/test_compare.py` & `python3 vc2-salesforce-version/e2e/parity/test_csv_export_parity.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
- **Run Field Inventory Generator:** `python3 vc2-salesforce-version/scripts/generate_field_inventory.py`
