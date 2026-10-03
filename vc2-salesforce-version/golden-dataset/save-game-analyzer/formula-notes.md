# Save_Game_Analyzer — Golden Dataset Formula Notes & Behavioral Audit (Phase 0 Extension)

This document provides a comprehensive formula and behavioral audit of the Python-based Victoria 2 Save Game Analyzer codebase (`Save_Game_Analyzer/`), establishing the authoritative mathematical reference for Extension Phase 0 and subsequent Salesforce Apex conversion.

---

## 1. Overview & Unit Conventions

In the `Save_Game_Analyzer` Python pipeline, economic values extracted from Clausewitz `.v2` save game files follow specific scaling and unit conventions:

1. **Pop Money Scaling (`/ 1000`):** Victoria 2 save game files store monetary amounts (last_income, last_spending, pops_paychecks, money, injected_money) in micro-pounds (multiplied by 1,000). The Python scripts divide all raw monetary amounts by `1,000.0` to convert to pounds (£).
2. **Annualization Multiplier (`* 365`):** Daily financial figures (revenue, RGO income, input costs) are annualized by multiplying by 365 days.
   - **RGO GDP:** `GDP = Last_income * 365`
   - **Factory GDP:** `GDP = (Last_income - Last_spending) * 365`
3. **Currency Formatting:** `Factory.py`, `States.py`, and `Country.py` format monetary amounts into string representations using `locale.currency(val, grouping=True)` under `en_US.UTF-8` (e.g. `$1,234.56`). In the Salesforce conversion, numeric `Decimal` fields (Precision 18, Scale 2/4) store raw unformatted figures, while UI components handle rendering.
4. **Population Definition:** `Pop` in `Provinces.py` represents total human population (`popSize * 4` in Victoria 2 pop size terms). `Population` on `Country.py` splits into `Population` (Core non-colonial) and `Colony_Population`.

---

## 2. Entity Formulas & Division-by-Zero Guard Inventory

### 2.1 Goods Market (`GoodsFinder.py` -> `Goods.csv` / `goods.json`)
- **Source Node:** `price_pool={ ... }`
- **Fields:**
  - `Good`: Commodity identifier code (e.g., `ammunition`, `cotton`).
  - `Price`: Market unit price extracted directly from save node.
- **Formulas:** Direct key-value extraction without transformation.

---

### 2.2 Province Micro-Economy (`Provinces.py` -> `Provinces.csv` / `provinces.json`)
- **Source Node:** `=\n{\n\tname=` (Province blocks)
- **Formulas:**
  - `Pop`: $\sum \text{size}$
  - `Last_income`: $\frac{\text{last\_income}}{1000.0}$ (£ daily)
  - `GDP`: $\text{Last\_income} \times 365$ (£ annual RGO GDP)
  - `Last_Spending`: $\frac{\sum \text{last\_spending}}{1000.0}$ (£ daily artisan spending)
  - `Production_Income`: $\frac{\sum \text{production\_income}}{1000.0}$ (£ daily artisan income)
  - `AGDP`: $\text{Production\_Income} - \text{Last\_Spending}$ (£ daily province artisan GDP)
    - **Division-by-Zero / Value Guard:** If $\text{AGDP} < -1000$, $\text{AGDP} = 0.0$ (safeguard against corrupt negative values).
  - `RGO_Production`: $\frac{\text{Last\_income}}{\text{Goods\_Price}}$
    - **Division-by-Zero / Value Guard:** If $\text{Goods\_Price} == 0$, fallback to $0.0$.
  - `Colony`: `True` if `colonial=2` in province block, else `False`.

---

### 2.3 Factory Micro-Economy (`Factory.py` -> `Factory.csv` / `factory.json`)
- **Source Node:** `state_buildings=`
- **Formulas:**
  - `Level`: $\text{int}(\text{level})$
  - `Last_spending` (Input Costs): $\frac{\text{last\_spending}}{1000.0}$ (£ daily)
  - `Last_income` (Revenue): $\frac{\text{last\_income}}{1000.0}$ (£ daily)
  - `Pops_paychecks` (Wages Paid): $\frac{\text{pops\_paychecks}}{1000.0}$ (£ daily)
  - `Profit`: $\text{Revenue} - \text{Input Costs} - \text{Pops\_paychecks}$ (£ daily)
  - `Money`: $\frac{\text{money}}{1000.0}$ (£)
  - `Produces`: $\text{float}(\text{produces})$ (physical unit output)
  - `Leftover`: $\text{float}(\text{leftover})$ (physical unit leftover)
  - `Injected_money`: $\frac{\text{injected\_money}}{1000.0}$ (£ daily)
  - `GDP`: $(\text{Revenue} - \text{Input Costs}) \times 365$ (£ annual factory value added)
  - `Employees`: $\sum \text{count}$ for `province_pop_id` worker pops.
  - `Productivity`: $\frac{\text{GDP}}{\text{Employees}}$
    - **Division-by-Zero Guard:** If $\text{Employees} == 0$, $\text{Productivity} = 0.0$.
  - `AvgWage`: $\frac{\text{Pops\_paychecks}}{\text{Employees}}$
    - **Division-by-Zero Guard:** If $\text{Employees} == 0$, $\text{AvgWage} = 0.0$.
  - `Rank`: Global factory ranking ordered by `Profit` descending.

---

### 2.4 Artisan Micro-Production (`Artisans.py` -> `Artisans.csv` / `artisans.json`)
- **Source Node:** `production_type="artisan_` inside province definitions.
- **Formulas:**
  - `artisan_type`: Good produced code normalized (e.g. `winery` $\to$ `wine`, `telephone` $\to$ `telephones`, `automobile` $\to$ `automobiles`, `steamer` $\to$ `steamer_convoy`, `clipper` $\to$ `clipper_convoy`, `aeroplane` $\to$ `aeroplanes`, `barrel` $\to$ `barrels`, `fabric_wool` $\to$ `fabric`).
  - `last_spending`: $\frac{\text{last\_spending}}{1000.0}$ (£ daily)
  - `production_income`: $\frac{\text{production\_income}}{1000.0}$ (£ daily)
  - `AGDP`: $\text{production\_income} - \text{last\_spending}$ (£ daily artisan GDP)
    - **Value Guard:** If $\text{AGDP} < -1000$, $\text{AGDP} = 0.0$.
  - `Production`: $\frac{\text{production\_income}}{\text{Commodity\_Price}}$
    - **Division-by-Zero Guard:** If commodity price is missing or $0$, fallback to $\text{Price} = 1.0$ and $\text{Production} = 0.0$.

---

### 2.5 State Regional Aggregation (`States.py` -> `States.csv` / `states.json`)
- **Aggregated Key:** $(\text{State Name}, \text{Country Tag})$
- **Formulas:**
  - `Population`: $\sum \text{Provinces.Population}$
  - `RGO_Income`: $\sum \text{Provinces.RGO\_Income}$ (£ daily)
  - `PGDP`: $\sum \text{Provinces.PGDP}$ (£ annual)
  - `AGDP`: $\sum \text{Provinces.AGDP}$ (£ daily)
  - `Employees`: $\sum \text{Factory.Employees}$
  - `Revenue`: $\sum \text{Factory.Revenue}$ (£ daily)
  - `Profit`: $\sum \text{Factory.Profit}$ (£ daily)
  - `FGDP`: $\sum \text{Factory.FGDP}$ (£ annual)
  - `GDP`: $\text{FGDP} + \text{PGDP} + \text{AGDP}$ (£ total state GDP)
  - `GDP_PerCapita`: $\frac{\text{GDP}}{\text{Population}}$
    - **Division-by-Zero Guard:** If $\text{Population} == 0$, $\text{GDP\_PerCapita} = 0.0$.
  - `Rank`: Global state ranking ordered by `GDP` descending.

---

### 2.6 Country Macro-Aggregation & Commodity Production (`Country.py` -> `Country.csv` / `country.json`)
- **Aggregated Key:** Country Tag (`ID`)
- **Formulas:**
  - `FGDP`: $\sum \text{Factory.FGDP}$ for country tag (£ annual).
  - `PGDP`: $\sum \text{Provinces.PGDP}$ for country tag (£ annual).
  - `AGDP`: $\sum \text{Provinces.AGDP}$ for country tag (£ daily).
  - `Population`: $\sum \text{Provinces.Population}$ where $\text{Colony} == \text{"False"}$.
  - `Colony_Population`: $\sum \text{Provinces.Population}$ where $\text{Colony} == \text{"True"}$.
  - `Total_Population`: $\text{Population} + \text{Colony\_Population}$.
  - `GDP`: $\text{FGDP} + \text{PGDP} + \text{AGDP}$ (£ total country GDP).
  - `GDPperCapita`: $\frac{\text{GDP}}{\text{Population}}$
    - **Division-by-Zero Guard:** If $\text{Population} == 0$, $\text{GDPperCapita} = 0.0$.
  - `Physical Commodity Totals` (49 Goods): $\text{RGO Production} + \text{Factory Output} + \text{Artisan Output}$
    - Unpivoted into 49 commodity columns on `Country.csv`.

---

## 3. Summary Matrix

| Entity | Metric | Legacy Formula | Guard / Edge-Case | Target Field / Location |
| :--- | :--- | :--- | :--- | :--- |
| Province | RGO GDP | `Last_income * 365` | N/A | `Province_Economy__c.RGO_GDP__c` |
| Province | AGDP | `Production_Income - Last_Spending` | `AGDP < -1000` $\to$ `0.0` | `Province_Economy__c.Artisan_GDP__c` |
| Factory | Profit | `Revenue - Input_Costs - Wages` | N/A | `Factory_Economy__c.Profit__c` |
| Factory | Annual GDP | `(Revenue - Input_Costs) * 365` | N/A | `Factory_Economy__c.GDP__c` |
| Factory | Productivity | `GDP / Employees` | `Employees == 0` $\to$ `0.0` | `Factory_Economy__c.Productivity__c` |
| Factory | Avg Wage | `Wages / Employees` | `Employees == 0` $\to$ `0.0` | `Factory_Economy__c.Average_Wage__c` |
| Artisan | Production Qty | `Income / Product_Price` | Unmatched price $\to$ `0.0` | `Artisan_Economy__c.Production_Quantity__c` |
| State | Total GDP | `FGDP + PGDP + AGDP` | N/A | `State_Economy__c.GDP__c` |
| State | GDP Per Capita | `GDP / Population` | `Population == 0` $\to$ `0.0` | `State_Economy__c.GDP_Per_Capita__c` |
| Country | Sector GDP | `FGDP + PGDP + AGDP` | N/A | `Country_Economy__c.Factory_GDP__c`, `Province_GDP__c`, `Artisan_GDP__c` |
| Country | GDP Per Capita | `GDP / Core_Population` | `Core_Population == 0` $\to$ `0.0` | `Country_Economy__c.GDP_Per_Capita__c` |
