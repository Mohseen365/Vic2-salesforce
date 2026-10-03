# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 0 (Legacy Behavior Freeze & Golden Dataset Verification) is **VERIFIED AND COMPLETE**.
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

## Confirmed Legacy Quirks

1. **GDP Per Capita Scaling Multiplier (`100,000`):** Formula is `(gdp / population) * 100000` where `population` is total individual humans (`popSize * 4`).
2. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `goldIncome` and added directly to country GDP; `precious_metal` skips world market exports.
3. **World Market Allocation Order:** Legacy analyzer reads post-allocation state directly from save file nodes rather than simulating GP allocation order.

---

## Mandatory Constraints & Rules for Phase 1 (Data Model Setup)

- Do **not** alter economic formulas or substitute Audit Document simplified formulas for legacy Java formulas.
- All formula fields must enforce division-by-zero safeguards using `IF(Denominator > 0, ..., 0.0)`.
- Custom object field precision must use **Precision 18, Scale 4** for prices/quantities and **Scale 2** for total currency/percentages.
- Use Master-Detail relationships for `Country_Economy__c`, `Product_Economy__c`, and `Country_Product_Economy__c` under parent `Economy_Analysis__c`.
