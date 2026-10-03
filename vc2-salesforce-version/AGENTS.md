# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** Phase 2 (Golden Dataset Extension) **VERIFIED AND COMPLETE** — Golden dataset extended.
- **Semantic Contract Reference:** [`SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Golden Dataset Location:** `golden-dataset/` & `golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`golden-dataset/manifest.json`](./golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across pre-existing scopes)

---

## Phase 2 Extended Golden Dataset Inventory & Record Counts

1. **`country.json` / `csv/Country.csv`:** 118 records (Extended with `fgdp`, `pgdp`, `agdp`, `corePopulation`, `colonyPopulation`).
2. **`provinces.json` / `csv/Provinces.csv`:** 2,703 records (Extended with `rgoIncome`, `rgoGdp`, `colony`, `artisanSpending`, `artisanIncome`, `artisanGdp`).
3. **`factory.json` / `csv/Factory.csv`:** 714 records (New Phase 2 addition covering individual building metrics).
4. **`artisans.json` / `csv/Artisans.csv`:** 4,406 records (New Phase 2 addition covering aggregated artisan metrics).
5. **`states.json` / `csv/States.csv`:** 124 records (New Phase 2 addition covering regional state aggregations).
6. **`goods.json` / `csv/Goods.csv`:** 48 records.

---

## Phase 1 Semantic Contract Compliance Verification

- All identity keys in Phase 2 match the Phase 1 frozen formulas (`State_Code__c`, `OccurrenceIndex`, `Province × Product`).
- All monetary and physical units match the Phase 1 canonical unit table.
- All division-by-zero guards (`Employees == 0 → 0.0`, `Population == 0 → 0.0`) and clamps (`AGDP < -1000 → 0.0`) are verified.

---

## Rules & Guidelines for Phase 3 (Salesforce Metadata Schema)

- Phase 3 must deploy custom objects `State__c`, `State_Economy__c`, `Factory_Economy__c`, and `Artisan_Economy__c`.
- Phase 3 must add extended custom fields to `Province_Economy__c` (`Colony__c`, `RGO_Income__c`, `RGO_GDP__c`, `Artisan_Spending__c`, `Artisan_Income__c`, `Artisan_GDP__c`) and `Country_Economy__c` (`Core_Population__c`, `Colony_Population__c`, `Factory_GDP__c`, `Province_GDP__c`, `Artisan_GDP__c`).
- Phase 3 must deploy unique external ID fields matching the frozen snapshot key contracts.
- Phase 3 must resolve `GATE-2` (State Name Variance Across Mods).
- Zero Apex, metadata (`force-app/`), LWCs, or tests were created in Phase 2.

---

## Core Documentation Artifacts & Pointers

1. 📜 **Semantic Contract:** [`SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
2. 📋 **Audit Compliance Matrix:** [`AUDIT_COMPLIANCE_MATRIX.md`](./AUDIT_COMPLIANCE_MATRIX.md)
3. 📄 **Migration Completion Report:** [`MIGRATION_COMPLETION_REPORT.md`](./MIGRATION_COMPLETION_REPORT.md)
4. 📖 **Maintenance Runbook:** [`MAINTENANCE_RUNBOOK.md`](./MAINTENANCE_RUNBOOK.md)
5. ⚖️ **Parity Verification Report:** [`PARITY_REPORT.md`](./PARITY_REPORT.md)
6. ⚡ **Performance & Governor Limit Report:** [`PERFORMANCE_REPORT.md`](./PERFORMANCE_REPORT.md)
7. 🔒 **Security Hardening Report:** [`SECURITY_HARDENING_REPORT.md`](./SECURITY_HARDENING_REPORT.md)

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 scripts/validate_metadata.py`
