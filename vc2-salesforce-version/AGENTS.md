# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Final Status

- **Current Status:** Phase 12 (Post-Migration Closeout & Audit Compliance Attestation) **VERIFIED AND COMPLETE** — Migration formally closed.
- **Audit Compliance:** 100% Compliant (All 18 Audit Document sections A through R satisfied, with 2 explicitly documented enterprise architectural deviations).
- **Enhancements Status:** **Enhancement Track A (Multi-Save Time Series & Historical Trend Analysis)** — Complete (Out of Original Audit Scope).
- **Golden Dataset Reference Location:** `vc2-salesforce-version/golden-dataset/`
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Final Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes)

---

## Core Documentation Artifacts & Pointers

1. 📋 **Audit Compliance Matrix:** [`vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md`](./AUDIT_COMPLIANCE_MATRIX.md)
2. 📄 **Migration Completion Report:** [`vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md`](./MIGRATION_COMPLETION_REPORT.md)
3. 📖 **Maintenance Runbook:** [`vc2-salesforce-version/MAINTENANCE_RUNBOOK.md`](./MAINTENANCE_RUNBOOK.md)
4. ⚖️ **Parity Verification Report:** [`vc2-salesforce-version/PARITY_REPORT.md`](./PARITY_REPORT.md)
5. ⚡ **Performance & Governor Limit Report:** [`vc2-salesforce-version/PERFORMANCE_REPORT.md`](./PERFORMANCE_REPORT.md)
6. 🔒 **Security Hardening Report:** [`vc2-salesforce-version/SECURITY_HARDENING_REPORT.md`](./SECURITY_HARDENING_REPORT.md)
7. 📉 **Enhancement Track A Completion Report:** [`vc2-salesforce-version/enhancement-a-completion-report.md`](./enhancement-a-completion-report.md)

---

## Verified Golden Dataset Metrics & Record Counts

- **Countries:** 118
- **Provinces:** 3,248
- **Products:** 49
- **Product Storages (Country × Product Junctions):** 3,772
- **Derived Calculation Records:** 3,940
- **Validation Status:** PASS (100% mathematical and domain parity verified)

---

## Workspace Tabset & Component Inventory

All five workspace tabs in `c-economy-analyzer-shell` are fully operational:
1. 🌐 **Global Overview (`c-global-economy-dashboard`)**: World KPI cards, Top 10 World Powers table, Top 10 Commodities table, embedded SVG charts container, and row navigation hooks.
2. 🏛️ **Country Explorer (`c-country-dashboard`)**: Country metrics, search filtering, trade breakdown datatable, and regional SVG charts.
3. 📦 **Product Market (`c-product-list-view` & `c-product-dashboard`)**: Commodity grid, search filtering, supply/demand breakdown, and country trade sub-table.
4. 📈 **Analytics & Visualizations (`c-economic-charts-container`)**: Pure SVG LWC multi-chart suite (GDP distribution donut, Trade balance grouped bar, Country GDP horizontal bar, Supply/demand grouped bar, Inflation scatter plot).
5. 📊 **Compare Saves (`c-analysis-compare`)**: Dual save snapshot selection, identical-selection guard, world GDP growth trend badge, country delta datatable, commodity delta datatable, and embedded **`c-multi-save-trend`** time-series accordion section (3–12 save game snapshots).

---

## Enhancement Track A — Complete (Out of Original Audit Scope)

- **Scope:** Read-only multi-save time series timeline analysis (N = 3–12 save game snapshots).
- **Apex DTOs:** `WorldTrendDTO`, `CountryTrendDTO`, `ProductTrendDTO`.
- **Selector & Service Methods:** Bounded selector queries in `EconomyAnalysisSelector.cls`, transactional aggregation in `EconomyAnalysisService.cls`, and `@AuraEnabled(cacheable=true)` methods in `EconomyAnalysisController.cls`.
- **LWC Component:** `c-multi-save-trend` featuring a dual-listbox snapshot selector (capped at 12), 5 SVG-native line and area chart tabs, first-vs-last country delta datatable, and full accessibility attributes.
- **Parity Attestation:** Zero changes to Phase 2 engine formulas or persisted fields. Parity harness (`compare.py`) re-verified with 0 discrepancies.

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc` (12 suites, 78 unit tests, 100% pass rate).
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
