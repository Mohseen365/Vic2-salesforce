# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** Phase 3 (Salesforce Metadata Schema) **VERIFIED AND COMPLETE** — Schema frozen and deployed.
- **Field Inventory Reference:** [`field-inventory.md`](./field-inventory.md)
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

## Schema Summary (Phase 3 Complete)

- **Total Custom Objects:** 13 (8 baseline + 4 new custom objects + 1 import platform event).
  - New Custom Objects: `State__c`, `State_Economy__c`, `Factory_Economy__c`, `Artisan_Economy__c`.
- **Total Custom Fields:** 138 custom fields verified across all objects.
- **Canonical Units & Precision:** 100% compliant with Phase 1 frozen unit definitions (Daily £, Annual £, Per-person wages/productivity, physical quantities, headcount counts, ranks).
- **Field Inventory:** Updated authoritative mapping available at [`field-inventory.md`](./field-inventory.md).
- **Zero Scope Creep Attestation:** Zero Apex classes (`.cls`), LWCs (`.js`/`.html`), DTOs, or tests created or modified in Phase 3.

---

## Architecture Review Gates Status

- **GATE-1 (Modded Commodity & Artisan Type Mappings):** OPEN — Target Phase 4 (Parser & Ingestion DTO Contract).
- **GATE-2 (State Name Variance Across Mods — HPM/GFM/Vanilla):** RESOLVED in Phase 3.
  - *Strategy:* Use composite key `State_Code__c = <CountryTag>_<StateName>` (e.g. `EGY_Cairo`, `TUR_blank`).
  - *Analysis:* Inspection of `golden-dataset/save-game-analyzer/states.json` confirms 124 state records with 124 unique composite key values (100% uniqueness).
  - *Residual Risk:* In modded saves where state names vary across languages/mods or where `blank` state names recur across different states within the same country, collision handling at import time is carried forward as a non-blocking consideration for Phase 6.
- **GATE-3 (Asynchronous Import Queue Scope for Large Saves):** OPEN — Target Phase 6 (Import Layer).

---

## Directives & Rules for Phase 4 (Parser & Ingestion DTO Contract)

- `EconomyImportRequestDTO` must emit exactly the fields the Phase 3 schema persists — no more, no less.
- DTO structures must map directly to snapshot external ID keys (`Unique_Snapshot_Key__c`) and lookups.
- Parser boundaries must handle unmapped artisan types dynamically (GATE-1 resolution).

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
