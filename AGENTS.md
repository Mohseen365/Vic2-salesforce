# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Handoff State

- **Current Status:** Phase 1 (Data Model Setup) is **VERIFIED AND COMPLETE**.
- **Data Model Inventory:** `vc2-salesforce-version/field-inventory.md`
- **Schema Summary:** 8 Custom Objects, 72 Custom Fields across Master Data and Snapshot Data.
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

## Data Model & Schema Summary (Phase 1 Complete)

1. **Master Objects:**
   - `Country__c` (Tag__c External ID Unique)
   - `Product__c` (Code__c External ID Unique)
   - `Province__c` (External_Province_Id__c External ID Unique, Lookup to Country__c)

2. **Snapshot Objects:**
   - `Economy_Analysis__c` (Save_File_Name__c External ID Unique, Roll-Up Summaries for World GDP, Population, Imports, Exports)
   - `Country_Economy__c` (Master-Detail to Economy_Analysis__c, Lookup to Country__c, Formulas for Unemployment Rates, GDP Share %, GDP Per Capita)
   - `Product_Economy__c` (Master-Detail to Economy_Analysis__c, Lookup to Product__c, Formulas for Inflation %, Overproduction %)
   - `Country_Product_Economy__c` (Master-Detail to Country_Economy__c, Lookup to Product_Economy__c and Product__c)
   - `Province_Economy__c` (Master-Detail to Country_Economy__c, Lookup to Province__c)

---

## Resolved Architecture Gates & Formulas

1. **Product Overproduction Formula:**
   - Formula Field: `IF(Real_Demand__c > 0, (Total_World_Supply__c / Real_Demand__c) * 100, 0.0)`
   - Source Method: `Product.getOverproduced()`

2. **GDP Contribution & Country GDP Formula:**
   - `sold_units = soldDomestic + (thrownToMarket * actualSoldWorld / worldmarketPool)`
   - `ProductStorage GDP (£) = max(sold_units - intermediate_consumption, 0) * product.price`
   - `Country Total GDP (£) = sum(ProductStorage.getGdpPounds()) + goldIncome`
   - Source Methods: `ProductStorage.innerCalculations()`, `Country.innerCalculations()`

3. **Parser Architecture:**
   - Architecture: Option A (External Off-Heap EUG Parser Service transmitting normalized JSON DTOs to Salesforce REST endpoint `EconomyImportService`).
   - Native Apex Clausewitz parsing is out of scope due to governor limits.

---

## Confirmed Legacy Quirks

1. **GDP Per Capita Scaling Multiplier (`100,000`):** `IF(Population__c > 0, (GDP__c / Population__c) * 100000, 0.0)` where population = `popSize * 4`.
2. **Precious Metals / Gold Special Handling:** RGO income (`last_income / 1000`) is tracked in `Gold_Income__c` and added directly to country GDP; precious metals skip world market exports.
3. **World Market Allocation Order:** Legacy analyzer reads post-allocation state directly from save file nodes rather than simulating GP allocation order.

---

## Mandatory Rules for Phase 2 (Core Apex Service & Calculation Engine)

- Do **not** alter economic formulas or substitute Audit Document simplified formulas for legacy Java formulas.
- Apex calculations must populate `GDP_Contribution__c` on `Country_Product_Economy__c` using Gate 2 formula: `Math.max(sold_units - intermediate_consumption, 0) * price`.
- Apex calculations must write total `GDP__c` on `Country_Economy__c` as `sum(GDP_Contribution__c) + Gold_Income__c`.
- Apex calculations must rank countries by GDP (`GDP_Rank__c`).
- Ensure all queries filter and bulkify appropriately using indexed external ID fields (`Unique_Snapshot_Key__c`, `Save_File_Name__c`).
