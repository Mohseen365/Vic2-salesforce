# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phase 9 Complete — Parity Harness Extended.**
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

## Phase 9 Parity Harness Inventory & Scope Structure

### Extended Comparison Tool (`e2e/parity/compare.py`)
- **Unified Harness Entry Point:** Runs comparisons across all 8 entity scopes (`world_totals`, `country`, `product`, `country_product_junctions`, `province`, `states`, `factories`, `artisans`).
- **Scope Modules Location:** `e2e/parity/scopes/`
  - `states.py`: `compare_states`
  - `factories.py`: `compare_factories`
  - `artisans.py`: `compare_artisans`
- **Extended Scope Comparators (Pattern C - Additive):**
  - `country`: `fgdp`, `pgdp`, `agdp`, `corePopulation`, `colonyPopulation` added below existing country fields.
  - `province`: `colony`, `rgoIncome`, `rgoGdp`, `artisanSpending`, `artisanIncome`, `artisanGdp` added below existing province fields.
- **Harness Test Suite:** `e2e/parity/test_compare.py` (6 unit tests, 100% pass rate).
- **Determinism Evidence:** `e2e/parity/verification/phase-9-determinism-diff.txt` (empty / byte-identical execution).

### Scope Inventory & Tolerance Table
| Scope | Record Count | Field Comparisons | Tolerance Applied | Pattern Applied |
|---|---|---|---|---|
| `world_totals` | 1 | 4 | £0.01 currency, integer exact | Preserved |
| `country` | 118 | 19 | £0.01 currency, 0.01% percent, exact integer | C (Additive) |
| `product` | 48 | 7 | 0.0001 price/qty, 0.01% percent | Preserved |
| `country_product_junctions` | 0 (bundle) / N | 8 | £0.01 currency, 0.0001 qty | Preserved |
| `province` | 2,701 | 8 | £0.01 currency, 0.0001 qty, string match | C (Additive) |
| `states` | 124 | 14 | £0.01 currency, exact integer, string match | A (Extension) |
| `factories` | 714 | 18 | £0.01 currency, 0.0001 qty, exact integer | A (Extension) |
| `artisans` | 4,054 (active) | 9 | £0.01 currency, 0.0001 qty, string match | A (Extension) |

---

## Rules for Phase 10 (LWC Dashboards)

1. **Consume Phase 8 Controller Facade:** Phase 10 LWCs must bind to `@AuraEnabled` methods in `EconomyAnalysisController.cls`, not directly to python scripts.
2. **Merge Discipline (Section 0):** When extending `c-economy-analyzer-shell` or existing LWC components to add new state/factory/artisan tabs, Phase 10 must **combine** new tabs with existing Country Explorer and Product Market tabs, not replace them (PATTERN A).
3. **Zero Scope Creep:** No Apex class or schema change occurred in Phase 9; Phase 10 owns LWC component additions.

---

## Maintenance & Test Execution Guidelines

- **Run Apex Test Suite:** Execute all Apex unit tests (`EconomyAnalysisSelectorTest`, `EconomyAnalysisControllerTest`, `EconomyAnalysisServiceTest`, `DTOsTest`, `EconomyImportIdempotencyTest`, etc.).
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Parity Test Suite:** `python3 vc2-salesforce-version/e2e/parity/test_compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
- **Run Field Inventory Generator:** `python3 vc2-salesforce-version/scripts/generate_field_inventory.py`
