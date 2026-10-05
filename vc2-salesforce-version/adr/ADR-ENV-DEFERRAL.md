# ADR-ENV-DEFERRAL: Deferral of Environment Verification to Final Gate

## Status
PROPOSED — pending human ratification

## Context
- Phase 2B (original) claimed 8/8/0 Apex tests and 100% coverage.
- Phase 2C could not reproduce this: SF CLI unavailable, no JUnit XML.
- Phase 2D confirmed SF CLI is absent and no authenticated org is reachable
  from the working container.
- Phase 2B-Redux re-verified the same finding: `sf: command not found`,
  `sfdx: command not found`.
- Phase 2B and Phase 2B-Redux are therefore RETRACTED as evidence.
- Installing the Salesforce CLI and authenticating an org cannot be done
  inside the current container. The required action is environment-level
  (runner image or workstation), not repository-level.

## Decision
- Environment-dependent verification is DEFERRED to a single bounded
  "Phase 5.5 — Environment Verification Gate" that must be executed
  before submission is considered complete.
- Phases 2E (this), 2F, and any static analysis work proceed without an org.
- The final gate must execute, at minimum:
    (a) SF CLI version check
    (b) `sf org list` — must show at least one authenticated org
    (c) `sf apex run test --class-names EconomyCalculationEngineTest --code-coverage --result-format junit`
         → tests_failed = 0 AND coverage ≥ 85%
    (d) POST the `egypt.v2` DTO to /services/apexrest/economy/import
    (e) `python3 e2e/parity/compare.py` → 0 discrepancies
    (f) `python3 e2e/parity/test_csv_export_parity.py` → PASS
- If any item in (a)–(f) fails, the gate fails and submission is BLOCKED.
- Until the gate passes, the project state is:
    "Designed, documented, statically verified — not yet executed
     against a Salesforce org."

## Consequences
- No further Phase 2/3/5 exit may be claimed as PASS until the gate runs.
- The 24 audit documents, schema, engine, and pipeline remain valid
  deliverables regardless of gate outcome.
- A subsequent ADR is required after the gate to record its result
  and either close the deferral or open remediation.

## Ratification
- Architect: __________________ Date: __________
- QA Lead:   __________________ Date: __________
- Product:   __________________ Date: __________
