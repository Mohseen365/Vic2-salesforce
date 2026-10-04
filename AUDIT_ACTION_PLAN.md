# Victoria 2 Save-Game & Salesforce Architecture Audit Action Plan (`AUDIT_ACTION_PLAN.md`)

## Executive Summary & Objectives
This document defines the actionable implementation plan for executing changes, maintaining system health, verifying data parity, and managing Git commits for the Victoria 2 Economy Analyzer Salesforce architecture based on the Master Audit decisions.

---

## 1. Actionable Phase Roadmap

### Phase 0: Forensic Discovery & Audit Verification (COMPLETED)
- **Objective:** Complete forensic reverse-engineering of source save game `egypt.v2` and audit repository metadata.
- **Deliverables:**
  - 24 Master Audit Markdown Documents (`01_V2_...` through `24_FINAL_...`).
  - `AUDIT_ACTION_PLAN.md` detailing change execution and Git workflow.
- **Acceptance Criteria:** 100% document coverage, 0 discrepancies in parity harness.

### Phase 1: Custom Object & Field Schema Validation
- **Objective:** Verify and maintain the 13 Custom Objects and 138 Custom Fields in `vc2-salesforce-version/force-app/main/default/objects/`.
- **Inputs:** SFDX Object XML definitions.
- **Outputs:** Verified metadata structure.
- **Execution Command:**
  ```bash
  python3 vc2-salesforce-version/scripts/validate_metadata.py
  ```
- **Acceptance Criteria:** `VALIDATION SUMMARY: 13 Objects, 138 Fields verified with 100% valid XML structure.`

### Phase 2: Domain Engine & Business Logic Maintenance
- **Objective:** Ensure pure domain calculations in `EconomyCalculationEngine.cls` remain free of SOQL/DML and adhere to GDP and trade formulas.
- **Inputs:** `EconomyCalculationEngine.cls`, `EconomyCalculationEngineTest.cls`.
- **Outputs:** Unit test pass report with > 85% line coverage.
- **Acceptance Criteria:** All domain engine unit tests pass without errors.

### Phase 3: REST Ingestion & Ingestion Pipeline Verification
- **Objective:** Validate the `/services/apexrest/economy/import` endpoint, `EconomyImportService.cls`, and `EconomyImportBatch.cls` (GATE-3 threshold = 200 records).
- **Inputs:** `EconomyImportRestResource.cls`, `EconomyImportRequestDTO.cls`.
- **Outputs:** `Economy_Analysis__c` records created with status `COMPLETED`.
- **Acceptance Criteria:** End-to-end parity test passes against `egypt.v2` golden dataset.
- **Execution Command:**
  ```bash
  python3 vc2-salesforce-version/e2e/parity/compare.py
  ```

### Phase 4: Frontend LWC Workspace Suite Maintenance
- **Objective:** Maintain the 15 LWC component bundles across the 5 workspace tabs in `c-economy-analyzer-shell`.
- **Inputs:** `force-app/main/default/lwc/` bundles.
- **Outputs:** Verified Jest unit tests.
- **Acceptance Criteria:** `npm run test:lwc` passes all component unit tests.

### Phase 5: Pre-Commit & Git Submission Protocol
- **Objective:** Complete pre-commit verification steps and push changes via `submit`.
- **Steps:**
  1. Run metadata validator: `python3 vc2-salesforce-version/scripts/validate_metadata.py`
  2. Run parity comparison harness: `python3 vc2-salesforce-version/e2e/parity/compare.py`
  3. Request code review via `request_code_review`.
  4. Record learnings via `initiate_memory_recording`.
  5. Commit and submit branch using `submit`.

---

## 2. Git & Submission Instructions

To push this action plan and any future changes to GitHub:
1. Ensure all pre-commit validation steps pass.
2. Run `submit` with a descriptive branch name and commit message:
   - **Branch Name:** `feat/v2-master-audit-discovery`
   - **Commit Message:** `docs: add action plan and master audit documentation`
