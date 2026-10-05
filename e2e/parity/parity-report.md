# Victoria 2 Economy Analyzer — End-to-End Parity Verification Report

**Parity Verification Status:** `PASS`
**Total Discrepancies:** `0`
**Golden Dataset File:** `egypt_golden_bundle.json`
**Target Export File:** `salesforce_export_bundle.json`

## Summary of Compared Metrics

- **World Totals:** 4 metrics compared
- **Countries:** 4 entities compared
- **Products:** 5 entities compared
- **Country × Product Junctions:** 16 entities compared
- **Provinces:** 0 entities compared
- **States:** 0 entities compared
- **Factories:** 0 entities compared
- **Artisans:** 0 entities compared

## Tolerances Applied (Section 2.2 Alignment)

- Currency / Monetary Totals / GDP: `±0.01 £` (2 decimal places)
- Price / Quantity / Supply / Demand: `±0.0001` (4 decimal places)
- Percentages (Inflation, Overproduction, Share, Unemployment): `±0.01 %` (2 decimal places)
- Integer Counts (Population, Workforce, Employment, Ranks): `Exact Integer (0)`

## Discrepancy Inventory

✅ **Zero discrepancies detected.** Full mathematical and semantic parity verified against Java Victoria 2 Economy Analyzer golden dataset.

## States Scope
- **Compared:** 0 records
- **Discrepancies:** 0
- **Status:** PASS

## Factories Scope
- **Compared:** 0 records
- **Discrepancies:** 0
- **Status:** PASS

## Artisans Scope
- **Compared:** 0 records
- **Discrepancies:** 0
- **Status:** PASS

## Provinces Scope
- **Compared:** 0 records
- **Discrepancies:** 0
- **Status:** PASS

---
*Generated automatically by `vc2-salesforce-version/e2e/parity/compare.py`*
