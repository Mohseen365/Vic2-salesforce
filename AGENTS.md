# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** Phase 1 (Semantic Contract Freeze) **VERIFIED AND COMPLETE** — Semantic contract frozen.
- **Semantic Contract Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Golden Dataset Location:** `vc2-salesforce-version/golden-dataset/`
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes)

---

## Phase 1 Frozen Semantic Contracts Summary

1. **Canonical Units:** Factory/RGO/Artisan financial metrics frozen in daily £ vs annual £ (`GDP = Daily * 365`), zero-guards (`Employees == 0 → 0.0`), and negative AGDP clamps (`AGDP < -1000 → 0.0`).
2. **Artisan Granularity:** Aggregated at `Province × Product per snapshot` with key `<AnalysisId>_<ExternalProvId>_<ProductCode>`. Individual POP-level preservation is an explicit non-goal.
3. **Factory Occurrence Key:** `<AnalysisId>_<StateCode>_<BuildingType>_<OccurrenceIndex>` (1-based index matching legacy `Factory.py` traversal order).
4. **Master vs. Snapshot Model:** Master records (`State__c`, `Province__c`) and Snapshot records (`State_Economy__c`, `Province_Economy__c`) remain strictly separated. Master records are never mutated by snapshot imports except via non-destructive auto-provisioning upserts.

---

## Open Architecture-Review Gates Carried Forward

- **GATE-1:** Modded Commodity & Artisan Type Mappings (Phase 4).
- **GATE-2:** State Name Variance across Mods via `<CountryTag>_<StateName>` keys (Phase 3).
- **GATE-3:** Asynchronous Import Queue Scope (200 records/scope) for Large Saves (Phase 6).

---

## Critical Rules & Guidelines for Phase 2 (Golden Dataset Extension)

- Phase 2 must produce derived golden JSON fixtures (`states.json`, `factories.json`, `artisans.json`) directly from Python/legacy execution without altering Apex or Salesforce metadata.
- Phase 2 must strictly enforce the identity key formats and canonical units frozen in Phase 1.
- Zero changes to Apex, Salesforce metadata (`force-app/`), LWCs, or existing tests were made in Phase 1.

---

## Core Documentation Artifacts & Pointers

1. 📜 **Semantic Contract:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
2. 📋 **Audit Compliance Matrix:** [`vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md`](./vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md)
3. 📄 **Migration Completion Report:** [`vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md`](./vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md)
4. 📖 **Maintenance Runbook:** [`vc2-salesforce-version/MAINTENANCE_RUNBOOK.md`](./vc2-salesforce-version/MAINTENANCE_RUNBOOK.md)
5. ⚖️ **Parity Verification Report:** [`vc2-salesforce-version/PARITY_REPORT.md`](./vc2-salesforce-version/PARITY_REPORT.md)
6. ⚡ **Performance & Governor Limit Report:** [`vc2-salesforce-version/PERFORMANCE_REPORT.md`](./vc2-salesforce-version/PERFORMANCE_REPORT.md)
7. 🔒 **Security Hardening Report:** [`vc2-salesforce-version/SECURITY_HARDENING_REPORT.md`](./vc2-salesforce-version/SECURITY_HARDENING_REPORT.md)

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
