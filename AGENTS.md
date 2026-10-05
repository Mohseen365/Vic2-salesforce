# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** Phase 6 (Import & Persistence Layer) **VERIFIED AND COMPLETE** — Ingestion service, REST API resource, and batch persistence pipeline live.
- **Semantic Contract Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Import Contract Reference:** [`vc2-salesforce-version/IMPORT_CONTRACT.md`](./vc2-salesforce-version/IMPORT_CONTRACT.md)
- **Golden Dataset Location:** `vc2-salesforce-version/golden-dataset/` & `vc2-salesforce-version/golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`vc2-salesforce-version/golden-dataset/manifest.json`](./vc2-salesforce-version/golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all scopes)

---

## Phase 6 Import Pipeline & REST Ingestion Architecture

### REST Endpoint Interface
- **Endpoint URL:** `POST /services/apexrest/economy/import`
- **Controller Class:** `EconomyImportRestResource.cls`
- **Request Body Shape:** `EconomyImportRequestDTO` (contract version `1.0.0` required).
- **HTTP Status Code Matrix:**
  - `201 Created`: Synchronous ingestion completed (`COMPLETED`).
  - `202 Accepted`: Large payload enqueued for async batch processing (`PROCESSING`).
  - `400 Bad Request`: Validation error, missing required header, or contract version mismatch.
  - `403 Forbidden`: FLS/CRUD authorization failure.
  - `500 Internal Server Error`: Unexpected exception during parsing/persistence.

### Orchestration Lifecycle & Status Transitions
`RECEIVED` → `PROCESSING` → `CALCULATING` → `COMPLETED` (or `FAILED` with diagnostic message)
1. **RECEIVED:** `Economy_Analysis__c` header created/upserted.
2. **PROCESSING:** Master data resolved (Country → Product → Province → State) via `Database.upsert` against External IDs.
3. **CALCULATING:** Child snapshot records persisted, Phase 5 engine invoked for storage trade calculations and country total/rank updates.
4. **COMPLETED:** Factory and Artisan snapshots persisted (synchronously or asynchronously), final diagnostic warnings saved to `Import_Diagnostic_Message__c`.

### Resolved Architecture Gates
- **GATE-1 (Modded Commodities / Artisan Types):**
  - Unknown products auto-provisioned in `Product__c` (`Code__c = code`, `Name = code`, `Base_Price__c = 0.0`).
  - Unknown artisan types log warning diagnostic and skip individual artisan record without failing transaction.
- **GATE-2 (State Name Variance):**
  - Master states use composite external key `State_Code__c = <CountryTag>_<StateName>`.
- **GATE-3 (Asynchronous Queue Scope for LDV):**
  - Threshold: `factories.size() > 200` or `artisans.size() > 200`.
  - Batch Class: `EconomyImportBatch.cls` (scope = 200 records per chunk).
  - Rationale: Guarantees DML and heap safety for save games containing 700+ factories and 4,400+ artisans.

---

## Rules & Guidelines for Subsequent Phases

- Subsequent phases must consume `EconomyAnalysisSelector.cls` and `EconomyAnalysisController.cls` for querying imported snapshot data.
- Master data auto-provisioning must maintain non-destructive upserts (`Database.upsert` on External ID).
- Zero LWC or UI components were created in Phase 6.

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
9. 📑 **Phase 6 Completion Report:** [`vc2-salesforce-version/phase-6-completion-report.md`](./vc2-salesforce-version/phase-6-completion-report.md)

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`

## Track B — Comprehensive Save-Game Data Model Expansion Status
- **Status:** `COMPLETE — ATTESTED` (Track B Remediation completed; reference integrity restored).
- **Deliverables & Verification Reports:**
  - [`vc2-salesforce-version/track-b-reconciliation.md`](./vc2-salesforce-version/track-b-reconciliation.md): Reconciliation decisions and governor limits resolutions.
  - [`vc2-salesforce-version/track-b-completion-report.md`](./vc2-salesforce-version/track-b-completion-report.md): Final completion report (§6 verification evidence & §7 remediation summary).
  - [`vc2-salesforce-version/track-b-coverage-map.md`](./vc2-salesforce-version/track-b-coverage-map.md): 1:1 coverage map (126 compact objects reconciled).
  - [`vc2-salesforce-version/track-b-verification-attestation.md`](./vc2-salesforce-version/track-b-verification-attestation.md): Re-issued attestation report (PASS verdict).
  - [`vc2-salesforce-version/track-b-remediation-log.md`](./vc2-salesforce-version/track-b-remediation-log.md): 74-row log detailing every field remediated or deleted.
  - `salesforce_model_expanded.txt`: Expanded 139-object model reference text.
  - `field-inventory.md`: Extended field inventory covering both Economy Model and Track B Full Save-Game Model.
- **Protected Economy Artifacts Integrity:**
  - 151 files across 13 protected economy object folders verified bit-for-bit unchanged (`git status` clean). Deterministic SHA-256 baseline: `976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38`.
- **Delivered Model Summary:**
  - Delivered object count: 139 custom objects (13 protected economy artifacts + 126 save entities & junction objects).
- **Rules for Future Tracks:**
  - Any future track extending non-economy entities must respect the junction patterns (`Save_Game_Country_Ref__c`, `Country_Country_Ref__c`).
  - Do not alter any of the 13 protected economy artifacts or `EconomyCalculationEngine.cls`.
