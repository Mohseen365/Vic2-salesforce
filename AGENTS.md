# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 2 (Core Apex Service & Calculation Engine) is **VERIFIED AND COMPLETE**.
- **Golden Dataset Reference Location:** `vc2-salesforce-version/golden-dataset/`
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)

---

## Verified Golden Dataset Metrics & Record Counts

- **Countries:** 118
- **Provinces:** 3,248
- **Products:** 49
- **Product Storages (Country × Product Junctions):** 3,772
- **Derived Calculation Records:** 3,940
- **Validation Status:** PASS (Integrity and byte-for-byte output determinism verified)

---

## Resolved Architecture Gates & Formulas

1. **Product Overproduction Formula:**
   - Authoritative Formula: `(Total_World_Supply__c / Real_Demand__c) * 100` (when `Real_Demand__c > 0`, else `0.0`).
   - Source Method: `Product.getOverproduced()`

2. **GDP Contribution & Country GDP Formula:**
   - Authoritative Formula: `sold_units = soldDomestic + thrownToMarket * actualSoldWorld / worldmarketPool`.
   - `ProductStorage GDP (£) = max(sold_units - intermediate_consumption, 0) * product.price`.
   - `Country Total GDP (£) = sum(ProductStorage.getGdpPounds()) + goldIncome`.
   - Source Methods: `ProductStorage.innerCalculations()`, `Country.innerCalculations()`

3. **Parser Architecture:**
   - Authoritative Architecture: Option A (External Off-Heap EUG Parser Service transmitting normalized JSON DTOs to Salesforce REST endpoint `EconomyImportService`).
   - Constraint: Native Apex Clausewitz parsing is out of scope due to Apex governor limits.

---

## Engine API Surface (`EconomyCalculationEngine.cls`)

- `public static void calculateProductStorageContributions(List<Country_Product_Economy__c> junctions, Map<Id, Product_Economy__c> productEconomyById)`
- `public static void calculateCountryTotals(List<Country_Economy__c> countries, Map<Id, List<Country_Product_Economy__c>> junctionsByCountryId)`
- `public static void assignGdpRanks(List<Country_Economy__c> countries)`
- `public static void calculateAnalysisTotals(Economy_Analysis__c analysis, List<Country_Economy__c> countries)`
- `public static Decimal safeDivide(Decimal numerator, Decimal denominator, Decimal fallback)`

---

## Confirmed Legacy Quirks & Engine Implementation Details

1. **GDP Per Capita Scaling Multiplier (`100,000`):** Preserved in Phase 1 Formula Field `Country_Economy__c.GDP_Per_Capita__c`.
2. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `Gold_Income__c` and added directly to country GDP; `precious_metal` product skips world market exports (`Export_Value__c = 0.0`).
3. **World Market Allocation Order:** Engine reads stored post-hoc quantities (`Sold_Domestic__c`, `Thrown_To_Market__c`, `Actual_Sold_World__c`, `Worldmarket_Pool__c`) without simulation.
4. **Ranking Tie-Breaker:** GDP sorting is deterministic: primary sort `GDP__c` descending, tie-breaker `Country_Tag__c` ascending.

---

## Rules for Phase 3 (Data Selectors & DTO Layer)

- Service layer calls `EconomyCalculationEngine` pure methods with retrieved SObject lists/DTO maps.
- Selectors must enforce `with sharing` and user CRUD/FLS accessibility checks (`Security.stripInaccessible`).
- Selectors must query all fields required by `EconomyCalculationEngine`:
  - `Country_Product_Economy__c`: `Product_Economy__c`, `Product_Code__c`, `Sold_Domestic__c`, `Bought_Quantity__c`, `Thrown_To_Market__c`, `Actual_Sold_World__c`, `Worldmarket_Pool__c`, `Intermediate_Consumption__c`.
  - `Product_Economy__c`: `Price__c`, `Product_Code__c`.
  - `Country_Economy__c`: `Gold_Income__c`, `Country_Tag__c`, `Total_Imports_Value__c`, `Total_Exports_Value__c`.
  - `Economy_Analysis__c`: `Total_World_Imports__c`, `Total_World_Exports__c`.
- Do NOT recompute Phase 1 formula fields (`GDP_Per_Capita__c`, `GDP_Share_Percent__c`, `Unemployment_Rate__c`, `Overproduction_Percent__c`, `Inflation_Percent__c`) or roll-up summaries (`Total_World_GDP__c`, `Total_World_Population__c`, `Total_Imports_Value__c`, `Total_Exports_Value__c`).
