# 20. System Test Strategy and Verification Harness

## Overview
This document specifies the multi-layered testing strategy ensuring system correctness, governor limit safety, and golden dataset parity.

---

## Test Execution Matrix

### 1. Apex Unit & Integration Tests (21 Test Classes)
- **Execution Command:** Apex Test Runner in SFDX.
- **Coverage Target:** > 85% line coverage across all Apex classes.
- **Key Test Classes:**
  - `EconomyCalculationEngineTest.cls`: Pure unit tests for GDP and trade math.
  - `EconomyImportIntegrationTest.cls`: End-to-end REST API ingestion test.
  - `EconomyImportBatchTest.cls`: Async batch processing for high volume records.
  - `EconomyGovernorLimitTest.cls`: Bulk processing and heap limit validation.

### 2. LWC Jest Unit Suite (15 Component Suites, 72 Unit Tests)
- **Execution Command:** `npm run test:lwc`
- **Pass Rate Requirement:** 100% pass rate across all 72 component tests.

### 3. End-to-End Parity Verification Harness
- **Execution Command:** `python3 vc2-salesforce-version/e2e/parity/compare.py`
- **Parity Criterion:** 0 discrepancies across all scopes compared against Phase 0 Golden Dataset.

### 4. Metadata Structure Validator
- **Execution Command:** `python3 vc2-salesforce-version/scripts/validate_metadata.py`
- **Validation Target:** 13 Custom Objects and 138 Custom Fields XML structure integrity.
