# Victoria 2 Economy Analyzer — Formula Notes & Behavioral Audit (Phase 0)

This document provides a comprehensive behavioral audit of every critical formula in the legacy Java Victoria 2 Economy Analyzer (`vic2_economy_analyzer`), establishing the authoritative reference for Phase 0 and future Salesforce Apex conversion.

---

## Formula: Product Overproduction

### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.Product`
- **Method:** `getOverproduced()`

### Actual implementation
```java
public float getOverproduced() {
    return supply / demand * 100;
}
```

### Inputs
- `supply`: World market supply pool (`supply_pool` parsed from `worldmarket`)
- `demand`: World market real demand (`real_demand` parsed from `worldmarket`)

### Formula
$$\text{Overproduction \%} = \left( \frac{\text{supply\_pool}}{\text{real\_demand}} \right) \times 100$$

### Zero/edge-case behavior
- If `real_demand == 0` and `supply_pool == 0`, floating-point arithmetic yields `Float.NaN`.
- If `real_demand == 0` and `supply_pool > 0`, floating-point arithmetic yields `Float.POSITIVE_INFINITY`.
- In Golden Exporter serialization, `Float.NaN` and `Float.POSITIVE_INFINITY` are sanitized to `0.0`.

### Precision
- Calculated using 32-bit single-precision IEEE 754 `float`.
- Multiplied by 100. Unrounded in Java engine.

### Audit document description
- Audit Section D lists `overproduction = ((actualSupply - maxDemand) / maxDemand) * 100`.

### Discrepancy
**YES** — Legacy Java implementation uses `(supply_pool / real_demand) * 100` rather than subtracting max demand.

### Phase 1 / Phase 2 impact
- Phase 1 field definition must support `(Total_World_Supply__c / Real_Demand__c) * 100`.
- Apex Service Layer must enforce division-by-zero safeguards returning `0.0` when `Real_Demand__c == 0`.

---

## Formula: Product Inflation

### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.Product`
- **Method:** `getInflation()`

### Actual implementation
```java
public float getInflation() {
    return price / basePrice * 100;
}
```

### Inputs
- `price`: Current commodity price (`price_pool` parsed from `worldmarket`)
- `basePrice`: Base commodity cost (parsed from `common/goods.txt`)

### Formula
$$\text{Inflation \%} = \left( \frac{\text{price}}{\text{basePrice}} \right) \times 100$$

### Zero/edge-case behavior
- If `basePrice == 0`, yields `NaN` or `Infinity`. Sanitized to `0.0`.

### Precision
- 32-bit `float`. Multiplied by 100. Unrounded in Java.

### Audit document description
- Audit Section D lists `inflation = ((price - basePrice) / basePrice) * 100`.

### Discrepancy
**YES** — Legacy Java implementation computes price ratio as a percentage `(price / basePrice) * 100` rather than net percentage change.

### Phase 1 / Phase 2 impact
- Formula field / Apex logic in Salesforce must maintain `(World_Price__c / Base_Price__c) * 100`.

---

## Formula: ProductStorage Inner Calculations & GDP Pounds

### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.ProductStorage`
- **Methods:** `innerCalculations()`, `getGdpPounds()`

### Actual implementation
```java
public void innerCalculations() {
    float thrownToMarket = (totalSupply - soldDomestic);
    if (thrownToMarket <= 0)
        sold = totalSupply;
    else if (product.name.equalsIgnoreCase("precious_metal"))
        sold = totalSupply;
    else if (product.worldmarketPool > 0)
        sold = soldDomestic + thrownToMarket * product.actualSoldWorld / product.worldmarketPool;
    else
        sold = soldDomestic;

    gdp += sold;
    gdp = Math.max(gdp, 0);

    imported = Math.max(bought - sold, 0);

    if (!product.name.equalsIgnoreCase("precious_metal")) {
        exported = Math.max(sold - bought, 0);
    }

    product.actualSupply += sold;
}

public double getGdpPounds() {
    return gdp * product.price;
}
```

### Inputs
- `totalSupply`: `saved_country_supply` from country save node.
- `soldDomestic`: `actual_sold_domestic` from country save node.
- `bought`: `actual_sold_domestic` from country save node.
- `gdp`: Initialized to `0.0`, decremented by intermediate consumption (artisan/factory stockpiles) during parse.
- `product.actualSoldWorld`: `actual_sold_world` from `worldmarket`.
- `product.worldmarketPool`: `worldmarket_pool` from `worldmarket`.
- `product.price`: `price_pool` from `worldmarket`.

### Formula
$$\text{sold} = \begin{cases}
\text{totalSupply} & \text{if } (\text{totalSupply} - \text{soldDomestic}) \le 0 \text{ or } \text{product} = \text{"precious\_metal"} \\
\text{soldDomestic} + (\text{thrownToMarket} \times \frac{\text{actualSoldWorld}}{\text{worldmarketPool}}) & \text{if } \text{worldmarketPool} > 0 \\
\text{soldDomestic} & \text{otherwise}
\end{cases}$$

$$\text{gdp\_units} = \max(\text{sold} - \text{intermediate\_consumption}, 0)$$
$$\text{gdp\_pounds} = \text{gdp\_units} \times \text{product.price}$$

### Zero/edge-case behavior
- Clamped to non-negative using `Math.max(gdp, 0)`.
- If `worldmarketPool == 0`, falls back to `sold = soldDomestic`.

### Precision
- Intermediate quantity calculations use `float`. `getGdpPounds()` converts result to `double`.

### Audit document description
- Audit Section D lists `gdpContrib = domesticSales + exportValue`.

### Discrepancy
**YES** — Java implementation calculates GDP from total sold quantity minus intermediate consumption clamped at 0, multiplied by price.

### Phase 1 / Phase 2 impact
- Apex engine must replicate exact `sold` units calculation and intermediate consumption deduction before price multiplication.

---

## Formula: Country Total GDP & GDP per Capita

### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.Country`
- **Methods:** `innerCalculations()`, `getGdpPerCapita()`

### Actual implementation
```java
public void innerCalculations() {
    clearCalculated();
    for (ProductStorage productStorage : getStorage().values()) {
        productStorage.innerCalculations();

        totalSupply += productStorage.getTotalSupplyPounds();
        sold += productStorage.getActualSupplyPounds();
        bought += productStorage.getActualDemandPounds();
        imported += productStorage.getImportedPounds();
        exported += productStorage.getExportedPounds();
        gdp += productStorage.getGdpPounds();
    }
}

public float getGdpPerCapita() {
    return gdp / (float) population * 100000;
}
```

### Inputs
- `productStorage.getGdpPounds()`: Sum across all product storages in country.
- `goldIncome`: Sum of RGO `last_income / 1000` for `precious_metal` (added to `Country.gdp` if accumulated).
- `population`: Total individual humans (`popSize * 4`).

### Formula
$$\text{Country GDP (£)} = \sum \text{ProductStorage.gdpPounds} + \text{goldIncome}$$
$$\text{GDP per Capita (£/100k)} = \left( \frac{\text{gdp}}{\text{population}} \right) \times 100,000$$

### Zero/edge-case behavior
- If `population == 0`, `getGdpPerCapita()` yields `NaN` or `Infinity`. Sanitized to `0.0`.

### Precision
- `gdp` is stored as `float` in `EconomySubject`.

### Audit document description
- Audit documents `100,000` scaling multiplier.

### Discrepancy
**NO** — Formula matches legacy implementation.

### Phase 1 / Phase 2 impact
- Preserve `100,000` multiplier in Apex Service and Formula fields.

---

## Formula: Country GDP Share (calcGdpPart)

### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.Country`
- **Method:** `calcGdpPart()`

### Actual implementation
```java
public void calcGdpPart(Country totalCountry) {
    GDPPart = gdp / totalCountry.gdp * 100;
}
```

### Inputs
- `gdp`: Country GDP in pounds.
- `totalCountry.gdp`: Sum of GDP across all existing countries (`TOT`).

### Formula
$$\text{GDP Share \%} = \left( \frac{\text{country.gdp}}{\text{totalCountry.gdp}} \right) \times 100$$

### Zero/edge-case behavior
- If `totalCountry.gdp == 0`, yields `NaN`. Sanitized to `0.0`.

### Precision
- 32-bit `float`.

### Audit document description
- Matches Audit Section D.

### Discrepancy
**NO**.

### Phase 1 / Phase 2 impact
- Calculate via Apex Service after global roll-up sum.

---

## Formula: Unemployment Rates (RGO & Factory)

### Java source
- **Class:** `org.victoria2.tools.vic2sgea.entities.Country`
- **Methods:** `getUnemploymentRateRgo()`, `getUnemploymentRateFactory()`

### Actual implementation
```java
public float getUnemploymentRateRgo() {
    return ((float) (workforceRGO - employmentRGO)) / workforceRGO * 100;
}

public float getUnemploymentRateFactory() {
    return (workforceFactory - employmentFactory) / (float) workforceFactory * 100;
}
```

### Inputs
- `workforceRGO`: Sum of sizes of `farmers, labourers, slaves, serfs`.
- `employmentRGO`: Sum of employees in RGOs.
- `workforceFactory`: Sum of sizes of `craftsmen, clerks`.
- `employmentFactory`: Sum of employees in factory state buildings.

### Formula
$$\text{Unemployment RGO \%} = \left( \frac{\text{workforceRGO} - \text{employmentRGO}}{\text{workforceRGO}} \right) \times 100$$
$$\text{Unemployment Factory \%} = \left( \frac{\text{workforceFactory} - \text{employmentFactory}}{\text{workforceFactory}} \right) \times 100$$

### Zero/edge-case behavior
- If workforce is `0`, yields `NaN`. Sanitized to `0.0`.

### Precision
- 32-bit `float`.

### Audit document description
- Matches Audit Section D.

### Discrepancy
**NO**.

### Phase 1 / Phase 2 impact
- Implement via Formula Field with zero-check in Salesforce.

---

## Precious Metals / Gold Special Handling

### Java source
- **Classes:** `Report.java`, `ProductStorage.java`
- **Implementation:**
  - `precious_metal` output from RGOs (`last_income / 1000`) is tracked as `goldIncome`.
  - In `ProductStorage.innerCalculations()`, `sold = totalSupply` for `precious_metal`, and `exported = 0`.
  - `goldIncome` is directly added to country GDP.

---

## World Market Order & Iteration Dependency

### Implementation Note
- The Java application parses data into `HashMap<String, Country>` and `HashMap<String, Product>`.
- `Report.countTotals()` iterates over `countryList` and `productMap.values()`.
- Country GDP ranking (`GDPPlace`) is assigned after sorting `countryList` in descending GDP order using `Comparator.reverseOrder()`.
- Iteration order does NOT alter mathematical formula outputs, but record array ordering in exports reflects sorted or hash order.
