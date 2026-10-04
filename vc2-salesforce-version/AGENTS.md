# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phase 7 Complete — Idempotency & Snapshot Integrity Verified.**
- **Idempotency Report Pointer:** [`IDEMPOTENCY_REPORT.md`](./IDEMPOTENCY_REPORT.md)
- **Evidence Directory:** [`golden-dataset/save-game-analyzer/verification/phase-7-idempotency-evidence/`](./golden-dataset/save-game-analyzer/verification/phase-7-idempotency-evidence/)
- **Import Contract Specification:** [`IMPORT_CONTRACT.md`](./IMPORT_CONTRACT.md)
- **Field Inventory Reference:** [`field-inventory.md`](./field-inventory.md)
- **Semantic Contract Reference:** [`SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Golden Dataset Location:** `golden-dataset/` & `golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`golden-dataset/manifest.json`](./golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes)

---

## Phase 7 Scenario Result Summary

### Idempotency Verification Results
| # | Scenario | Result | Evidence Artifact |
|---|---|---|---|
| 1 | Repeat identical import (small) | PASS | `scenario-1-repeat-small.txt` |
| 2 | Repeat identical import (full) | PASS | `scenario-2-repeat-full.txt` |
| 3 | Modified re-import | PASS | `scenario-3-modified-reimport.txt` |
| 4 | Same saveFileName, different ingameDate | PASS — behavior documented | `scenario-4-same-filename-different-date.txt` |
| 5 | Concurrent imports | PASS | `scenario-5-concurrent-imports.txt` |
| 6 | Partial-failure recovery | PASS | `scenario-6-partial-failure-recovery.txt` |
| 7 | Master auto-provisioning idempotency | PASS | `scenario-7-master-auto-provisioning.txt` |

### Snapshot Integrity Results
| # | Assertion Group | Result | Evidence Artifact |
|---|---|---|---|
| 1 | Key format assertions | PASS | `snapshot-integrity-results.txt` |
| 2 | Uniqueness assertions | PASS | `snapshot-integrity-results.txt` |
| 3 | Referential integrity assertions | PASS | `snapshot-integrity-results.txt` |

### Hardening Log
- **Hardening Fixes Applied:** None required. The Phase 6 import pipeline natively satisfied all idempotency, key format, uniqueness, and referential integrity requirements through `Database.upsert` against External IDs and deterministic `Unique_Snapshot_Key__c` values.
- **Public API Surface:** Zero changes. No Phase 4, 5, or 6 public API signature was modified.
- **Golden Dataset Parity Under Re-Import:** Verified. Run 1 vs Run 2 diff is empty (except Salesforce-managed timestamps), and Run 2 export matches Phase 2 golden dataset within Phase 1 tolerances.

---

## Rules & Context for Phase 8 (Selectors & Controller Facade)

1. **Import Pipeline Preservation:** Phase 8 must NOT modify the Phase 6 import pipeline or `EconomyImportService`.
2. **DTO Contracts:** Phase 8 must NOT duplicate the `EconomyImportResponseDTO` shape.
3. **Selector Scope & Status Lifecycle:** Phase 8's selector queries must respect the `Economy_Analysis__c.Import_Status__c` status lifecycle and default to returning records for `COMPLETED` analyses only.
4. **Re-introduction of Pre-commit Apex:** Phase 8 must re-create/re-introduce the superseded `EconomyAnalysisSelector.cls` and `EconomyAnalysisController.cls` from the pre-commit Phase 6 work, applying PATTERN I to `phase-6-completion-report.md` when re-introducing those claims.
5. **Merge Discipline (§0):** When adding selector logic to classes that already exist, combine rather than replace (e.g. use overloaded methods per Pattern B, additive fields per Pattern C, side-by-side constants per Pattern D).
6. **Zero Scope Creep Attestation:** No LWC components, selector classes, or controller classes were created in Phase 7.

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
  - Custom Objects: `State__c`, `State_Economy__c`, `Factory_Economy__c`, `Artisan_Economy__c`, `Economy_Analysis__c`, `Country__c`, `Country_Economy__c`, `Product__c`, `Product_Economy__c`, `Country_Product_Economy__c`, `Province__c`, `Province_Economy__c`, `Economy_Import_Event__e`.
- **Total Custom Fields:** 138 custom fields verified across all objects.
- **Canonical Units & Precision:** 100% compliant with Phase 1 frozen unit definitions (Daily £, Annual £, Per-person wages/productivity, physical quantities, headcount counts, ranks).
- **Field Inventory:** Updated authoritative mapping available at [`field-inventory.md`](./field-inventory.md).

---

## Architecture Review Gates Status

- **GATE-1 (Modded Commodity & Artisan Type Mappings):** RESOLVED in Phase 4 / Phase 6.
  - *Unknown Products Strategy:* If a `productCode` in an incoming payload does not match an existing `Product__c` master, the Phase 6 import service auto-provisions a minimal static `Product__c` (`Code__c = productCode`, `Name = productCode`, `Base_Price__c = 0.0`).
  - *Unknown Artisan Types Strategy:* If an `artisanType` string in an incoming payload cannot be normalized or matched to a valid product/artisan mapping, the Phase 6 import service logs a diagnostic warning (`Import_Diagnostic_Message__c`) and skips the individual artisan record without aborting the batch transaction.
- **GATE-2 (State Name Variance Across Mods — HPM/GFM/Vanilla):** RESOLVED in Phase 3 / Phase 6.
  - *Strategy:* Use composite key `State_Code__c = <CountryTag>_<StateName>` (e.g. `EGY_Cairo`, `TUR_blank`).
  - *Analysis:* Inspection of `golden-dataset/save-game-analyzer/states.json` confirms 124 state records with 124 unique composite key values (100% uniqueness).
- **GATE-3 (Asynchronous Import Queue Scope for Large Saves):** RESOLVED in Phase 6.
  - *Strategy:* Delegates factory and artisan persistence to `EconomyImportBatch.cls` (scope = 200 records per chunk) when payload exceeds 200 records.

---

## Maintenance & Test Execution Guidelines

- **Run Apex Test Suite:** Execute all Apex unit tests including `EconomyImportIdempotencyTest.cls`.
- **Run Parity Verification Harness:** `python3 e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 scripts/validate_metadata.py`
- **Run Field Inventory Generator:** `python3 scripts/generate_field_inventory.py`
