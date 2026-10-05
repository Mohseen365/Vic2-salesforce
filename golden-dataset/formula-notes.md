# Victoria 2 Economy Analyzer — Formula Notes & Behavioral Audit (Phase 0)

This document provides a comprehensive behavioral audit of every critical formula in the legacy Java Victoria 2 Economy Analyzer (`vic2_economy_analyzer`), establishing the authoritative reference for Phase 0 and future Salesforce Apex conversion.

---

## 1. Architecture Review Gates Resolution

### Gate 1: Product Overproduction Formula

#### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.Product`
- **Method:** `getOverproduced()`

#### Actual implementation
```java
public float getOverproduced() {
    return supply / demand * 100;
}
```

#### Inputs
- `supply`: World market supply pool (`supply_pool` parsed from `worldmarket` node)
- `demand`: World market real demand (`real_demand` parsed from `worldmarket` node)

#### Formula
$$\text{Overproduction \%} = \left( \frac{\text{supply\_pool}}{\text{real\_demand}} \right) \times 100$$

#### Zero/edge-case behavior
- If `real_demand == 0` and `supply_pool == 0`, IEEE 754 arithmetic yields `Float.NaN`.
- If `real_demand == 0` and `supply_pool > 0`, IEEE 754 arithmetic yields `Float.POSITIVE_INFINITY`.
- In Golden Exporter serialization and Apex conversion, `NaN` and `Infinity` are sanitized to `0.0`.

#### Precision
- Calculated using 32-bit single-precision IEEE 754 `float`. Unrounded in Java engine.

#### Audit document description
- Audit Section D lists `overproduction = ((actualSupply - maxDemand) / maxDemand) * 100` and proposed field `(Total_World_Supply__c - Max_Demand__c) / Max_Demand__c`.

#### Discrepancy
**YES** — The Java source implementation computes `(supply_pool / real_demand) * 100` rather than subtracting max demand.

#### Phase 1 Field Definition Requirement
- Phase 1 formula field `Overproduction_Percent__c` on `Product_Economy__c` must be defined as:
  `IF(Real_Demand__c > 0, (Total_World_Supply__c / Real_Demand__c) * 100, 0.0)`

---

### Gate 2: GDP Contribution & Country GDP Formula

#### Java source
- **Classes:** `org.victoria2.tools.vic2sgea.entities.ProductStorage`, `org.victoria2.tools.vic2sgea.entities.Country`
- **Methods:** `ProductStorage.innerCalculations()`, `ProductStorage.getGdpPounds()`, `Country.innerCalculations()`

#### Actual implementation
```java
// ProductStorage.innerCalculations()
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

imported = Math.max(bought - sold, 0);
if (!product.name.equalsIgnoreCase("precious_metal")) {
    exported = Math.max(sold - bought, 0);
}

// ProductStorage.getGdpPounds()
return gdp * product.price;

// Country.innerCalculations()
gdp += productStorage.getGdpPounds();
```

#### Inputs
- `totalSupply`: `saved_country_supply` from country save node.
- `soldDomestic`: `actual_sold_domestic` from country save node.
- `bought`: `actual_sold_domestic` from country save node.
- `intermediate_consumption`: Accumulated from artisan and factory stockpiles during parse (`storage.incGdp(-value)`).
- `product.actualSoldWorld`: `actual_sold_world` from `worldmarket`.
- `product.worldmarketPool`: `worldmarket_pool` from `worldmarket`.
- `product.price`: `price_pool` from `worldmarket`.
- `goldIncome`: Sum of RGO `last_income / 1000` for `precious_metal`.

#### Formula
$$\text{sold} = \begin{cases}
\text{totalSupply} & \text{if } (\text{totalSupply} - \text{soldDomestic}) \le 0 \text{ or } \text{product} = \text{"precious\_metal"} \\
\text{soldDomestic} + \left( \text{thrownToMarket} \times \frac{\text{actualSoldWorld}}{\text{worldmarketPool}} \right) & \text{if } \text{worldmarketPool} > 0 \\
\text{soldDomestic} & \text{otherwise}
\end{cases}$$

$$\text{ProductStorage GDP (£)} = \max(\text{sold} - \text{intermediate\_consumption}, 0) \times \text{product.price}$$
$$\text{Country Total GDP (£)} = \sum \text{ProductStorage.gdpPounds} + \text{goldIncome}$$

#### Zero/edge-case behavior
- Product Storage GDP units are clamped at `0` using `Math.max(gdp, 0)`.
- If `worldmarketPool == 0`, falls back to `sold = soldDomestic`.

#### Audit document description
- Audit Section D lists `GDP Contribution = Domestic_Sales_Value__c + Export_Value__c`.

#### Discrepancy
**YES** — The Java implementation computes GDP based on total sold units minus intermediate consumption, clamped at 0, multiplied by product price, plus direct gold income.

#### Phase 2 Calculation Engine Requirement
- Phase 2 `EconomyCalculationEngine.cls` must implement the exact `sold` units allocation, intermediate consumption deduction, price multiplication, and gold income addition.

---

### Gate 3: Parser Architecture Confirmation

#### Java source
- **Classes:** `eug.parser.CWordFile`, `eug.parser.EUGScanner`, `eug.parser.EUGFileIO`, `org.victoria2.tools.vic2sgea.main.Vic2SaveGameCustom`

#### Authoritative Resolution
- Victoria 2 `.v2` save files are 15MB–120MB uncompressed plain text files containing 2+ million lines of Clausewitz syntax.
- Native synchronous parsing inside Salesforce Apex is impossible due to Apex governor limits (heap size limit of 6MB/12MB, CPU timeout of 10s, regex backtracking limits).
- **Confirmation:** Option A (External Off-Heap EUG Parser Service transmitting normalized JSON DTOs to Salesforce REST endpoint `EconomyImportService`) is confirmed as the primary production architecture.
- **Apex Scope Rule:** No Apex Clausewitz parser is in scope for Phase 0, Phase 1, or Phase 2.

---

## 2. Legacy Quirks Audit & Confirmation

### 1. GDP Per Capita Scaling Multiplier (`100,000`)
- **Class:** `org.victoria2.tools.vic2sgea.entities.Country`
- **Method:** `getGdpPerCapita()`
- **Implementation:** `return gdp / (float) population * 100000;`
- **Confirmation:** In Victoria 2, `population` represents total human population (`popSize * 4`). The `100,000` multiplier scales per-capita GDP to represent pounds per 100k citizens. **Confirmed preserved in formula fields and Apex.**

### 2. Gold / Precious Metals Special Handling
- **Classes:** `Report.java`, `ProductStorage.java`
- **Implementation:**
  - Gold (`precious_metal`) output from RGOs (`last_income / 1000`) is tracked directly in `goldIncome`.
  - In `ProductStorage.innerCalculations()`, `sold = totalSupply` for `precious_metal`, and `exported = 0`.
  - `goldIncome` is directly added to total country GDP. **Confirmed preserved.**

### 3. World Market Allocation Order
- **Classes:** `Report.java`, `Vic2SaveGameCustom.java`
- **Implementation:**
  - The legacy analyzer does not simulate the Great Power market allocation order; it reads post-allocation quantities directly from the save game file nodes (`saved_country_supply`, `domestic_demand_pool`, `actual_sold_domestic`, `price_pool`, `actual_sold_world`, `worldmarket_pool`). **Confirmed preserved.**

---

## 3. Comprehensive Metric Summary Table

| Entity | Metric | Legacy Java Formula | Safeguard | Target SF Location |
| :--- | :--- | :--- | :--- | :--- |
| Product | Overproduction % | `(supply / demand) * 100` | `demand == 0` -> `0.0` | `Product_Economy__c.Overproduction_Percent__c` (Formula) |
| Product | Inflation % | `(price / basePrice) * 100` | `basePrice == 0` -> `0.0` | `Product_Economy__c.Inflation_Percent__c` (Formula) |
| Country | Unemployment RGO % | `((workforce - employment) / workforce) * 100` | `workforce == 0` -> `0.0` | `Country_Economy__c.Unemployment_Rate_RGO__c` (Formula) |
| Country | Unemployment Factory % | `((workforce - employment) / workforce) * 100` | `workforce == 0` -> `0.0` | `Country_Economy__c.Unemployment_Rate_Factory__c` (Formula) |
| Country | GDP per Capita | `(gdp / population) * 100000` | `population == 0` -> `0.0` | `Country_Economy__c.GDP_Per_Capita__c` (Formula) |
| Country | GDP Share % | `(country.gdp / totalWorldGdp) * 100` | `totalWorldGdp == 0` -> `0.0` | `Country_Economy__c.GDP_Share_Percent__c` (Apex Service) |
