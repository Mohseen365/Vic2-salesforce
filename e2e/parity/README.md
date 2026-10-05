# End-to-End Parity Harness (`vc2-salesforce-version/e2e/parity/`)

This directory contains the deterministic parity comparison harness for Phase 10 validation. It verifies mathematical and domain parity between the Phase 0 Java Victoria 2 Economy Analyzer golden dataset and Salesforce-produced export bundles/DTOs without requiring a live Salesforce org connection.

---

## Directory Contents

- `compare.py`: Deterministic comparison tool enforcing Phase 10 Audit Section 2.2 tolerances.
- `fixtures/`:
  - `egypt_golden_bundle.json`: Baseline golden dataset bundle parsed from `egypt.v2`.
  - `salesforce_export_bundle.json`: Target export bundle representing Salesforce DTO/CSV output.
- `parity-report.json`: Machine-readable comparison output.
- `parity-report.md`: Markdown summary report detailing compared entities and discrepancies.

---

## Tolerances Applied (Section 2.2 Alignment)

- **Currency fields (GDP, Imports, Exports, Gold Income):** `±£0.01` (exact match to 2 decimal places).
- **Price / Quantity / Supply / Demand:** `±0.0001` (exact match to 4 decimal places).
- **Percentages (Inflation %, Overproduction %, GDP Share %, Unemployment %):** `±0.01 %` (exact match to 2 decimal places).
- **Population / Workforce / Employment / Ranks:** `Exact Integer Match` (deterministic tie-breaking: `GDP__c` descending, `Country_Tag__c` ascending).
- **Zero-by-Zero Safeguard:** `NaN` and `Infinity` inputs are sanitized to `0.0%`.

---

## How to Run the Parity Comparison Harness

### Default Run (Using Bundled Golden & Salesforce Fixtures)

```bash
python3 vc2-salesforce-version/e2e/parity/compare.py
```

### Custom Run (Specifying Input & Output Paths)

```bash
python3 vc2-salesforce-version/e2e/parity/compare.py \
  --golden vc2-salesforce-version/golden-dataset/golden-dataset.json \
  --target vc2-salesforce-version/e2e/parity/fixtures/salesforce_export_bundle.json \
  --out-json vc2-salesforce-version/e2e/parity/parity-report.json \
  --out-md vc2-salesforce-version/e2e/parity/parity-report.md
```

### Exit Codes

- `0`: Parity verification **PASSED** (0 discrepancies or only sanctioned redesigns).
- `1`: Parity verification **FAILED** (1 or more discrepancies exceeding tolerance).
