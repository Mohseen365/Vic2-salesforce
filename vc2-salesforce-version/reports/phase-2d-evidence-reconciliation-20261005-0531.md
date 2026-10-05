# Phase 2D — Test Evidence Reconciliation & GDP Amendment Specification

## 1. Item A — Phase 2B Evidence Reconciliation
- 2B command (verbatim): `sf apex run test --class-names EconomyCalculationEngineTest --code-coverage --result-format human --wait 10`
- 2B target-org flag present: NO
- Current Default Org / Config:
  - `sf org list`: `-bash: sf: command not found`
  - `sf config get target-org`: `-bash: sf: command not found`
  - Note: Salesforce CLI (`sf` / `sfdx`) is not installed in the environment container.
- 2B JUnit XML found: NONE
  - Search command: `find vc2-salesforce-version/reports -name "*.xml" -newermt "2026-10-04 20:30"`
  - Result: 0 files found.
- Verdict: UNRESOLVED
- If re-run:
  - Command: N/A (Cannot run `sf apex run test`; Salesforce CLI binary `sf` is missing and no target org connection exists in container environment)
  - Tests run / passed / failed: 0/0/0
  - Engine line coverage: 0%
  - JUnit XML path: NONE

## 2. Item B — Cited Evidence Produced

### B1 formula-notes.md
- Path exists: yes (`vc2-salesforce-version/formula-notes.md`)
- Verbatim lines 1-200:
```
     1	# Formula & Calculation Reference
     2
     3	This document provides a single reference for all economic formulas, legacy Java implementation details, and Salesforce field mapping logic for the Victoria 2 → Salesforce Economy Analyzer conversion.
     4
     5	---
     6
     7	## 1. Executive Summary & Audit Resolution Matrix
     8
     9	During initial audit phases (Phase 0, Phase 1, Phase 2), several formula discrepancies and architectural questions were raised across audit documents (`10_DATA_TO_STORE_VS_DERIVE.md`, `13_SALESFORCE_FIELD_LINEAGE.md`, etc.). This section summarizes the authoritative resolutions validated against the original Java save game analyzer codebase.
    10
    11	| Audit Topic | Audit Document Statement | Java Source Reference | Authoritative Resolution | Status |
    12	| :--- | :--- | :--- | :--- | :--- |
    13	| **Overproduction Formula** | `(supply - demand) / demand` or `(supply / max_demand)` | `Product.getOverproduced()`: `(supply / demand) * 100` | Overproduction % is defined as `(supply_pool / real_demand) * 100`. Returns `0.0` if `real_demand == 0`. | **Resolved** |
    14	| **Country GDP Definition** | `Factory_GDP + Province_GDP + Artisan_GDP` | `Country.innerCalculations()` & `ProductStorage.innerCalculations()` | Country GDP = `sum(ProductStorage.getGdpPounds()) + goldIncome`. Includes intermediate goods subtraction. | **Resolved** |
    15	| **Precious Metals Handling** | Treated as standard commodity market output | `Report.loadProvince()`, `ProductStorage.innerCalculations()` | Gold generates direct `goldIncome` (£) from RGOs. Market exported/imported pounds for `precious_metal` is set to `0`. | **Resolved** |
    16	| **Unemployment Formula** | `(unemployed / total_pop)` | `Country.getUnemploymentRateRgo()`, `getUnemploymentRateFactory()` | Calculated separately for RGO workforce and Factory workforce. | **Resolved** |
    17	| **Parser Architecture** | Native Apex Clausewitz Parser (Option B) vs Off-heap External EUG (Option A) | `save-game-analyzer` Java parser | Off-heap EUG parser (Option A) is required due to Apex governor limits. | **Resolved** |
    18
    19	---
    20
    21	## 2. Detailed Audit Discrepancy Analysis & Proofs
    22
    23	### Gate 1: Overproduction Formula Ambiguity
    24
    25	- **Audit Document Statement:** Section D lists `Overproduction % = (supply - demand) / demand * 100` or `(supply / max_demand)`.
    26	- **Legacy Java Implementation (`Product.java`):**
    27	  ```java
    28	  public float getOverproduced() {
    29	      if (demand == 0) return 0;
    30	      return (supply / demand) * 100;
    31	  }
    32	  ```
    33	  - Here, `supply` represents `supply_pool` (total world supply pool) and `demand` represents `real_demand` (realized global demand) parsed from `worldmarket`.
    34	  - **Salesforce Target Implementation:**
    35	    - Apex Service / Formula calculation must compute `(Total_World_Supply__c / Real_Demand__c) * 100` when `Real_Demand__c > 0`.
    36	    - If `Real_Demand__c == 0` or null, the safeguard must return `0.0`.
    37	    - Note: If Phase 2 calculations require net overproduction ratio relative to max demand, both fields can be provided, but the core legacy `overproduced` metric maps strictly to `(supply / demand) * 100`.
    38
    39	### Gate 2: GDP Contribution & Country GDP Formula Ambiguity
    40
    41	- **Audit Document Statement:** Section D lists `gdpContrib = domesticSales + exportValue` where `domesticSales = (supply - sold) * product.price`.
    42	- **Legacy Java Implementation (`ProductStorage.java`, `Country.java`, `Report.java`):**
    43	  - In `Report.loadCountry()` / `loadProvince()`, intermediate goods consumption from factory and artisan stockpiles is subtracted from product GDP:
    44	    ```java
    45	    storage.incGdp(-value);
    46	    ```
    47	  - In `ProductStorage.innerCalculations()`:
    48	    ```java
    49	    float thrownToMarket = (totalSupply - soldDomestic);
    50	    if (thrownToMarket <= 0)
    51	        sold = totalSupply;
    52	    else if (product.name.equalsIgnoreCase("precious_metal"))
    53	        sold = totalSupply;
    54	    else if (product.worldmarketPool > 0)
    55	        sold = soldDomestic + thrownToMarket * product.actualSoldWorld / product.worldmarketPool;
    56	    else
    57	        sold = soldDomestic;
    58
    59	    gdp += sold; // gdp was initialized to (-intermediate_consumption)
    60	    gdp = Math.max(gdp, 0); // clamped to >= 0
    61	    ```
    62	  - In `ProductStorage.getGdpPounds()`:
    63	    ```java
    64	    return gdp * product.price;
    65	    ```
    66	  - In `Country.innerCalculations()`:
    67	    ```java
    68	    gdp += productStorage.getGdpPounds();
    69	    ```
    70	  - In `loadProvince()` for RGOs:
    71	    ```java
    72	    if (output.getName().equalsIgnoreCase("precious_metal"))
    73	        owner.addGoldIncome((float) lastIncome); // last_income / 1000
    74	    ```
    75	- **Authoritative Resolution:**
    76	  - Product-level GDP in pieces equals `max(sold_units - intermediate_consumption_units, 0)`.
    77	  - Product-level GDP in pounds equals `product_gdp_units * product.price`.
    78	  - Country total GDP in pounds equals `sum(ProductStorage.getGdpPounds()) + goldIncome`.
    79	  - `goldIncome` is the direct treasury revenue in pounds derived from precious metal RGOs (`last_income / 1000`).
    80
    81	### Gate 3: Parser Architecture Confirmation
    82
    83	- **Audit Document Confirmation:** Section J confirms the external EUG parser (Option A) as the primary production architecture for 15MB–120MB `.v2` save game files.
    84	- **Authoritative Resolution:**
    85	  - Victoria 2 save game files (15–120 MB) cannot be parsed synchronously or natively inside Apex due to governor limits (heap size, CPU execution time, regex limit).
    86	  - The off-heap external parser parses the `.v2` file using `eug.parser`, extracts normalized DTO payloads (Countries, Products, ProductStorages, World Market Totals), and POSTs the structured JSON payload to the Salesforce REST endpoint (`EconomyImportService`).
    87	  - Native chunked Apex (Option B) is strictly an optional fallback for small preprocessed payloads.
    88	  - **Phase 0 Rule:** Phase 0 confirms Option A architecture and does **not** author any Apex Clausewitz parser.
    89
    90	---
    91
    92	## 3. Comprehensive Formula & Calculation Matrix
    93
    94	| Entity | Field / Metric | Java Source Class / Method | Legacy Formula | Division-by-Zero Risk & Safeguard | Salesforce Execution Location |
    95	| :--- | :--- | :--- | :--- | :--- | :--- |
    96	| **Product** | Min Price | `Product.getMinPrice()` | `basePrice / 5` | None | Formula / Apex |
    97	| **Product** | Max Price | `Product.getMaxPrice()` | `basePrice * 5` | None | Formula / Apex |
    98	| **Product** | Inflation % | `Product.getInflation()` | `(price / basePrice) * 100` | `basePrice == 0` -> `0.0` | Formula Field (`Product_Economy__c`) |
    99	| **Product** | Overproduction % | `Product.getOverproduced()` | `(supply / demand) * 100` | `demand == 0` -> `0.0` | Formula / Apex Service |
   100	| **Product** | Trend String | `Product.getTrend()` | `trend < 0 ? "DOWN" : trend > 0 ? "UP" : ""` | N/A | Apex / LWC Display |
   101	| **Country** | Population (Pops) | `Report.loadProvince()` | `sum(popSize * 4)` | None | Apex Service Engine |
   102	| **Country** | Workforce RGO | `Report.loadProvince()` | `sum(popSize)` for `farmers, labourers, slaves, serfs` | None | Apex Service Engine |
   103	| **Country** | Workforce Factory | `Report.loadProvince()` | `sum(popSize)` for `craftsmen, clerks` | None | Apex Service Engine |
   104	| **Country** | Unemployment RGO % | `Country.getUnemploymentRateRgo()` | `((workforceRGO - employmentRGO) / workforceRGO) * 100` | `workforceRGO == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
   105	| **Country** | Unemployment Factory % | `Country.getUnemploymentRateFactory()` | `((workforceFactory - employmentFactory) / workforceFactory) * 100` | `workforceFactory == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
   106	| **Country** | Gold Income (£) | `Report.loadProvince()` | `sum(rgo.last_income / 1000)` where `goods_type == precious_metal` | None | Apex Service Engine |
   107	| **Country** | GDP (£) | `Country.innerCalculations()` | `sum(ProductStorage.getGdpPounds()) + goldIncome` | None | Apex Service / Roll-Up |
   108	| **Country** | GDP per Capita (£/100k) | `Country.getGdpPerCapita()` | `(gdp / population) * 100000` | `population == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
   109	| **Country** | GDP Share % | `Country.calcGdpPart()` | `(gdp / totalCountry.gdp) * 100` | `totalCountry.gdp == 0` -> `0.0` | Apex Service / Formula |
   110	| **ProductStorage** | Total Supply (£) | `ProductStorage.getTotalSupplyPounds()` | `totalSupply * product.price` | None | Apex Service Engine |
   111	| **ProductStorage** | Actual Supply (£) | `ProductStorage.getActualSupplyPounds()` | `sold * product.price` | None | Apex Service Engine |
   112	| **ProductStorage** | Actual Demand (£) | `ProductStorage.getActualDemandPounds()` | `bought * product.price` | None | Apex Service Engine |
   113	| **ProductStorage** | Imported (£) | `ProductStorage.getImportedPounds()` | `max(bought - sold, 0) * product.price` | None | Apex Service Engine |
   114	| **ProductStorage** | Exported (£) | `ProductStorage.getExportedPounds()` | `max(sold - bought, 0) * product.price` (`0` if `precious_metal`) | None | Apex Service Engine |
   115	| **ProductStorage** | GDP (£) | `ProductStorage.getGdpPounds()` | `max(sold - intermediateConsumption, 0) * product.price` | None | Apex Service Engine |
   116	| **World Total** | Total Product Supply (£) | `Report.countTotals()` | `sum(product.supply * product.price)` | None | Apex Service (`Economy_Analysis__c`) |
   117	| **World Total** | Total Product Demand (£) | `Report.countTotals()` | `sum(product.demand * product.price)` | None | Apex Service (`Economy_Analysis__c`) |
   118	| **World Total** | Total Product Consumption (£) | `Report.countTotals()` | `sum(product.consumption * product.price)` | None | Apex Service (`Economy_Analysis__c`) |
   119	| **World Total** | Total Product Base Price (£) | `Report.countTotals()` | `sum(product.basePrice * volume) / sum(volume)` | `sum(volume) == 0` -> `0.0` | Apex Service (`Economy_Analysis__c`) |
   120	| **World Total** | Total Product Price (£) | `Report.countTotals()` | `sum(product.price * volume) / sum(volume)` | `sum(volume) == 0` -> `0.0` | Apex Service (`Economy_Analysis__c`) |
   121
   122	---
   123
   124	## 4. Legacy Implementation Quirks, Precision & Rounding Rules
   125
   126	1. **GDP Per Capita Scaling Multiplier (`100,000`):**
   127	   - Java code: `(gdp / (float) population) * 100000`.
   128	   - Victoria 2 save files record total POP size integer units, where 1 POP unit = 4 total population. The analyzer multiplies POP units by 4 to obtain total human population (`population = sum(popSize * 4)`).
   129	   - Per-capita GDP is scaled by `100,000` so that GDP per capita reflects GDP per 100k inhabitants. This scaling factor **must be preserved** in Salesforce formulas.
   130
   131	2. **Precious Metals / Gold Special Handling:**
   132	   - Gold (`precious_metal`) does not flow through standard world market allocation or exported goods calculations.
   133	   - Its output from RGOs (`last_income / 1000`) is tracked directly as `goldIncome`.
   134	   - `goldIncome` is added directly to total country GDP in `Country.innerCalculations()`.
   135	   - In `ProductStorage.innerCalculations()`, `sold = totalSupply` for `precious_metal`, and `exported = 0`.
   136
   137	3. **World Market Allocation Order:**
   138	   - Victoria 2 engine allocates world market goods based on country Great Power rank.
   139	   - The Java analyzer does not simulate market allocation; it reads post-allocation state directly from the save game file (`saved_country_supply`, `domestic_demand_pool`, `actual_sold_domestic`, `price_pool`, `actual_sold_world`, `worldmarket_pool`).
   140
   141	4. **Floating-Point Precision:**
   142	   - The Java application uses 32-bit single-precision floats (`float`) for core quantities/prices and `double` for wages.
   143	   - In Salesforce, Apex `Decimal` and custom object currency/number fields should use **Precision 18, Scale 4** for quantities/prices and **Scale 2** for percentages/currency totals to prevent floating-point rounding errors.
   144
   145	---
   146
   147	## 5. Detailed Field-by-Field Formula Reference
   148
   149	### 5.1 `Country_Economy__c`
   150
   151	#### `Unemployment_Rate_RGO__c`
   152	- **Type:** Formula (Percent, 2 decimals)
   153	- **Formula:**
   154	  ```sql
   155	  IF(Workforce_RGO__c > 0, ((Workforce_RGO__c - Employment_RGO__c) / Workforce_RGO__c), 0.0)
   156	  ```
   157
   158	#### `Unemployment_Rate_Factory__c`
   159	- **Type:** Formula (Percent, 2 decimals)
   160	- **Formula:**
   161	  ```sql
   162	  IF(Workforce_Factory__c > 0, ((Workforce_Factory__c - Employment_Factory__c) / Workforce_Factory__c), 0.0)
   163	  ```
   164
   165	#### `GDP_Per_Capita__c`
   166	- **Type:** Formula (Currency, 2 decimals)
   167	- **Formula:**
   168	  ```sql
   169	  IF(Population__c > 0, (GDP__c / Population__c) * 100000, 0.0)
   170	  ```
   171
   172	#### `GDP_Share_Percent__c`
   173	- **Type:** Formula (Percent, 2 decimals) or Apex-assigned Number
   174	- **Formula:**
   175	  ```sql
   176	  IF(Economy_Analysis__r.Total_World_GDP__c > 0, (GDP__c / Economy_Analysis__r.Total_World_GDP__c), 0.0)
   177	  ```
   178
   179	---
   180
   181	### 5.2 `Product_Economy__c`
   182
   183	#### `Min_Price__c`
   184	- **Type:** Formula (Currency, 4 decimals)
   185	- **Formula:** `Base_Price__c / 5.0`
   186
   187	#### `Max_Price__c`
   188	- **Type:** Formula (Currency, 4 decimals)
   189	- **Formula:** `Base_Price__c * 5.0`
   190
   191	#### `Inflation_Percent__c`
   192	- **Type:** Formula (Percent, 2 decimals)
   193	- **Formula:**
   194	  ```sql
   195	  IF(Base_Price__c > 0, ((Price__c / Base_Price__c) - 1.0), 0.0)
   196	  ```
   197
   198	#### `Overproduction_Percent__c`
   199	- **Type:** Formula (Percent, 2 decimals)
   200	- **Formula:**
```

### B2 Java source
- Path: NONE
- Note: No `.java` files exist in the repository tree (`find . -name "*.java"` returned 0 files). Phase 2C's citation of `ProductStorage.java` / `Country.java` / `innerCalculations()` was derived from textual references in `vc2-salesforce-version/formula-notes.md` rather than an extant `.java` source file in the repository. As directed by Phase 2D constraints, Phase 2C's verdict of "DOC DRIFT" based on Java source citation is DOWNGRADED to "unverified" with respect to direct Java source inspection, though `formula-notes.md` remains present and fully documents the legacy Java calculations.
- Verbatim `innerCalculations()`: N/A

### B3 Field Inventory Cross-Check

Metadata Directory Path: `vc2-salesforce-version/force-app/main/default/objects/Country_Product_Economy__c/fields/`

| Field API Name | In Doc 12 | In Metadata | In Code (`EconomyCalculationEngine.cls`) | Verdict |
| :--- | :--- | :--- | :--- | :--- |
| `Country_Economy__c` | YES | YES | YES | MATCH |
| `Product_Economy__c` | YES | YES | YES (Line 53, 54) | MATCH |
| `Product__c` | YES | YES | NO | MATCH (Lookup/Schema) |
| `Product_Code__c` | YES | YES | YES (Line 62, 64, 143) | MATCH |
| `Sold_Domestic__c` | YES | YES | YES (Line 69, 76, 84, 86) | MATCH |
| `Bought_Quantity__c` | YES | YES | YES (Line 70, 91, 93, 97) | MATCH |
| `Sold_Quantity__c` | YES | YES | NO | MATCH (Schema) |
| `Thrown_To_Market__c` | YES | YES | YES (Line 71, 76, 81, 84) | MATCH |
| `Import_Value__c` | YES | YES | YES (Line 93, 108) | MATCH |
| `Export_Value__c` | YES | YES | YES (Line 97, 109) | MATCH |
| `Domestic_Sales_Value__c` | YES | YES | YES (Line 92, 107) | MATCH |
| `GDP_Contribution__c` | YES | YES | YES (Line 102, 110, 140, 141) | MATCH |
| `Actual_Demand_Pounds__c` | YES | YES | YES (Line 91, 106) | MATCH |
| `Actual_Supply_Pounds__c` | YES | YES | YES (Line 90, 105) | MATCH |
| `Total_Supply_Pounds__c` | YES | YES | YES (Line 89, 104) | MATCH |
| `Unique_Snapshot_Key__c` | YES | YES | NO | MATCH (External ID) |
| `Actual_Sold_World__c` | NO | YES | YES (Line 72, 84) | NON-BLOCKING SCHEMA DRIFT |
| `Worldmarket_Pool__c` | NO | YES | YES (Line 73, 83, 84) | NON-BLOCKING SCHEMA DRIFT |
| `Intermediate_Consumption__c` | NO | YES | YES (Line 74, 100) | NON-BLOCKING SCHEMA DRIFT |

Explicit confirmation of target fields:
- `Actual_Sold_World__c`: Present in Metadata (`Actual_Sold_World__c.field-meta.xml`), Present in Code (Line 72, 84), ABSENT from Doc 12 (`12_SALESFORCE_FIELD_INVENTORY.md` section 4 summary list).
- `Worldmarket_Pool__c`: Present in Metadata (`Worldmarket_Pool__c.field-meta.xml`), Present in Code (Line 73, 83, 84), ABSENT from Doc 12 (`12_SALESFORCE_FIELD_INVENTORY.md` section 4 summary list).
- `Intermediate_Consumption__c`: Present in Metadata (`Intermediate_Consumption__c.field-meta.xml`), Present in Code (Line 74, 100), ABSENT from Doc 12 (`12_SALESFORCE_FIELD_INVENTORY.md` section 4 summary list).

## 3. Item C — GDP Amendment Drafts (proposed, not applied)

### 3.1 Doc 13 lineage row replacement
Draft replacement for `13_SALESFORCE_FIELD_LINEAGE.md` row for `Country_Economy__c.GDP__c`:

```markdown
| `Country_Economy__c.GDP__c` | Industry outputs & Product junction calculations | CountrySnapshot.GDP | Engine computes `sum(Country_Product_Economy__c.GDP_Contribution__c)` across country junctions. `GDP_Contribution__c` is calculated per product junction as `max(soldUnits - intermediateConsumption, 0) * price`, where `soldUnits` depends on product branching (`precious_metal` or `thrownToMarket <= 0` -> `soldDomestic + thrownToMarket`; `worldmarketPool > 0` -> `soldDomestic + (thrownToMarket * actualSoldWorld / worldmarketPool)`; else -> `soldDomestic`). If `precious_metal` product junction is present, gold income is included in `GDP_Contribution__c`; if absent, `Gold_Income__c` is added to total GDP. |
```

### 3.2 Doc 10 storage/derive row replacement
Draft replacement for `10_DATA_TO_STORE_VS_DERIVE.md` Country GDP matrix row:

```markdown
| Country GDP (`Country_Economy__c.GDP__c`) | DERIVE & STORE | Engine calculates sum of `Country_Product_Economy__c.GDP_Contribution__c` plus conditional `Gold_Income__c` (if `precious_metal` junction is absent). Each product junction `GDP_Contribution__c` derives from clamped net output `max(soldUnits - intermediateConsumption, 0) * price`. Computed in `EconomyCalculationEngine.calculateCountryTotals` and persisted to field. |
```

### 3.3 ADR-2C-GDP stub
```markdown
# ADR-2C-GDP: Country GDP Formula & Lineage Reconciliation

## Status
PROPOSED

## Context
Phase 2C static audit identified that the documentation in `10_DATA_TO_STORE_VS_DERIVE.md` and `13_SALESFORCE_FIELD_LINEAGE.md` described Country GDP as a simple additive sum of sub-entities (`Factory_GDP + Province_GDP + Artisan_GDP`), whereas `EconomyCalculationEngine.cls` (lines 128–152 and 43–112) computes Country GDP via product junction roll-ups (`sum(Country_Product_Economy__c.GDP_Contribution__c) + Gold_Income__c`), incorporating intermediate consumption subtractions and world market allocation branching rules.

## Decision
The implementation in `EconomyCalculationEngine.cls` is authoritative and faithful to the Victoria 2 economic model specification as detailed in `vc2-salesforce-version/formula-notes.md` (Gate 2). The documentation in Doc 10 and Doc 13 shall be amended to reflect the actual Apex calculation path once human review approves this ADR.

## Consequences
- Documentation aligns with Apex engine logic and formula notes.
- No changes required to Apex engine code (`EconomyCalculationEngine.cls`) or Custom Field metadata.
- Doc 12 field inventory will also be updated to record the 3 previously unlisted fields (`Actual_Sold_World__c`, `Worldmarket_Pool__c`, `Intermediate_Consumption__c`).
```

## 4. Blockers
- **Item A UNRESOLVED:** Salesforce CLI (`sf` / `sfdx`) is not installed in the environment container, and no authenticated Salesforce target org is configured. Consequently, `sf apex run test` cannot be executed, and no JUnit XML test evidence can be generated for Phase 2B/2C corroboration.
- **Java source files missing:** No `.java` files exist in the repository to inspect directly. As required by constraints, Phase 2C's verdict of "DOC DRIFT" based on Java source citation is DOWNGRADED to "unverified".

## 5. Non-Blocking Findings
- **Doc 12 Schema Drift (Phase 1 Escape):**
  Three custom fields exist in metadata (`force-app/main/default/objects/Country_Product_Economy__c/fields/`) and are actively referenced in Apex engine logic (`EconomyCalculationEngine.cls`), but were omitted from the summary field list in `12_SALESFORCE_FIELD_INVENTORY.md`:
  1. `Actual_Sold_World__c`
  2. `Worldmarket_Pool__c`
  3. `Intermediate_Consumption__c`
  *Action required:* Doc 12 amendment required to list these 3 fields under `Country_Product_Economy__c`.

## 6. Exit Recommendation
PHASE 2D BLOCKED

*Explanation:*
Phase 2D MUST exit BLOCKED because Item A remains UNRESOLVED (Salesforce CLI unavailable and no target org configured; 0 JUnit XML test execution evidence produced) and no Java source files exist in the repo tree to quote verbatim for Item B. Per the explicit Phase 2D directives ("Do NOT produce a PASS if Item A is UNRESOLVED" and "Any of: Item A UNRESOLVED, formula-notes.md missing, Java source missing... -> Blockers"), Phase 2D cannot pass until a real org environment with SF CLI is connected or an explicit ADR decision is made to waive remote Apex test execution in favor of the off-org parity harness.
