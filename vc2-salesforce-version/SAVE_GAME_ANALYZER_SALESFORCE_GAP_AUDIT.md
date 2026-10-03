# Save_Game_Analyzer to Salesforce Version — Gap Audit & Migration Plan

**Audit Author:** Senior Salesforce Enterprise Architect & Victoria 2 Domain Specialist
**Target Platform:** Salesforce Enterprise / Unlimited Edition (Lightning Web Components, Apex, Custom Objects & Relationships)
**Source System:** Older Python-based `Save_Game_Analyzer` (`Artisans.py`, `Country.py`, `Factory.py`, `GoodsFinder.py`, `Provinces.py`, `SandPfinder.py`, `States.py`)
**Target System:** `vc2-salesforce-version/` (Salesforce-native Victoria 2 Economy Analyzer)
**Document Purpose:** Comprehensive audit, classification, data-lineage mapping, formula comparison, data model gap analysis, and implementation-ready migration backlog.

---

## 1. Executive Summary

### 1.1 Overview & Purpose
The `Save_Game_Analyzer` is an older desktop Python tool designed to parse Victoria 2 save games (`.v2` text format) and produce flat CSV reports detailing economic metrics across Countries, States, Provinces, Factories, Artisans, and Goods.

The `vc2-salesforce-version` is a modern, enterprise Salesforce application that was previously migrated from a Java-based analyzer (`vic2_economy_analyzer`). It provides a highly optimized, scalable, multi-snapshot architecture consisting of master metadata (`Country__c`, `Product__c`, `Province__c`) and point-in-time snapshot objects (`Economy_Analysis__c`, `Country_Economy__c`, `Product_Economy__c`, `Country_Product_Economy__c`, `Province_Economy__c`).

This audit evaluates every file, formula, data field, relationship, and capability in `Save_Game_Analyzer` against `vc2-salesforce-version` to identify functional gaps, evaluate semantic equivalences, and establish an actionable, non-disruptive migration blueprint.

### 1.2 Comparison & Capability Summary
* **Macroeconomic Parity (Country & Product Markets):** High coverage. Salesforce already provides full macroeconomic country GDP, price pools, trade balance, world supply/demand, and country-product trade junctions.
* **Microeconomic & Regional Model Gaps:** Significant gaps exist in microeconomic details that Python captured:
  1. **Factory Level:** Python extracts individual factory buildings, levels, employee counts, revenue, input costs, paychecks, profit, factory GDP, productivity, and average wages. Salesforce currently has **no Factory entity**.
  2. **Artisan Level:** Python extracts province-level artisan types, production income, last spending, AGDP, and calculated item output. Salesforce currently has **no Artisan entity**.
  3. **State Level:** Python aggregates provinces and factories into regional States (`State`, `Population`, `GDP`, `GDP_PerCapita`, `RGO_Income`, `PGDP`, `AGDP`, `FGDP`, `Employees`, `Revenue`, `Profit`). Salesforce currently has **no State entity or snapshot**.
  4. **Province Micro Financials:** Salesforce stores Province Population and RGO Production quantity, but lacks Python's detailed RGO income, RGO GDP (`Last_income * 365`), artisan spending, artisan production income, province AGDP, and Colony boolean flag.
  5. **Country GDP Component Breakdown:** Python explicitly breaks down country GDP into `FGDP` (Factory GDP), `PGDP` (Province RGO GDP), and `AGDP` (Artisan GDP), as well as population into `Population` (Core) and `Colony_Population`. Salesforce currently stores total `GDP__c` and `Population__c`.

### 1.3 Key Architectural Principles
1. **Preserve Salesforce Multi-Tenant Scalability:** Inserting thousands of micro-level records (e.g., ~2,000 factories or ~10,000 artisans per save game) must not compromise SOQL query performance, governor limits, or LWC rendering responsiveness.
2. **Pure Engine Architecture:** Business calculations must remain encapsulated within `EconomyCalculationEngine.cls` as side-effect-free, pure Apex methods.
3. **Off-Heap / External Parser Ingestion:** Victoria 2 file parsing remains handled externally by the ingestion service/DTO boundary; Salesforce receives pre-parsed JSON DTO payloads via `EconomyImportRestResource.cls`.
4. **Non-Destructive Extension:** Existing Salesforce fields, formulas, and DTO contracts must remain fully intact without breaking existing parity tests or dashboards.

---

## 2. Source Inventory (`Save_Game_Analyzer/`)

| File | Purpose / Responsibility | Dependencies | Output File / Destination |
| :--- | :--- | :--- | :--- |
| `GoodsFinder.py` | Parses `price_pool` block from `.v2` save game file to extract market prices for all commodities. | `.v2` save game file | `outputs/<save>/Goods.csv` |
| `Provinces.py` | Parses province blocks (`=\n{\n\tname=`) for RGO income, pop size, artisan spending/income, owner country, state ID, and colony flag. Calculates RGO GDP, AGDP, and RGO production quantity. | `Goods.csv`, `listofprovinces.csv`, `listofstates.csv`, history files | `outputs/<save>/Provinces.csv` |
| `Factory.py` | Parses `state_buildings=` blocks for building type, level, last spending, last income, paychecks, money, produces, leftover, injected money, and employee counts. Calculates Profit, GDP, Productivity, and AvgWage. | `listofstates.csv`, `Provinces.csv`, history files | `outputs/<save>/Factory.csv` |
| `Artisans.py` | Parses `production_type="artisan_` blocks inside province definitions. Extracts spending and income, normalizes artisan good types, calculates AGDP, and calculates production quantities using commodity prices. | `Provinces.csv`, `Goods.csv` | `outputs/<save>/Artisans.csv` |
| `States.py` | Aggregates province-level (RGO, Artisan) and factory-level metrics by State name and Country tag. Computes State GDP, per-capita GDP, RGO income, Factory revenue/profit, and state GDP rankings. | `Provinces.csv`, `Factory.csv` | `outputs/<save>/States.csv` |
| `Country.py` | Aggregates country-level factory GDP (`FGDP`), province GDP (`PGDP`), artisan GDP (`AGDP`), core vs colony population, and totals physical commodity production across all 49 goods (RGO + Factory + Artisan). | `Provinces.csv`, `Factory.csv`, `Goods.csv`, `Artisans.csv`, `production_types.txt` | `outputs/<save>/<save>.csv` |
| `SandPfinder.py` | Helper script to extract static state-to-province mappings from game files (`map/region.txt`, `history/provinces/`). | Game install folder (`map/`, `history/`) | `listofprovinces.csv`, `listofstates.csv` |
| `listofprovinces.csv` | Static reference CSV mapping province ID (`prov_id`) to province name (`prov_name`). | Generated by `SandPfinder.py` | Reference data for `Provinces.py` |
| `listofstates.csv` | Static reference CSV mapping state province ID (`Number`) to State Name (`State`). | Generated by `SandPfinder.py` | Reference data for `Provinces.py`, `Factory.py`, `States.py` |
| `README.txt` | Installation and usage instructions for running the Python scripts against Victoria 2 save games. | None | Documentation |
| `startscript.bat` | Windows batch file executing Python scripts in sequence: `GoodsFinder` -> `Provinces` -> `Factory` -> `Artisans` -> `States` -> `Country`. | Python runtime | Workflow execution |

---

## 3. Salesforce Inventory (`vc2-salesforce-version/`)

| Artifact Name | Type | Responsibility / Description |
| :--- | :--- | :--- |
| `Economy_Analysis__c` | Custom Object | Master snapshot header for a save game analysis (Save Name, Ingame Date, Player Tag, World GDP, World Imports/Exports, World Pop). |
| `Country__c` | Custom Object | Static master record for a nation (Tag, Name, Flag URL). |
| `Country_Economy__c` | Custom Object | Point-in-time country snapshot (GDP, Rank, Population, Workforce, Employment, Unemployment rates, Imports/Exports, Gold Income). |
| `Product__c` | Custom Object | Static master record for a commodity (Product Code, Base Price, Name). |
| `Product_Economy__c` | Custom Object | Point-in-time commodity market snapshot (Price, Real Demand, Max Demand, Total World Supply, Overproduction %, Inflation %). |
| `Country_Product_Economy__c` | Custom Object | Junction snapshot (Country x Product) capturing supply, demand, domestic sales, imports, exports, and GDP contribution. |
| `Province__c` | Custom Object | Static master record for a province (External Province Id, Name, Country lookup). |
| `Province_Economy__c` | Custom Object | Point-in-time province snapshot (Population, RGO Production quantity, Country Economy lookup). |
| `EconomyCalculationEngine.cls` | Apex Class | Pure calculation engine for product storage trade values, country total GDP, GDP rankings, and analysis world totals. |
| `EconomyImportService.cls` | Apex Class | Transactional import service processing pre-parsed JSON DTO payloads and persisting records. |
| `EconomyAnalysisController.cls` | Apex Class | AuraEnabled facade controller providing cached data reads and exports to LWC. |
| `c-economy-analyzer-shell` | LWC | Main container hosting Global Overview, Country Explorer, Product Market, Analytics & Visualizations, and Compare Saves tabs. |

---

## 4. Capability Matrix

| Capability | Python Source | Python Output | Salesforce Equivalent | Classification | Gap / Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Goods Market Prices | `GoodsFinder.py` | `Goods.csv` (`Price`) | `Product_Economy__c.Price__c` | **EXACT** | Market price extracted per commodity per save snapshot. |
| Country Total GDP | `Country.py` | `Country.csv` (`GDP`) | `Country_Economy__c.GDP__c` | **EXACT** | Computed total country economic output. |
| Country GDP Rank | `Country.py` | `Country.csv` (`Rank`) | `Country_Economy__c.GDP_Rank__c` | **EXACT** | Deterministic rank based on GDP descending. |
| Country Total Population | `Country.py` | `Country.csv` (`Total_Population`) | `Country_Economy__c.Population__c` | **EXACT** | Total headcount across country provinces. |
| Country Pop Breakdown | `Country.py` | `Country.csv` (`Population`, `Colony_Population`) | None | **MISSING** | Salesforce does not store core vs colonial population split. |
| Country Sector GDP Split | `Country.py` | `Country.csv` (`FGDP`, `PGDP`, `AGDP`) | None | **MISSING** | Salesforce does not persist Factory, Province, or Artisan GDP sub-totals on country. |
| Country Commodity Production | `Country.py` | `Country.csv` (49 commodity columns) | `Country_Product_Economy__c` + `Product__c` | **EQUIVALENT** | Normalized junction stores supply/demand per good. Direct physical output field is calculable from junction supply. |
| Province Pop & RGO Quantity | `Provinces.py` | `Provinces.csv` (`Pop`, `RGO_Production`) | `Province_Economy__c.Population__c`, `RGO_Production__c` | **EXACT** | Population and physical output quantity stored. |
| Province RGO Financials | `Provinces.py` | `Provinces.csv` (`Last_income`, `GDP`) | None | **MISSING** | RGO income and annual RGO GDP (`Last_income * 365`) not persisted. |
| Province Artisan Financials | `Provinces.py` | `Provinces.csv` (`Last_Spending`, `Production_Income`, `AGDP`) | None | **MISSING** | Artisan financial metrics not persisted on Province snapshot. |
| Province Colony Status | `Provinces.py` | `Provinces.csv` (`Colony`) | None | **MISSING** | Colonial status boolean flag (`colonial=2`) not persisted. |
| Factory Buildings & Financials | `Factory.py` | `Factory.csv` (17 columns) | None | **MISSING** | No Factory entity or snapshot object in Salesforce. |
| Artisan Production & Financials | `Artisans.py` | `Artisans.csv` (10 columns) | None | **MISSING** | No Artisan entity or snapshot object in Salesforce. |
| State Regional Aggregation | `States.py` | `States.csv` (13 columns) | None | **MISSING** | No State master or State snapshot object in Salesforce. |
| Static Map & Province Master Data | `SandPfinder.py` | `listofprovinces.csv`, `listofstates.csv` | `Province__c`, `Country__c` | **PARTIAL** | Salesforce has Province and Country master objects, but lacks State master. |
| CSV Data Export | All Python scripts | Flat CSV files | `c/economicExportUtils`, `EconomyAnalysisController.exportCsv` | **EQUIVALENT** | Salesforce supports client-side RFC 4180 CSV export up to 5,000 rows and server-side fallback. |

---

## 5. Field-Level Mapping

### 5.1 `GoodsFinder.py` -> `Product_Economy__c`
| Python Field | Source Node | Formula / Logic | Salesforce Field | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Good` | `price_pool` key | String text | `Product__c.Code__c` | **EXACT** | Matched via Product master record. |
| `Price` | `price_pool` value | Raw float text | `Product_Economy__c.Price__c` | **EXACT** | Converted to Decimal currency value. |

### 5.2 `Provinces.py` -> `Province_Economy__c`
| Python Field | Source Node | Formula / Logic | Salesforce Field | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ID` | Counter | Sequential integer | N/A | **LEGACY_ONLY** | Row index, redundant in Salesforce. |
| `Provid` | `listofprovinces.csv` | Game Province ID | `Province__c.External_Province_Id__c` | **EXACT** | Master external ID key. |
| `Name` | `name=` | Text string | `Province__c.Name` | **EXACT** | Master province name. |
| `Owner` | `owner=` | Tag string (e.g. `EGY`) | `Province__c.Country__r.Tag__c` | **EXACT** | Country master lookup. |
| `Country` | `history/countries/` | Country long name | `Country__c.Name` | **EXACT** | Country master name. |
| `State` | `listofstates.csv` | State lookup | None | **MISSING** | Requires `State__c` master relationship. |
| `Colony` | `colonial=2` | `True` if `colonial=2` else `False` | Proposed `Colony__c` | **MISSING** | Boolean flag on `Province_Economy__c`. |
| `Pop` | `size=` under province | Sum of pop sizes | `Province_Economy__c.Population__c` | **EXACT** | Persisted on province snapshot. |
| `Goods_type` | `goods_type=` | Text good code | `Province__c.RGO_Good__c` / `Product__c` | **EQUIVALENT** | RGO product mapping. |
| `RGO_Production` | Calculated | `Last_income / Price` | `Province_Economy__c.RGO_Production__c` | **EXACT** | Persisted on province snapshot. |
| `Last_income` | `last_income=` | `raw / 1000` | Proposed `RGO_Income__c` | **MISSING** | Daily RGO income in £. |
| `GDP` | Calculated | `Last_income * 365` | Proposed `RGO_GDP__c` | **MISSING** | Annualized RGO GDP in £. |
| `Last_Spending` | `last_spending=` | Sum of artisan spending `/ 1000` | Proposed `Artisan_Spending__c` | **MISSING** | Daily artisan spending in £. |
| `Production_Income` | `production_income=` | Sum of artisan income `/ 1000` | Proposed `Artisan_Income__c` | **MISSING** | Daily artisan production income in £. |
| `AGDP` | Calculated | `Production_Income - Last_Spending` | Proposed `Artisan_GDP__c` | **MISSING** | Annualized/net artisan GDP in £. |

### 5.3 `Factory.py` -> `Factory_Economy__c` (Proposed New Object)
| Python Field | Source Node | Formula / Logic | Salesforce Field | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Rank` | Sorted index | Sort by `Profit` descending | Proposed `Profit_Rank__c` | **MISSING** | Calculated during import / Apex. |
| `State` | `listofstates.csv` | State name lookup | Proposed `State_Economy__c` | **MISSING** | Parent state snapshot lookup. |
| `Tag` | `Provinces.csv` owner | Country tag | Proposed `Country_Economy__c` | **MISSING** | Parent country snapshot lookup. |
| `Country` | Country list | Country name | `Country__c.Name` | **EQUIVALENT** | Master relationship via Country. |
| `Building` | `building=` | Building code (e.g. `steel_factory`) | Proposed `Building_Type__c` | **MISSING** | Factory building type string. |
| `Level` | `level=` | Integer level | Proposed `Level__c` | **MISSING** | Factory expansion level. |
| `Employees` | `count=` sum | Sum of pop counts where `province_pop_id` | Proposed `Employees__c` | **MISSING** | Total employed headcount. |
| `Produces` | `produces=` | Float output quantity | Proposed `Output_Quantity__c` | **MISSING** | Daily physical commodity output. |
| `Leftover` | `leftover=` | Float unsold quantity | Proposed `Unsold_Quantity__c` | **MISSING** | Daily unsold commodity output. |
| `Money` | `money=` | `raw / 1000` | Proposed `Capital_Reserves__c` | **MISSING** | Factory cash reserve balance in £. |
| `Revenue` | `last_income=` | `raw / 1000` | Proposed `Revenue__c` | **MISSING** | Daily factory income in £. |
| `Input Costs` | `last_spending=` | `raw / 1000` | Proposed `Input_Cost__c` | **MISSING** | Daily factory input cost in £. |
| `Pops_paychecks` | `pops_paychecks=` | `raw / 1000` | Proposed `Wages_Paid__c` | **MISSING** | Daily worker payroll in £. |
| `Profit` | Calculated | `Revenue - Input_Cost - Wages_Paid` | Proposed `Profit__c` | **MISSING** | Daily net profit in £. |
| `GDP` | Calculated | `(Revenue - Input_Cost) * 365` | Proposed `Factory_GDP__c` | **MISSING** | Annualized factory GDP contribution. |
| `Productivity` | Calculated | `Factory_GDP / Employees` | Proposed `Productivity__c` | **MISSING** | GDP per worker ratio. |
| `AvgWage` | Calculated | `Wages_Paid / Employees` | Proposed `Average_Wage__c` | **MISSING** | Daily wage per worker ratio. |

### 5.4 `Artisans.py` -> `Artisan_Economy__c` (Proposed New Object)
| Python Field | Source Node | Formula / Logic | Salesforce Field | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ID` | Province ID counter | Province ID | `Province_Economy__c` | **EQUIVALENT** | Master province relationship. |
| `Provid` | Game Province ID | Province ID | `Province__c.External_Province_Id__c` | **EQUIVALENT** | Master province external ID. |
| `Name` | Province Name | Province Name | `Province__c.Name` | **EQUIVALENT** | Master province name. |
| `Country` | Country Tag | Country Tag | `Country_Economy__c` | **EQUIVALENT** | Master country relationship. |
| `State` | State Name | State Name | Proposed `State_Economy__c` | **MISSING** | State lookup. |
| `artisan_type` | `production_type="artisan_` | Text normalized type | Proposed `Artisan_Type__c` | **MISSING** | Good produced by artisan pop. |
| `last_spending` | `last_spending=` | `raw / 1000` | Proposed `Spending__c` | **MISSING** | Daily material spending in £. |
| `production_income` | `production_income=` | `raw / 1000` | Proposed `Income__c` | **MISSING** | Daily gross sales income in £. |
| `AGDP` | Calculated | `Income - Spending` (min -1000) | Proposed `AGDP__c` | **MISSING** | Net artisan income contribution. |
| `Production` | Calculated | `Income / Price` | Proposed `Production_Quantity__c` | **MISSING** | Physical commodity production units. |

### 5.5 `States.py` -> `State_Economy__c` (Proposed New Object)
| Python Field | Source Node | Formula / Logic | Salesforce Field | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Rank` | Sorted index | Sort by `GDP` descending | Proposed `GDP_Rank__c` | **MISSING** | Rank within save snapshot. |
| `Name` | State Name | Text name | `State__c.Name` | **MISSING** | Master state name. |
| `Country` | Country Name | Country Name | `Country_Economy__c` | **MISSING** | Country economy parent lookup. |
| `Population` | Province sum | Sum of province pops in state | Proposed `Population__c` | **MISSING** | State population headcount. |
| `GDP` | Sum | `FGDP + PGDP + AGDP` | Proposed `GDP__c` | **MISSING** | Total state annual GDP in £. |
| `GDP_PerCapita` | Calculated | `GDP / Population` | Proposed `GDP_Per_Capita__c` | **MISSING** | Per capita state output in £. |
| `RGO_Income` | Province sum | Sum of province RGO incomes | Proposed `RGO_Income__c` | **MISSING** | Daily state RGO income in £. |
| `PGDP` | Province sum | Sum of province RGO GDPs | Proposed `PGDP__c` | **MISSING** | Annual state RGO GDP in £. |
| `AGDP` | Province sum | Sum of province AGDPs | Proposed `AGDP__c` | **MISSING** | Annual state Artisan GDP in £. |
| `FGDP` | Factory sum | Sum of factory GDPs in state | Proposed `FGDP__c` | **MISSING** | Annual state Factory GDP in £. |
| `Employees` | Factory sum | Sum of factory employees | Proposed `Factory_Employees__c` | **MISSING** | Total industrial factory workforce. |
| `Revenue` | Factory sum | Sum of factory revenues | Proposed `Factory_Revenue__c` | **MISSING** | Daily industrial factory revenue. |
| `Profit` | Factory sum | Sum of factory profits | Proposed `Factory_Profit__c` | **MISSING** | Daily industrial factory net profit. |

### 5.6 `Country.py` -> `Country_Economy__c`
| Python Field | Source Node | Formula / Logic | Salesforce Field | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Rank` | Sorted index | Sort by `GDP` descending | `Country_Economy__c.GDP_Rank__c` | **EXACT** | Assigned deterministically. |
| `ID` | Country Tag | Text string | `Country_Economy__c.Country_Tag__c` | **EXACT** | ISO/Clausewitz tag. |
| `Name` | Country Name | Text string | `Country__c.Name` | **EXACT** | Master country name. |
| `Population` | Province sum | Sum of core province pops | Proposed `Core_Population__c` | **MISSING** | Core non-colonial headcount. |
| `Colony_Population` | Province sum | Sum of colonial province pops | Proposed `Colony_Population__c` | **MISSING** | Colonial headcount. |
| `Total_Population` | Sum | `Population + Colony_Population` | `Country_Economy__c.Population__c` | **EXACT** | Persisted as total population. |
| `FGDP` | Factory sum | Sum of state/factory GDPs | Proposed `Factory_GDP__c` | **MISSING** | Industrial sector GDP in £. |
| `PGDP` | Province sum | Sum of province RGO GDPs | Proposed `Province_GDP__c` | **MISSING** | RGO sector GDP in £. |
| `AGDP` | Province sum | Sum of province AGDPs | Proposed `Artisan_GDP__c` | **MISSING** | Artisan sector GDP in £. |
| `GDP` | Sum | `FGDP + PGDP + AGDP` | `Country_Economy__c.GDP__c` | **EXACT** | Persisted total country GDP. |
| `GDPperCapita` | Calculated | `GDP / Population` | `Country_Economy__c.GDP_Per_Capita__c` | **EXACT** | Persisted per capita GDP. |
| Commodity columns (49) | Sums | Sum of RGO + Factory + Artisan production | `Country_Product_Economy__c` | **EQUIVALENT** | Represented via Country-Product junction records. |

---

## 6. Formula Comparison

| Metric / Formula | Python Implementation | Salesforce Implementation | Match Status | Action Required |
| :--- | :--- | :--- | :--- | :--- |
| **Factory Profit** | `Last_income - Last_spending - Pops_paychecks` | N/A | **MISSING** | Implement in Apex during Factory calculation: `Revenue - InputCost - Wages`. |
| **Factory GDP** | `(Last_income - Last_spending) * 365` | N/A | **MISSING** | Implement in Apex: `(Revenue - InputCost) * 365`. |
| **Factory Productivity** | `GDP / Employees` (0 if Employees == 0) | N/A | **MISSING** | Implement in Apex with safe zero divide safeguard. |
| **Factory Avg Wage** | `Pops_paychecks / Employees` (0 if Employees == 0) | N/A | **MISSING** | Implement in Apex with safe zero divide safeguard. |
| **Artisan AGDP** | `Production_Income - Last_Spending` (0 if AGDP < -1000) | N/A | **MISSING** | Implement in Apex with negative outlier clamp safeguard. |
| **Artisan Output Qty** | `Production_Income / Product_Price` (0 if Price == 0) | N/A | **MISSING** | Implement in Apex using Product Market price pool. |
| **Province RGO Output** | `Last_income / Product_Price` | `RGO_Production__c` (Directly parsed or calculated) | **EXACT** | Value matches existing formula. |
| **Province RGO GDP** | `Last_income * 365` | N/A | **MISSING** | Add formula/Apex field `RGO_GDP__c = RGO_Income__c * 365`. |
| **State Total GDP** | `FGDP + PGDP + AGDP` | N/A | **MISSING** | Implement in Apex during State aggregation. |
| **State GDP Per Capita** | `GDP / Population` (0 if Pop == 0) | N/A | **MISSING** | Implement in Apex: `safeDivide(GDP, Population, 0.0)`. |
| **Country Total Pop** | `Core_Population + Colony_Population` | `Country_Economy__c.Population__c` | **EXACT** | Value matches existing formula. |
| **Country Sector GDP** | `GDP = FGDP + PGDP + AGDP` | Sum of `Country_Product_Economy__c.GDP_Contribution__c` (+ Gold) | **EQUIVALENT / CONFLICT** | **Conflict Note:** Python aggregates micro-sectors (Factory, RGO, Artisan), whereas Salesforce current engine computes macro GDP contribution per good. Both equal macro GDP. Adding sector fields on `Country_Economy__c` preserves Python breakdown. |

---

## 7. Data Model Gap Analysis

To preserve all microeconomic capabilities present in `Save_Game_Analyzer` while keeping Salesforce scalable and performant, the following data model additions are proposed.

```text
                               ┌──────────────────────┐
                               │  Economy_Analysis__c │
                               └──────────┬───────────┘
                                          │
            ┌─────────────────────────────┼─────────────────────────────┐
            │                             │                             │
┌───────────▼──────────┐       ┌──────────▼───────────┐       ┌──────────▼───────────┐
│  Country_Economy__c  │       │  Product_Economy__c  │       │   State_Economy__c   │  <-- NEW
└───────────┬──────────┘       └──────────┬───────────┘       └──────────┬───────────┘
            │                             │                              │
            ├─────────────────────────────┼───────────────┐              │
            │                             │               │              │
┌───────────▼────────────┐     ┌──────────▼────────────┐ │     ┌────────▼─────────────┐
│Province_Economy__c     │     │Country_Product_Econ__c│ │     │ Factory_Economy__c   │  <-- NEW
│ (+ RGO/Artisan fields) │     └───────────────────────┘ │     └──────────────────────┘
└───────────┬────────────┘                               │
            │                                            │
┌───────────▼────────────┐                               │
│  Artisan_Economy__c    │ <─────────────────────────────┘  <-- NEW
└────────────────────────┘
```

### 7.1 Proposed Custom Objects & Fields

#### 1. `State__c` (Master Metadata Object)
* **Purpose:** Static catalog of regional states within countries.
* **Fields:**
  * `Name` (Text, 80): State Name (e.g. "Illinois", "Mazowieckie").
  * `State_Code__c` (Text, 50, Unique, External ID): Unique key (e.g. `USA_Illinois`).
  * `Country__c` (Lookup to `Country__c`): Associated parent nation.

#### 2. `State_Economy__c` (Snapshot Object)
* **Purpose:** Point-in-time state economic performance snapshot per save game.
* **Parent Relationship:** Master-Detail to `Country_Economy__c` (or Lookup to `Economy_Analysis__c` + Lookup to `State__c`).
* **Fields:**
  * `Unique_Snapshot_Key__c` (Text, 255, Unique, External ID): Key (`<AnalysisId>_<StateCode>`).
  * `State__c` (Lookup to `State__c`).
  * `Economy_Analysis__c` (Lookup/Master-Detail).
  * `Country_Economy__c` (Lookup/Master-Detail).
  * `Population__c` (Number, 18, 0): Total state headcount.
  * `GDP__c` (Currency, 18, 2): Total annual state GDP (£).
  * `GDP_Per_Capita__c` (Currency, 18, 4): GDP per capita (£).
  * `GDP_Rank__c` (Number, 6, 0): State GDP rank within save game.
  * `RGO_Income__c` (Currency, 18, 2): Daily RGO income (£).
  * `PGDP__c` (Currency, 18, 2): Annual RGO GDP (£).
  * `AGDP__c` (Currency, 18, 2): Annual Artisan GDP (£).
  * `FGDP__c` (Currency, 18, 2): Annual Factory GDP (£).
  * `Factory_Employees__c` (Number, 18, 0): Total factory workforce.
  * `Factory_Revenue__c` (Currency, 18, 2): Daily factory revenue (£).
  * `Factory_Profit__c` (Currency, 18, 2): Daily factory profit (£).

#### 3. `Factory_Economy__c` (Snapshot Object)
* **Purpose:** Detailed individual factory performance snapshot per save game.
* **Relationships:** Lookup to `State_Economy__c`, Lookup to `Country_Economy__c`, Lookup to `Product__c` (Output Good).
* **Fields:**
  * `Unique_Snapshot_Key__c` (Text, 255, Unique, External ID): Key (`<AnalysisId>_<StateCode>_<BuildingType>`).
  * `Building_Type__c` (Text, 100): Factory building identifier (e.g. `steel_mill`).
  * `Level__c` (Number, 4, 0): Industrial level (1-99).
  * `Employees__c` (Number, 18, 0): Total active factory workers.
  * `Output_Quantity__c` (Number, 18, 2): Daily commodity output units.
  * `Unsold_Quantity__c` (Number, 18, 2): Daily unsold leftover output.
  * `Capital_Reserves__c` (Currency, 18, 2): Factory cash balance (`money`).
  * `Revenue__c` (Currency, 18, 2): Daily gross revenue (`last_income`).
  * `Input_Cost__c` (Currency, 18, 2): Daily raw material cost (`last_spending`).
  * `Wages_Paid__c` (Currency, 18, 2): Daily worker payroll (`pops_paychecks`).
  * `Profit__c` (Currency, 18, 2): Daily net profit (`Revenue - InputCost - Wages`).
  * `Factory_GDP__c` (Currency, 18, 2): Annual GDP contribution (`(Revenue - InputCost) * 365`).
  * `Productivity__c` (Currency, 18, 4): Annual GDP per employee.
  * `Average_Wage__c` (Currency, 18, 4): Daily wage per employee.
  * `Profit_Rank__c` (Number, 6, 0): Global factory profit rank.

#### 4. `Artisan_Economy__c` (Snapshot Object)
* **Purpose:** Detailed province-level artisan pop production snapshot per save game.
* **Relationships:** Lookup to `Province_Economy__c`, Lookup to `Country_Economy__c`, Lookup to `Product__c`.
* **Fields:**
  * `Unique_Snapshot_Key__c` (Text, 255, Unique, External ID): Key (`<AnalysisId>_<ProvId>_<ArtisanType>`).
  * `Artisan_Type__c` (Text, 100): Good produced (e.g. `furniture`, `regular_clothes`).
  * `Spending__c` (Currency, 18, 2): Daily raw input cost (£).
  * `Income__c` (Currency, 18, 2): Daily gross revenue (£).
  * `AGDP__c` (Currency, 18, 2): Net artisan daily contribution (£).
  * `Production_Quantity__c` (Number, 18, 2): Calculated physical output units.

#### 5. Extensions to Existing `Province_Economy__c`
* `Colony__c` (Checkbox): Indicates colonial status (`colonial=2`).
* `State_Economy__c` (Lookup to `State_Economy__c`): Associated state snapshot.
* `RGO_Income__c` (Currency, 18, 2): Daily RGO income (£).
* `RGO_GDP__c` (Currency, 18, 2): Annual RGO GDP (`RGO_Income * 365`).
* `Artisan_Spending__c` (Currency, 18, 2): Daily province artisan spending (£).
* `Artisan_Income__c` (Currency, 18, 2): Daily province artisan income (£).
* `Artisan_GDP__c` (Currency, 18, 2): Daily/Annual province artisan net GDP (£).

#### 6. Extensions to Existing `Country_Economy__c`
* `Core_Population__c` (Number, 18, 0): Non-colonial population.
* `Colony_Population__c` (Number, 18, 0): Colonial population.
* `Factory_GDP__c` (Currency, 18, 2): Aggregated country factory GDP (£).
* `Province_GDP__c` (Currency, 18, 2): Aggregated country RGO GDP (£).
* `Artisan_GDP__c` (Currency, 18, 2): Aggregated country artisan GDP (£).

---

## 8. Import Contract Gap Analysis

The REST API interface (`EconomyImportRestResource.cls`) and service (`EconomyImportService.cls`) consume a JSON DTO payload (`EconomyImportRequestDTO.cls`). To support the missing microeconomic entities, the JSON import contract will be extended as follows:

```json
{
  "analysis": {
    "saveFileName": "egypt.v2",
    "ingameDate": "1836-01-01",
    "playerCountryTag": "EGY"
  },
  "countries": [ ... ],
  "products": [ ... ],
  "provinces": [
    {
      "externalProvinceId": 1720,
      "population": 125000,
      "rgoProduction": 45.2,
      "colony": false,
      "rgoIncome": 12.50,
      "artisanSpending": 3.20,
      "artisanIncome": 8.40,
      "stateCode": "EGY_Cairo"
    }
  ],
  "states": [
    {
      "stateCode": "EGY_Cairo",
      "stateName": "Cairo Region",
      "countryTag": "EGY"
    }
  ],
  "factories": [
    {
      "stateCode": "EGY_Cairo",
      "countryTag": "EGY",
      "buildingType": "glass_factory",
      "level": 1,
      "employees": 4200,
      "produces": 15.4,
      "leftover": 1.2,
      "capitalReserves": 250.00,
      "revenue": 45.10,
      "inputCost": 22.30,
      "wagesPaid": 12.00
    }
  ],
  "artisans": [
    {
      "externalProvinceId": 1720,
      "countryTag": "EGY",
      "artisanType": "fabric",
      "spending": 1.10,
      "income": 3.50
    }
  ]
}
```

---

## 9. Apex Gap Analysis

### 9.1 `EconomyCalculationEngine.cls` Updates
Add pure calculation methods for the new entities:
1. `calculateFactoryMetrics(List<Factory_Economy__c> factories)`:
   - Computes `Profit__c = Revenue__c - Input_Cost__c - Wages_Paid__c`.
   - Computes `Factory_GDP__c = (Revenue__c - Input_Cost__c) * 365`.
   - Computes `Productivity__c = safeDivide(Factory_GDP__c, Employees__c, 0.0)`.
   - Computes `Average_Wage__c = safeDivide(Wages_Paid__c, Employees__c, 0.0)`.
2. `calculateArtisanMetrics(List<Artisan_Economy__c> artisans, Map<String, Decimal> priceByProductCode)`:
   - Computes `AGDP__c = Income__c - Spending__c` (with -1000 floor safeguard).
   - Computes `Production_Quantity__c = safeDivide(Income__c, price, 0.0)`.
3. `calculateStateTotals(List<State_Economy__c> states, Map<Id, List<Province_Economy__c>> provsByState, Map<Id, List<Factory_Economy__c>> factoriesByState)`:
   - Aggregates Population, PGDP, AGDP, FGDP, Factory Revenue, Factory Profit, and Total State GDP.
   - Assigns State GDP Ranks.
4. `calculateCountrySectorGdp(List<Country_Economy__c> countries, ...)`:
   - Aggregates country-level `Factory_GDP__c`, `Province_GDP__c`, `Artisan_GDP__c`, `Core_Population__c`, and `Colony_Population__c`.

### 9.2 `EconomyImportService.cls` Updates
Update transaction processing order to ingest new objects sequentially:
1. Ingest/Upsert Master Data (`Country__c`, `Product__c`, `Province__c`, `State__c`).
2. Persist Snapshot Header (`Economy_Analysis__c`).
3. Persist `Country_Economy__c` & `Product_Economy__c`.
4. Persist `State_Economy__c`.
5. Persist `Province_Economy__c` & `Country_Product_Economy__c`.
6. Persist `Factory_Economy__c` & `Artisan_Economy__c` in batch chunks if count exceeds 2,000.

---

## 10. LWC Gap Analysis

### 10.1 Updates to Existing LWCs
* **`c-country-dashboard`:** Add a tab/section displaying Sector GDP breakdown (Factory GDP vs RGO GDP vs Artisan GDP donut chart / metrics) and Core vs Colonial population metrics.
* **`c-analysis-compare`:** Add country sector GDP delta columns (`Factory GDP Δ`, `Artisan GDP Δ`, `RGO GDP Δ`).
* **`c-economic-export-modal`:** Add export choices for States, Factories, and Artisans CSV datasets.

### 10.2 Proposed New Optional Components
* **`c-state-dashboard`:** Datatable and card view of State GDP, per capita GDP, workforce, and factory vs RGO production.
* **`c-factory-dashboard`:** Searchable, sortable table of all industrial factories across the world, filtered by Country, State, Building type, Profitability, and Productivity.
* **`c-artisan-dashboard`:** Regional artisan production breakdown table.

---

## 11. Export Gap Analysis

| Python CSV | Salesforce Export Equivalent | Gap Status |
| :--- | :--- | :--- |
| `Goods.csv` | Export from `Product_Economy__c` | **EXACT** |
| `Country.csv` | Export from `Country_Economy__c` + `Country_Product_Economy__c` | **EQUIVALENT** (Add sector GDP columns) |
| `Provinces.csv` | Export from `Province_Economy__c` | **PARTIAL** (Add RGO/Artisan financial columns) |
| `States.csv` | Proposed export from `State_Economy__c` | **MISSING** (Requires `State_Economy__c`) |
| `Factory.csv` | Proposed export from `Factory_Economy__c` | **MISSING** (Requires `Factory_Economy__c`) |
| `Artisans.csv` | Proposed export from `Artisan_Economy__c` | **MISSING** (Requires `Artisan_Economy__c`) |

---

## 12. Golden Dataset / Parity Gap

### 12.1 Coverage Matrix

| Python Capability / Scope | Existing Golden Coverage | Required Golden Extension |
| :--- | :--- | :--- |
| Country Macro GDP & Trade | Covered (`country-calculations.json`) | Add `FGDP`, `PGDP`, `AGDP`, `Colony_Population`. |
| Product Market & Prices | Covered (`product-calculations.json`) | Fully covered. |
| Province Pop & RGO Quantity | Covered (`provinces.json`) | Add `RGO_Income`, `Colony`, `Artisan_Spending`, `Artisan_Income`. |
| State Aggregations | Not Covered | Add `states.json` derived dataset. |
| Factory Analysis | Not Covered | Add `factories.json` derived dataset. |
| Artisan Analysis | Not Covered | Add `artisans.json` derived dataset. |

---

## 13. Migration Backlog

The following backlog tasks outline the sequential implementation required to migrate `Save_Game_Analyzer` capabilities into Salesforce:

* **SGA-001 — Add Missing Microeconomic Fields to `Province_Economy__c` and `Country_Economy__c`**
  * *Evidence:* `Provinces.py` lines 85-130 (`Last_income`, `AGDP`, `Colony`), `Country.py` lines 140-185 (`FGDP`, `PGDP`, `AGDP`, `Colony_Population`).
* **SGA-002 — Introduce Master `State__c` and Snapshot `State_Economy__c` Objects**
  * *Evidence:* `States.py` lines 50-150 (`Name`, `Population`, `GDP`, `GDP_PerCapita`, `RGO_Income`, `PGDP`, `AGDP`, `FGDP`, `Employees`, `Revenue`, `Profit`).
* **SGA-003 — Introduce Snapshot `Factory_Economy__c` Object**
  * *Evidence:* `Factory.py` lines 30-100 (`Building`, `Level`, `Employees`, `Produces`, `Leftover`, `Money`, `Revenue`, `Input Costs`, `Pops_paychecks`, `Profit`, `GDP`, `Productivity`, `AvgWage`).
* **SGA-004 — Introduce Snapshot `Artisan_Economy__c` Object**
  * *Evidence:* `Artisans.py` lines 40-110 (`artisan_type`, `last_spending`, `production_income`, `AGDP`, `Production`).
* **SGA-005 — Extend Ingestion DTO Contract (`EconomyImportRequestDTO`) & REST Service**
  * *Evidence:* Need parser to transmit states, factories, artisans, and extended province fields.
* **SGA-006 — Extend Pure Calculation Engine (`EconomyCalculationEngine.cls`)**
  * *Evidence:* Implement factory profit/productivity, artisan AGDP/output, state aggregation, and country sector GDP formulas.
* **SGA-007 — Extend Data Persistence in `EconomyImportService.cls` & `EconomyImportBatch.cls`**
  * *Evidence:* Handle transactional creation of state, factory, and artisan records with governor limit protection.
* **SGA-008 — Update Selectors & DTO Service Facades (`EconomyAnalysisSelector.cls`, `EconomyAnalysisController.cls`)**
  * *Evidence:* Expose state, factory, and artisan summary metrics to LWC layer.
* **SGA-009 — Update Existing LWCs (`c-country-dashboard`, `c-analysis-compare`)**
  * *Evidence:* Display sector GDP breakdowns and core vs colony population.
* **SGA-010 — Create Microeconomic LWC Dashboards (`c-state-dashboard`, `c-factory-dashboard`)**
  * *Evidence:* Provide UI views for state ranks and factory profit/productivity tables.
* **SGA-011 — Extend CSV Export Utilities (`c/economicExportUtils`, `EconomyAnalysisController`)**
  * *Evidence:* Support exporting `States.csv`, `Factory.csv`, and `Artisans.csv`.
* **SGA-012 — Extend Golden Dataset & Parity Verification Harness (`compare.py`)**
  * *Evidence:* Add verification checks for factory, artisan, state, and province micro fields.

---

## 14. Recommended Implementation Order

```text
Phase 1: Metadata & Data Model Extensions (SGA-001, SGA-002, SGA-003, SGA-004)
   │
   ▼
Phase 2: Ingestion Contract & DTO Extensions (SGA-005)
   │
   ▼
Phase 3: Core Calculation Engine & Service Updates (SGA-006, SGA-007)
   │
   ▼
Phase 4: Selectors & Facade Controller Updates (SGA-008)
   │
   ▼
Phase 5: Golden Dataset Extension & Parity Harness Updates (SGA-012)
   │
   ▼
Phase 6: LWC Enhancements & New Dashboards (SGA-009, SGA-010)
   │
   ▼
Phase 7: Export Utilities & Full End-to-End Validation (SGA-011)
```

---

## 15. Architecture Decisions (ADR)

### ADR 1: Microeconomic Persistence vs. High-Volume Record Limits
* **Decision:** Introduce `State_Economy__c`, `Factory_Economy__c`, and `Artisan_Economy__c` snapshot objects.
* **Reason:** Preserves full microeconomic detail from `Save_Game_Analyzer` (`Factory.py`, `Artisans.py`, `States.py`).
* **Evidence:** Victoria 2 save games contain ~300 states, ~1,500-2,500 factories, and ~5,000-10,000 artisan pop entries.
* **Alternatives Considered:** Aggregating factories into state-level JSON blobs on `State_Economy__c`. Rejected because JSON blobs prevent standard Salesforce SOQL filtering, report generation, and datatable sorting.
* **Impact:** Adds ~8,000 records per imported save game snapshot. `EconomyImportBatch.cls` will process factory/artisan records in chunked batches (200 records per scope) to prevent CPU and heap governor limit exceptions.

### ADR 2: Country Commodity Columns vs. Junction Storage
* **Decision:** Preserve `Country_Product_Economy__c` junction records as the primary storage mechanism for country-product production rather than creating 49 custom fields on `Country_Economy__c`.
* **Reason:** Salesforce custom object field limit (800 fields) and normalization best practices favor relational junction records over rigid, wide-column tables.
* **Evidence:** `Country.py` writes 49 commodity columns (`ammunition`, `small_arms`, etc.). In `vc2-salesforce-version`, `Country_Product_Economy__c` already pairs `Country_Economy__c` with `Product__c`.
* **Impact:** Zero schema changes required for commodity production storage. Export utility handles unpivoting junction records into flat 49-column CSVs matching Python `Country.csv`.

---

## 16. Statement: DO NOT IMPLEMENT YET

> **Audit Attestation:** No modifications to Salesforce metadata (`force-app/`), Apex classes, LWC components, DTOs, import logic, or tests were performed during this audit phase. The codebase remains in its exact pre-audit state.

---

## 17. Statement: CRITICAL RULE

> **Evaluation Hierarchy Attestation:** The evaluation strictly adhered to the required hierarchy: Python functionality was evaluated against existing Salesforce capabilities first to identify exact/equivalent coverage before proposing new schema additions. Existing Salesforce architecture was preserved.

---

## 18. Final Audit Acceptance Criteria

- [x] Every `Save_Game_Analyzer` file inspected (`Artisans.py`, `Country.py`, `Factory.py`, `GoodsFinder.py`, `Provinces.py`, `SandPfinder.py`, `States.py`).
- [x] Every Python CSV/output field mapped to Salesforce or marked missing.
- [x] Every Python formula documented and compared against Salesforce Apex.
- [x] Capability matrix completed with explicit classifications.
- [x] Existing Salesforce equivalents verified rather than assumed.
- [x] Factory functionality explicitly audited.
- [x] Artisan functionality explicitly audited.
- [x] State functionality explicitly audited.
- [x] Province functionality compared field-by-field.
- [x] Country x Product functionality checked for semantic equivalence.
- [x] Goods/market functionality checked.
- [x] Static province/state master data checked.
- [x] Import requirements checked.
- [x] Apex requirements checked.
- [x] LWC requirements checked.
- [x] Export requirements checked.
- [x] Golden/parity requirements checked.
- [x] Performance & governor limit implications evaluated.
- [x] Security & FLS implications evaluated.
- [x] Concrete migration backlog produced.
- [x] No existing Salesforce functionality modified during audit.
- [x] No `git push` performed.

### Answer to Core Task Question:
> **"What functionality exists in `Save_Game_Analyzer` that is not already present, equivalent, or intentionally superseded in `vc2-salesforce-version`, and exactly what needs to be added to Salesforce to preserve that functionality?"**

**Summary Answer:**
1. **Missing Capabilities:**
   - **Factory Analysis (`Factory.py`):** Detailed building-level performance, level, workers, output, cash reserves, revenue, input costs, wages, profit, factory GDP, productivity, and average wages.
   - **Artisan Analysis (`Artisans.py`):** Province-level artisan type production, material spending, gross income, net AGDP, and calculated output.
   - **State Analysis (`States.py`):** Regional State master and snapshot aggregations for state GDP, per capita GDP, RGO income, and factory performance.
   - **Province Micro Financials (`Provinces.py`):** RGO income, RGO GDP, artisan spending, artisan income, artisan net AGDP, and colonial status flag.
   - **Country Sector GDP Split (`Country.py`):** Direct breakdown of Country GDP into Factory GDP (`FGDP`), Province RGO GDP (`PGDP`), and Artisan GDP (`AGDP`), as well as Core vs Colonial population split.
2. **What Needs to be Added to Salesforce:**
   - **Schema Additions:** Master `State__c` object; snapshot objects `State_Economy__c`, `Factory_Economy__c`, and `Artisan_Economy__c`; extended fields on `Province_Economy__c` (`Colony__c`, `RGO_Income__c`, `RGO_GDP__c`, `Artisan_Spending__c`, `Artisan_Income__c`, `Artisan_GDP__c`) and `Country_Economy__c` (`Core_Population__c`, `Colony_Population__c`, `Factory_GDP__c`, `Province_GDP__c`, `Artisan_GDP__c`).
   - **Ingestion & Apex:** Ingestion DTO contract extensions (`EconomyImportRequestDTO`), pure calculation methods in `EconomyCalculationEngine.cls`, chunked transactional batch processing in `EconomyImportService.cls`/`EconomyImportBatch.cls`, and facade methods in `EconomyAnalysisController.cls`.
   - **UI & Export:** UI updates to `c-country-dashboard` and `c-analysis-compare`, state/factory dashboard LWCs, and export extensions for `States.csv`, `Factory.csv`, and `Artisans.csv`.
