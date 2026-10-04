# 23. Dependency-Aware Implementation Roadmap

## Overview
The implementation roadmap outlines the sequential phases for building, verifying, and deploying the Victoria 2 Salesforce system.

---

## Sequential Implementation Phases

### Phase 0: Discovery & Forensic Audit (CURRENT PHASE)
- **Objective:** Forensic inspection of `egypt.v2`, repository metadata audit, and baseline parity definition.
- **Deliverables:** 24 Master Audit Documents (`01_V2_...` to `24_FINAL_...`).

### Phase 1: Canonical Data Model & Schema Freeze
- **Objective:** Finalize 13 Custom Objects and 138 Custom Fields in Salesforce metadata.
- **Deliverables:** `force-app/main/default/objects/` XML definitions.

### Phase 2: Domain Engine & Calculations
- **Objective:** Implement pure domain calculation engine in `EconomyCalculationEngine.cls`.
- **Deliverables:** Unit test suite verifying GDP math and trade formulas.

### Phase 3: REST Ingestion & Import Pipeline
- **Objective:** Deploy `EconomyImportRestResource.cls`, `EconomyImportService.cls`, and `EconomyImportBatch.cls`.
- **Deliverables:** Verified endpoint returning 201 Created and 202 Accepted for batch jobs.

### Phase 4: LWC Workspace Suite
- **Objective:** Deploy 15 LWC bundles across 5 main workspace tabs in `c-economy-analyzer-shell`.
- **Deliverables:** Interactive UI with SVG charts and search filters.

### Phase 5: Production Hardening & Parity Verification
- **Objective:** Run E2E parity harness, validate zero discrepancies, and complete pre-commit checks.
- **Deliverables:** Passed parity report and production-ready SFDX package.
