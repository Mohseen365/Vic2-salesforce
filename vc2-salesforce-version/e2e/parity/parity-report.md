# Victoria 2 Economy Analyzer — End-to-End Parity Verification Report

**Parity Verification Status:** `PASS`
**Total Discrepancies:** `0`
**Golden Dataset File:** `save-game-analyzer`
**Target Export File:** `save-game-analyzer`

## Summary of Compared Metrics

- **World Totals:** 4 metrics compared
- **Countries:** 118 entities compared
- **Products:** 48 entities compared
- **Country × Product Junctions:** 0 entities compared
- **Provinces:** 2701 entities compared
- **States:** 124 entities compared
- **Factories:** 714 entities compared
- **Artisans:** 4054 entities compared

## Tolerances Applied (Section 2.2 Alignment)

- Currency / Monetary Totals / GDP: `±0.01 £` (2 decimal places)
- Price / Quantity / Supply / Demand: `±0.0001` (4 decimal places)
- Percentages (Inflation, Overproduction, Share, Unemployment): `±0.01 %` (2 decimal places)
- Integer Counts (Population, Workforce, Employment, Ranks): `Exact Integer (0)`

## Discrepancy Inventory

✅ **Zero discrepancies detected.** Full mathematical and semantic parity verified against Java Victoria 2 Economy Analyzer golden dataset.

## States Scope
- **Compared:** 124 records
- **Discrepancies:** 0
- **Status:** PASS

## Factories Scope
- **Compared:** 714 records
- **Discrepancies:** 0
- **Status:** PASS

## Artisans Scope
- **Compared:** 4054 records
- **Discrepancies:** 0
- **Status:** PASS

## Provinces Scope
- **Compared:** 2701 records
- **Discrepancies:** 0
- **Status:** PASS

---
*Generated automatically by `vc2-salesforce-version/e2e/parity/compare.py`*
