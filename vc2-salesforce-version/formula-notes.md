# Victoria 2 Economy Analyzer — Legacy Formula Notes & Architecture Gates (Phase 0)

## 1. Executive Summary & Objective

This document establishes the authoritative behavioral and mathematical reference for the **Victoria 2 Economy Analyzer** Java application (`vic2_economy_analyzer`) prior to its conversion to the Salesforce platform.

The primary objective of Phase 0 is to freeze all legacy calculations, formulas, rounding behaviors, precision rules, and special cases as implemented in the Java source codebase. Where discrepancies exist between the legacy Java implementation and preliminary documentation (such as `VICTORIA2_ECONOMY_ANALYZER_SALESFORCE_CONVERSION_AUDIT.md`), the **legacy Java source code is authoritative**.

---

## 2. Architecture Review Gates Resolution

### Gate 1: Overproduction Formula Ambiguity

- **Audit Document Statement:** Section D states `overproduction = ((actualSupply - maxDemand) / maxDemand) * 100` and proposed field formula `(Total_World_Supply__c - Max_Demand__c) / Max_Demand__c`.
- **Legacy Java Implementation (`Product.java`):**
  ```java
  public float getOverproduced() {
      return supply / demand * 100;
  }
  ```
- **Authoritative Resolution:**
  - In the legacy Java codebase, `Product.getOverproduced()` is implemented as `(supply / demand) * 100`.
  - Here, `supply` represents `supply_pool` (total world supply pool) and `demand` represents `real_demand` (realized global demand) parsed from `worldmarket`.
  - **Salesforce Target Implementation:**
    - Apex Service / Formula calculation must compute `(Total_World_Supply__c / Real_Demand__c) * 100` when `Real_Demand__c > 0`.
    - If `Real_Demand__c == 0` or null, the safeguard must return `0.0`.
    - Note: If Phase 2 calculations require net overproduction ratio relative to max demand, both fields can be provided, but the core legacy `overproduced` metric maps strictly to `(supply / demand) * 100`.

### Gate 2: GDP Contribution & Country GDP Formula Ambiguity

- **Audit Document Statement:** Section D lists `gdpContrib = domesticSales + exportValue` where `domesticSales = (supply - sold) * product.price`.
- **Legacy Java Implementation (`ProductStorage.java`, `Country.java`, `Report.java`):**
  - In `Report.loadCountry()` / `loadProvince()`, intermediate goods consumption from factory and artisan stockpiles is subtracted from product GDP:
    ```java
    storage.incGdp(-value);
    ```
  - In `ProductStorage.innerCalculations()`:
    ```java
    float thrownToMarket = (totalSupply - soldDomestic);
    if (thrownToMarket <= 0)
        sold = totalSupply;
    else if (product.name.equalsIgnoreCase("precious_metal"))
        sold = totalSupply;
    else if (product.worldmarketPool > 0)
        sold = soldDomestic + thrownToMarket * product.actualSoldWorld / product.worldmarketPool;
    else
        sold = soldDomestic;

    gdp += sold; // gdp was initialized to (-intermediate_consumption)
    gdp = Math.max(gdp, 0); // clamped to >= 0
    ```
  - In `ProductStorage.getGdpPounds()`:
    ```java
    return gdp * product.price;
    ```
  - In `Country.innerCalculations()`:
    ```java
    gdp += productStorage.getGdpPounds();
    ```
  - In `loadProvince()` for RGOs:
    ```java
    if (output.getName().equalsIgnoreCase("precious_metal"))
        owner.addGoldIncome((float) lastIncome); // last_income / 1000
    ```
- **Authoritative Resolution:**
  - Product-level GDP in pieces equals `max(sold_units - intermediate_consumption_units, 0)`.
  - Product-level GDP in pounds equals `product_gdp_units * product.price`.
  - Country total GDP in pounds equals `sum(ProductStorage.getGdpPounds()) + goldIncome`.
  - `goldIncome` is the direct treasury revenue in pounds derived from precious metal RGOs (`last_income / 1000`).

### Gate 3: Parser Architecture Confirmation

- **Audit Document Confirmation:** Section J confirms the external EUG parser (Option A) as the primary production architecture for 15MB–120MB `.v2` save game files.
- **Authoritative Resolution:**
  - Victoria 2 save game files (15–120 MB) cannot be parsed synchronously or natively inside Apex due to governor limits (heap size, CPU execution time, regex limit).
  - The off-heap external parser parses the `.v2` file using `eug.parser`, extracts normalized DTO payloads (Countries, Products, ProductStorages, World Market Totals), and POSTs the structured JSON payload to the Salesforce REST endpoint (`EconomyImportService`).
  - Native chunked Apex (Option B) is strictly an optional fallback for small preprocessed payloads.
  - **Phase 0 Rule:** Phase 0 confirms Option A architecture and does **not** author any Apex Clausewitz parser.

---

## 3. Comprehensive Formula & Calculation Matrix

| Entity | Field / Metric | Java Source Class / Method | Legacy Formula | Division-by-Zero Risk & Safeguard | Salesforce Execution Location |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Product** | Min Price | `Product.getMinPrice()` | `basePrice / 5` | None | Formula / Apex |
| **Product** | Max Price | `Product.getMaxPrice()` | `basePrice * 5` | None | Formula / Apex |
| **Product** | Inflation % | `Product.getInflation()` | `(price / basePrice) * 100` | `basePrice == 0` -> `0.0` | Formula Field (`Product_Economy__c`) |
| **Product** | Overproduction % | `Product.getOverproduced()` | `(supply / demand) * 100` | `demand == 0` -> `0.0` | Formula / Apex Service |
| **Product** | Trend String | `Product.getTrend()` | `trend < 0 ? "DOWN" : trend > 0 ? "UP" : ""` | N/A | Apex / LWC Display |
| **Country** | Population (Pops) | `Report.loadProvince()` | `sum(popSize * 4)` | None | Apex Service Engine |
| **Country** | Workforce RGO | `Report.loadProvince()` | `sum(popSize)` for `farmers, labourers, slaves, serfs` | None | Apex Service Engine |
| **Country** | Workforce Factory | `Report.loadProvince()` | `sum(popSize)` for `craftsmen, clerks` | None | Apex Service Engine |
| **Country** | Unemployment RGO % | `Country.getUnemploymentRateRgo()` | `((workforceRGO - employmentRGO) / workforceRGO) * 100` | `workforceRGO == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
| **Country** | Unemployment Factory % | `Country.getUnemploymentRateFactory()` | `((workforceFactory - employmentFactory) / workforceFactory) * 100` | `workforceFactory == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
| **Country** | Gold Income (£) | `Report.loadProvince()` | `sum(rgo.last_income / 1000)` where `goods_type == precious_metal` | None | Apex Service Engine |
| **Country** | GDP (£) | `Country.innerCalculations()` | `sum(ProductStorage.getGdpPounds()) + goldIncome` | None | Apex Service / Roll-Up |
| **Country** | GDP per Capita (£/100k) | `Country.getGdpPerCapita()` | `(gdp / population) * 100000` | `population == 0` -> `0.0` | Formula Field (`Country_Economy__c`) |
| **Country** | GDP Share % | `Country.calcGdpPart()` | `(gdp / totalCountry.gdp) * 100` | `totalCountry.gdp == 0` -> `0.0` | Apex Service / Formula |
| **ProductStorage** | Total Supply (£) | `ProductStorage.getTotalSupplyPounds()` | `totalSupply * product.price` | None | Apex Service Engine |
| **ProductStorage** | Actual Supply (£) | `ProductStorage.getActualSupplyPounds()` | `sold * product.price` | None | Apex Service Engine |
| **ProductStorage** | Actual Demand (£) | `ProductStorage.getActualDemandPounds()` | `bought * product.price` | None | Apex Service Engine |
| **ProductStorage** | Imported (£) | `ProductStorage.getImportedPounds()` | `max(bought - sold, 0) * product.price` | None | Apex Service Engine |
| **ProductStorage** | Exported (£) | `ProductStorage.getExportedPounds()` | `max(sold - bought, 0) * product.price` (`0` if `precious_metal`) | None | Apex Service Engine |
| **ProductStorage** | GDP (£) | `ProductStorage.getGdpPounds()` | `max(sold - intermediateConsumption, 0) * product.price` | None | Apex Service Engine |
| **World Total** | Total Product Supply (£) | `Report.countTotals()` | `sum(product.supply * product.price)` | None | Apex Service (`Economy_Analysis__c`) |
| **World Total** | Total Product Demand (£) | `Report.countTotals()` | `sum(product.demand * product.price)` | None | Apex Service (`Economy_Analysis__c`) |
| **World Total** | Total Product Consumption (£) | `Report.countTotals()` | `sum(product.consumption * product.price)` | None | Apex Service (`Economy_Analysis__c`) |
| **World Total** | Total Product Base Price (£) | `Report.countTotals()` | `sum(product.basePrice * volume) / sum(volume)` | `sum(volume) == 0` -> `0.0` | Apex Service (`Economy_Analysis__c`) |
| **World Total** | Total Product Price (£) | `Report.countTotals()` | `sum(product.price * volume) / sum(volume)` | `sum(volume) == 0` -> `0.0` | Apex Service (`Economy_Analysis__c`) |

---

## 4. Legacy Implementation Quirks, Precision & Rounding Rules

1. **GDP Per Capita Scaling Multiplier (`100,000`):**
   - Java code: `(gdp / (float) population) * 100000`.
   - Victoria 2 save files record total POP size integer units, where 1 POP unit = 4 total population. The analyzer multiplies POP units by 4 to obtain total human population (`population = sum(popSize * 4)`).
   - Per-capita GDP is scaled by `100,000` so that GDP per capita reflects GDP per 100k inhabitants. This scaling factor **must be preserved** in Salesforce formulas.

2. **Precious Metals / Gold Special Handling:**
   - Gold (`precious_metal`) does not flow through standard world market allocation or exported goods calculations.
   - Its output from RGOs (`last_income / 1000`) is tracked directly as `goldIncome`.
   - `goldIncome` is added directly to total country GDP in `Country.innerCalculations()`.
   - In `ProductStorage.innerCalculations()`, `sold = totalSupply` for `precious_metal`, and `exported = 0`.

3. **World Market Allocation Order:**
   - Victoria 2 engine allocates world market goods based on country Great Power rank.
   - The Java analyzer does not simulate market allocation; it reads post-allocation state directly from the save game file (`saved_country_supply`, `domestic_demand_pool`, `actual_sold_domestic`, `price_pool`, `actual_sold_world`, `worldmarket_pool`).

4. **Floating-Point Precision:**
   - The Java application uses 32-bit single-precision floats (`float`) for core quantities/prices and `double` for wages.
   - In Salesforce, Apex `Decimal` and custom object currency/number fields should use **Precision 18, Scale 4** for quantities/prices and **Scale 2** for percentages/currency totals to prevent floating-point rounding errors.
