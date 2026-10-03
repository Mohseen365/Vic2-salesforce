# Phase 0 (Legacy Behavior Freeze & Golden Dataset) Completion & Handoff Report

## Summary of Accomplishments
- **Golden Dataset Artifacts Verified:**
  - `vc2-salesforce-version/golden-dataset/manifest.json`
  - `vc2-salesforce-version/golden-dataset/formula-notes.md`
  - `vc2-salesforce-version/golden-dataset/validation-report.md`
  - `vc2-salesforce-version/golden-dataset/README.md`
  - `vc2-salesforce-version/golden-dataset/raw/` (`save-metadata.json`, `countries.json`, `provinces.json`, `products.json`, `product-storage.json`, `economy-subjects.json`)
  - `vc2-salesforce-version/golden-dataset/derived/` (`country-calculations.json`, `product-calculations.json`, `product-storage-calculations.json`, `report-calculations.json`)
  - `vc2-salesforce-version/golden-dataset/expected/` (`apex-golden-results.json`)
  - `vc2-salesforce-version/golden-dataset/csv/` (`countries.csv`, `provinces.csv`, `products.csv`, `product-storage.csv`, `calculations.csv`)
  - `vc2-salesforce-version/golden-dataset/source/` (`parser-invocation.md`, `extraction-summary.md`)
  - `vc2-salesforce-version/golden-dataset/verification/` (`determinism-diff.txt`)
- **Representative Save Games Analyzed:**
  - `egypt.v2` (Path: `/tmp/file_attachments/savegames/egypt.v2`, Size: 27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`, Mod: Base Game Vanilla)
- **Phase 0 Handoff Status:** **VERIFIED, GATES RESOLVED, HANDOFF READY**

---

## Technical Details & Golden Dataset State

### Golden Dataset Directory Structure
```text
vc2-salesforce-version/golden-dataset/
├── README.md                          # Handoff developer guide
├── manifest.json                      # Machine-readable dataset manifest
├── formula-notes.md                   # Authoritative legacy formula audit
├── validation-report.md               # Pipeline validation report
├── phase-0-completion-report.md       # Final completion & handoff report
├── raw/                               # RAW parsed save nodes
│   ├── save-metadata.json
│   ├── countries.json
│   ├── provinces.json
│   ├── products.json
│   ├── product-storage.json
│   └── economy-subjects.json
├── derived/                           # DERIVED domain calculations
│   ├── country-calculations.json
│   ├── product-calculations.json
│   ├── product-storage-calculations.json
│   └── report-calculations.json
├── expected/                          # Apex regression test targets
│   └── apex-golden-results.json
├── csv/                               # Human-readable CSV representations
│   ├── countries.csv
│   ├── provinces.csv
│   ├── products.csv
│   ├── product-storage.csv
│   └── calculations.csv
├── source/                            # Execution and extraction pipelines
│   ├── parser-invocation.md
│   └── extraction-summary.md
└── verification/                      # Determinism and integrity logs
    └── determinism-diff.txt
```

### Verified Record Counts
- **Countries:** 118
- **Provinces:** 3,248
- **Products:** 49
- **Product Storages (Country × Product Junctions):** 3,772
- **Derived Calculation Records:** 3,940

### Structural Integrity & Determinism Results
- **JSON & CSV Validation:** All JSON files pass strict syntax validation. CSV header schemas match JSON keys.
- **Referential Integrity:** 100% of `countryTag` and `productName` keys in `product-storage.*` exist in `countries.*` and `products.*`.
- **Determinism Check:** Re-running `GoldenDatasetExporterMain` against `egypt.v2` into a temporary directory produced a **byte-for-byte deterministic match** across all generated artifacts (logged in `verification/determinism-diff.txt`).

### Section G Coverage
- **RAW Values Coverage:** 100% (Ingame Date, Start Date, Country Tag, Product Code, Population, Workforces, Employment, Production Qty, Prices, Supply Pools, Gold Income).
- **DERIVED Values Coverage:** 100% (Unemployment Rates, GDP Per Capita, Inflation %, Overproduction %, Import/Export Values, Country GDP, GDP Share, GDP Rank, World Totals).

---

## Resolved Architecture-Review Gates

### Gate 1: Overproduction Formula
- **Resolved Version:** `Overproduction % = (supply_pool / real_demand) * 100`
- **Source Method:** `Product.getOverproduced()`
- **Formula Phase 1 Must Use (`Overproduction_Percent__c`):**
  `IF(Real_Demand__c > 0, (Total_World_Supply__c / Real_Demand__c) * 100, 0.0)`

### Gate 2: GDP Contribution & Country GDP Formula
- **Resolved Version:**
  $$\text{sold} = \text{soldDomestic} + \left( \text{thrownToMarket} \times \frac{\text{actualSoldWorld}}{\text{worldmarketPool}} \right)$$
  $$\text{ProductStorage GDP (£)} = \max(\text{sold} - \text{intermediate\_consumption}, 0) \times \text{product.price}$$
  $$\text{Country Total GDP (£)} = \sum \text{ProductStorage.gdpPounds} + \text{goldIncome}$$
- **Source Methods:** `ProductStorage.innerCalculations()`, `ProductStorage.getGdpPounds()`, `Country.innerCalculations()`
- **Formula Phase 2 Engine Must Implement:** `EconomyCalculationEngine.cls` must allocate `sold` units, subtract intermediate consumption, clamp to non-negative before multiplying by price, and add direct RGO gold income.

### Gate 3: Parser Architecture
- **Resolved Version:** Option A (External Off-Heap EUG Parser Service transmitting normalized JSON DTOs to Salesforce REST endpoint `EconomyImportService`).
- **Scope Rule:** Native Apex Clausewitz parser is out of scope due to Apex governor limits.

---

## Confirmed Legacy Quirks

1. **GDP Per Capita Scaling Multiplier (`100,000`):** `(gdp / population) * 100000` (where population = `popSize * 4`).
2. **Gold / Precious Metals Special Handling:** Precious metal RGO output (`last_income / 1000`) bypasses world market exports and flows into `goldIncome` which directly adds to country GDP.
3. **World Market Allocation Order:** Legacy analyzer reads post-allocation state directly from save file nodes (`saved_country_supply`, `domestic_demand_pool`, `actual_sold_domestic`, `price_pool`, `actual_sold_world`, `worldmarket_pool`).

---

## Open Items / Carried-Forward Risks

- **Division-by-Zero in Unhandled Legacy Fields:** Floating-point division by zero in unhandled Java code produces `Float.NaN` or `Float.POSITIVE_INFINITY`. In Salesforce Apex and Formula fields, explicit `IF(Denominator > 0, ..., 0.0)` checks are mandatory.
- **EGY Tag Regional Status:** In `egypt.v2`, `EGY` tag is an unowned tag node (no active provinces/states). Region is controlled by `TUR` (Ottoman Empire).

---

## Critical Context for Phase 1 (Data Model Setup)

### Custom Fields and External IDs Implied by Golden Dataset
- `Economy_Analysis__c`: `Save_File_Name__c` (External ID), `Ingame_Date__c`, `Analysis_Date__c`, `Total_World_GDP__c`
- `Country__c`: `Tag__c` (External ID Master), `Name__c`
- `Country_Economy__c`: `Country__c` (Lookup/Master-Detail), `Economy_Analysis__c` (Master-Detail), `GDP__c`, `GDP_Per_Capita__c`, `GDP_Share_Percent__c`, `GDP_Rank__c`, `Unemployment_Rate_RGO__c`, `Unemployment_Rate_Factory__c`, `Gold_Income__c`
- `Product__c`: `Code__c` (External ID Master), `Name__c`, `Base_Price__c`
- `Product_Economy__c`: `Product__c` (Lookup/Master-Detail), `Economy_Analysis__c` (Master-Detail), `World_Price__c`, `Inflation_Percent__c`, `Overproduction_Percent__c`, `Total_World_Supply__c`, `Real_Demand__c`
- `Country_Product_Economy__c`: `Country_Economy__c` (Master-Detail), `Product__c` (Lookup), `Sold_Domestic__c`, `Total_Supply_Pounds__c`, `Actual_Supply_Pounds__c`, `Actual_Demand_Pounds__c`, `Import_Value__c`, `Export_Value__c`, `GDP_Contribution__c`

### Prerequisites Checklist Before Starting Phase 1
- [x] Golden dataset verified and deterministic
- [x] Architecture review gates resolved
- [x] Legacy quirks documented
- [x] AGENTS.md updated with Phase 1 constraints
