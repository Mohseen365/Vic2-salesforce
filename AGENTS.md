# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** Phase 5 (Apex Calculation Engine Extension) **VERIFIED AND COMPLETE** — Calculation engine frozen and tested.
- **Semantic Contract Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Golden Dataset Location:** `vc2-salesforce-version/golden-dataset/` & `vc2-salesforce-version/golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`vc2-salesforce-version/golden-dataset/manifest.json`](./vc2-salesforce-version/golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all scopes)

---

## Phase 5 Calculation Engine Specification & API Surface

### `EconomyCalculationEngine.cls` Public API Methods
1. `calculateProductStorageContributions(List<Country_Product_Economy__c> junctions, Map<Id, Product_Economy__c> productEconomyById)`
   - Computes trade, supply/demand monetary values, and GDP contribution for each junction record.
2. `calculateCountryTotals(List<Country_Economy__c> countries, Map<Id, List<Country_Product_Economy__c>> junctionsByCountryId)`
   - Calculates total national GDP (`GDP__c`) based on product GDP contributions and gold income.
3. `assignGdpRanks(List<Country_Economy__c> countries)`
   - Sorts countries by GDP descending (tie-breaker: `Country_Tag__c` ascending) and assigns sequential GDP ranks.
4. `calculateAnalysisTotals(Economy_Analysis__c analysis, List<Country_Economy__c> countries)`
   - Aggregates top-level analysis total world imports and world exports.
5. `safeDivide(Decimal numerator, Decimal denominator, Decimal fallback)`
   - Utility helper to perform safe division with explicit zero/null fallback checks.

### Precious Metals Special Rule & Justification
- If a country has a child `Country_Product_Economy__c` record for `precious_metal`, its GDP contribution is included in the sum of product GDP contributions, avoiding double-counting of `Gold_Income__c`.
- If a `precious_metal` junction record is absent for a country, `Gold_Income__c` is added directly to `GDP__c`.
- **Golden Dataset Parity Rationale:** Matches Phase 1 frozen semantic contract and golden dataset oracle expectations.

### Precision, Scale, and Division Guards
- Monetary fields: Decimal currency values formatted/scaled per Phase 1 units.
- All division operations inside `EconomyCalculationEngine.cls` are guarded by `safeDivide` or explicit `!= 0` non-zero denominator checks.
- Purity confirmed: 0 SOQL, 0 DML, 0 Schema calls, 0 `Double` primitive types.

---

## Rules & Guidelines for Phase 6 (Import & Persistence Layer)

- Phase 6 must consume `EconomyCalculationEngine.cls` for all derived field calculations without duplicating calculation logic.
- Phase 6 must resolve master data (`Country__c`, `Product__c`, `Province__c`, `State__c`) before inserting snapshot records.
- Phase 6 must construct `Unique_Snapshot_Key__c` values deterministically from Phase 1 contracts.
- Phase 6 owns **GATE-3** (Asynchronous Queue Scope for Large Saves).
- Zero LWC components, REST endpoints, selector classes, or service classes were created in Phase 5.

---

## Core Documentation Artifacts & Pointers

1. 📜 **Semantic Contract:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
2. 📋 **Audit Compliance Matrix:** [`vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md`](./vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md)
3. 📄 **Migration Completion Report:** [`vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md`](./vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md)
4. 📖 **Maintenance Runbook:** [`vc2-salesforce-version/MAINTENANCE_RUNBOOK.md`](./vc2-salesforce-version/MAINTENANCE_RUNBOOK.md)
5. ⚖️ **Parity Verification Report:** [`vc2-salesforce-version/PARITY_REPORT.md`](./vc2-salesforce-version/PARITY_REPORT.md)
6. ⚡ **Performance & Governor Limit Report:** [`vc2-salesforce-version/PERFORMANCE_REPORT.md`](./vc2-salesforce-version/PERFORMANCE_REPORT.md)
7. 🔒 **Security Hardening Report:** [`vc2-salesforce-version/SECURITY_HARDENING_REPORT.md`](./vc2-salesforce-version/SECURITY_HARDENING_REPORT.md)
8. 📑 **Phase 5 Completion Report:** [`vc2-salesforce-version/phase-5-completion-report.md`](./vc2-salesforce-version/phase-5-completion-report.md)

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
