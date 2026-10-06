# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phases 0 through 6 Planning, UX Architecture, and Prompt Pipelines are FULLY COMPLETE AND VERIFIED.**
- **Master Consolidated Planning Document:** [`Victoria 2 Save-Game Salesforce Application — Master Consolidated Planning Document.md`](./Victoria%202%20Save-Game%20Salesforce%20Application%20—%20Master%20Consolidated%20Planning%20Document.md)
- **UX-UI Command Center Architecture:** [`Victoria 2 Command Center: UX-UI Possibility Map & LWC Component Architecture.md`](./Victoria%202%20Command%20Center:%20UX-UI%20Possibility%20Map%20&%20LWC%20Component%20Architecture.md)
- **Context Retrieval & Audit Summary:** [`AUDIT_AND_IMPLEMENTATION_SUMMARY.md`](./AUDIT_AND_IMPLEMENTATION_SUMMARY.md)
- **Phase Execution Index:** [`PHASE_EXECUTION_INDEX.md`](./PHASE_EXECUTION_INDEX.md)
- **Semantic Contract Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Import Contract Reference:** [`vc2-salesforce-version/IMPORT_CONTRACT.md`](./vc2-salesforce-version/IMPORT_CONTRACT.md)
- **Golden Dataset Location:** `vc2-salesforce-version/golden-dataset/` & `vc2-salesforce-version/golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`vc2-salesforce-version/golden-dataset/manifest.json`](./vc2-salesforce-version/golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all scopes)
- **Protected Economy Baseline Hash:** `976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38` (100% bit-for-bit match verified)

---

## Architecture & Track Status Summary

- **Track A (Economy Core Migration):** `COMPLETE — ATTESTED`
- **Track B (Full Save-Game Model Expansion):** `COMPLETE — ATTESTED` (139 custom objects, 997 fields verified)
- **Track C (Data Model Quality & Permissions):** `COMPLETE — ATTESTED` (`Economy_Analyzer_User` and `Economy_Analyzer_Admin` permission sets provisioned)
- **Track D (Capabilities, Derived Metrics & Platform Extensions):** `COMPLETE — ATTESTED`
- **Track E (Remediation & Governance):** `COMPLETE — ATTESTED` (0 defects remaining)
- **UX/UI Command Center Architecture:** `COMPLETE — ATTESTED` (15 LWC component bundles verified)
- **Phase 0–6 Execution Pipelines:** `COMPLETE — ATTESTED`

---

## Core Documentation Artifacts & Pointers

1. 📜 **Master Planning Document:** [`Victoria 2 Save-Game Salesforce Application — Master Consolidated Planning Document.md`](./Victoria%202%20Save-Game%20Salesforce%20Application%20—%20Master%20Consolidated%20Planning%20Document.md)
2. 🎨 **UX-UI Command Center Map:** [`Victoria 2 Command Center: UX-UI Possibility Map & LWC Component Architecture.md`](./Victoria%202%20Command%20Center:%20UX-UI%20Possibility%20Map%20&%20LWC%20Component%20Architecture.md)
3. 📊 **Audit & Summary Report:** [`AUDIT_AND_IMPLEMENTATION_SUMMARY.md`](./AUDIT_AND_IMPLEMENTATION_SUMMARY.md)
4. 📑 **Phase Execution Index:** [`PHASE_EXECUTION_INDEX.md`](./PHASE_EXECUTION_INDEX.md)
5. 📜 **Semantic Contract:** [`vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./vc2-salesforce-version/SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
6. 📋 **Audit Compliance Matrix:** [`vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md`](./vc2-salesforce-version/AUDIT_COMPLIANCE_MATRIX.md)
7. 📄 **Migration Completion Report:** [`vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md`](./vc2-salesforce-version/MIGRATION_COMPLETION_REPORT.md)
8. 📖 **Maintenance Runbook:** [`vc2-salesforce-version/MAINTENANCE_RUNBOOK.md`](./vc2-salesforce-version/MAINTENANCE_RUNBOOK.md)
9. ⚖️ **Parity Verification Report:** [`e2e/parity/parity-report.md`](./e2e/parity/parity-report.md)
10. 🔒 **Security & Governance:** [`SECURITY_HARDENING_REPORT.md`](./SECURITY_HARDENING_REPORT.md)

---

## Maintenance & Test Execution Guidelines

- **Run LWC Jest Suite:** `npm run test:lwc`
- **Run Parity Verification Harness:** `python3 e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 scripts/validate_metadata.py`
- **Run Track D Audit Verification:** `python3 scripts/run_track_d_phase1_audit.py`
