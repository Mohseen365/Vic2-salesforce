# Victoria 2 Economy Analyzer — Salesforce Field Inventory

This document provides the authoritative inventory of all Custom Objects, Custom Fields, Data Types, Precisions, Formulas, External IDs, and Relationships created in the application.

## Summary Metrics
- **Custom Objects:** 13
- **Custom Fields:** 138

---

## Custom Object: `Artisan_Economy__c` (Artisan Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `AGDP__c` | AGDP (£) | Currency | 18, 2 | - | None |
| `Artisan_Type__c` | Artisan Type | Text | 100 | - | None |
| `Country_Economy__c` | Country Economy | Lookup | - | Target: `Country_Economy__c`, Rel: `Artisan_Economies` | Required |
| `Economy_Analysis__c` | Economy Analysis | MasterDetail | - | Target: `Economy_Analysis__c`, Rel: `Artisan_Economies` | None |
| `Income__c` | Income (£) | Currency | 18, 2 | - | None |
| `Product__c` | Product | Lookup | - | Target: `Product__c`, Rel: `Artisan_Economies` | Required |
| `Production_Quantity__c` | Production Quantity | Number | 18, 2 | - | None |
| `Province_Economy__c` | Province Economy | Lookup | - | Target: `Province_Economy__c`, Rel: `Artisan_Economies` | Required |
| `Spending__c` | Spending (£) | Currency | 18, 2 | - | None |
| `State_Economy__c` | State Economy | Lookup | - | Target: `State_Economy__c`, Rel: `Artisan_Economies` | None |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 150 | - | External ID, Unique, Required |

---

## Custom Object: `Country_Economy__c` (Country Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Artisan_GDP__c` | Artisan GDP (£) | Currency | 18, 2 | - | None |
| `Colony_Population__c` | Colony Population | Number | 18, 0 | - | None |
| `Core_Population__c` | Core Population | Number | 18, 0 | - | None |
| `Country_Tag__c` | Country Tag | Text | 10 | - | None |
| `Country__c` | Country | Lookup | - | Target: `Country__c`, Rel: `Country_Economies` | Required |
| `Economy_Analysis__c` | Economy Analysis | MasterDetail | - | Target: `Economy_Analysis__c`, Rel: `Country_Economies` | None |
| `Employment_Factory__c` | Employment Factory | Number | 18, 0 | - | None |
| `Employment_RGO__c` | Employment RGO | Number | 18, 0 | - | None |
| `Employment__c` | Employment | Number | 18, 0 | - | None |
| `Factory_GDP__c` | Factory GDP (£) | Currency | 18, 2 | - | None |
| `GDP_Per_Capita__c` | GDP Per Capita (£/100k) | Currency | 18, 2 | `IF(Core_Population__c > 0, GDP__c / Core_Population__c, 0.0)` | None |
| `GDP_Rank__c` | GDP Rank | Number | 6, 0 | - | None |
| `GDP_Share_Percent__c` | GDP Share % | Percent | 6, 4 | `IF(Economy_Analysis__r.Total_World_GDP__c > 0, GDP__c / Economy_Analysis__r.Total_World_GDP__c, 0.0)` | None |
| `GDP__c` | GDP (£) | Currency | 18, 2 | - | None |
| `Gold_Income__c` | Gold Income (£) | Currency | 18, 2 | - | None |
| `Population__c` | Population | Number | 18, 0 | - | None |
| `Province_GDP__c` | Province GDP (£) | Currency | 18, 2 | - | None |
| `Total_Exports_Value__c` | Total Exports Value (£) | Summary | - | SUM(`Country_Product_Economy__c.Export_Value__c`) | None |
| `Total_Imports_Value__c` | Total Imports Value (£) | Summary | - | SUM(`Country_Product_Economy__c.Import_Value__c`) | None |
| `Unemployment_Rate_Factory__c` | Unemployment Rate Factory | Percent | 6, 2 | `IF(Workforce_Factory__c > 0, (Workforce_Factory__c - Employment_Factory__c) / Workforce_Factory__c, 0.0)` | None |
| `Unemployment_Rate_RGO__c` | Unemployment Rate RGO | Percent | 6, 2 | `IF(Workforce_RGO__c > 0, (Workforce_RGO__c - Employment_RGO__c) / Workforce_RGO__c, 0.0)` | None |
| `Unemployment_Rate__c` | Unemployment Rate | Percent | 6, 2 | `IF(Workforce__c > 0, (Workforce__c - Employment__c) / Workforce__c, 0.0)` | None |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 100 | - | External ID, Unique, Required |
| `Workforce_Factory__c` | Workforce Factory | Number | 18, 0 | - | None |
| `Workforce_RGO__c` | Workforce RGO | Number | 18, 0 | - | None |
| `Workforce__c` | Workforce | Number | 18, 0 | - | None |

---

## Custom Object: `Country_Product_Economy__c` (Country Product Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Actual_Demand_Pounds__c` | Actual Demand (£) | Currency | 18, 2 | - | None |
| `Actual_Sold_World__c` | Actual Sold World | Number | 18, 4 | - | None |
| `Actual_Supply_Pounds__c` | Actual Supply (£) | Currency | 18, 2 | - | None |
| `Bought_Quantity__c` | Bought Quantity | Number | 18, 4 | - | None |
| `Country_Economy__c` | Country Economy | MasterDetail | - | Target: `Country_Economy__c`, Rel: `Country_Product_Economies` | None |
| `Domestic_Sales_Value__c` | Domestic Sales Value (£) | Currency | 18, 2 | - | None |
| `Export_Value__c` | Export Value (£) | Currency | 18, 2 | - | None |
| `GDP_Contribution__c` | GDP Contribution (£) | Currency | 18, 2 | - | None |
| `Import_Value__c` | Import Value (£) | Currency | 18, 2 | - | None |
| `Intermediate_Consumption__c` | Intermediate Consumption | Number | 18, 4 | - | None |
| `Product_Code__c` | Product Code | Text | 50 | - | None |
| `Product_Economy__c` | Product Economy | Lookup | - | Target: `Product_Economy__c`, Rel: `Country_Product_Economies` | Required |
| `Product__c` | Product | Lookup | - | Target: `Product__c`, Rel: `Country_Product_Economies` | Required |
| `Sold_Domestic__c` | Sold Domestic | Number | 18, 4 | - | None |
| `Sold_Quantity__c` | Sold Quantity | Number | 18, 4 | - | None |
| `Thrown_To_Market__c` | Thrown To Market | Number | 18, 4 | - | None |
| `Total_Supply_Pounds__c` | Total Supply (£) | Currency | 18, 2 | - | None |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 150 | - | External ID, Unique, Required |
| `Worldmarket_Pool__c` | Worldmarket Pool | Number | 18, 4 | - | None |

---

## Custom Object: `Country__c` (Country)
- **Sharing Model:** `ReadWrite`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Flag_URL__c` | Flag URL | Url | - | - | None |
| `Tag__c` | Country Tag | Text | 10 | - | External ID, Unique, Required |

---

## Custom Object: `Economy_Analysis__c` (Economy Analysis)
- **Sharing Model:** `ReadWrite`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Analysis_Timestamp__c` | Analysis Timestamp | DateTime | - | - | None |
| `Import_Diagnostic_Message__c` | Import Diagnostic Message | LongTextArea | 32768 | - | None |
| `Import_Status__c` | Import Status | Picklist | - | - | None |
| `Ingame_Date__c` | Ingame Date | Date | - | - | Required |
| `Player_Country_Tag__c` | Player Country Tag | Text | 10 | - | None |
| `Save_File_Name__c` | Save File Name | Text | 255 | - | External ID, Unique, Required |
| `Source_Save_File_Name__c` | Source Save File Name | Text | 255 | - | None |
| `Total_World_Exports__c` | Total World Exports (£) | Currency | 18, 2 | - | None |
| `Total_World_GDP__c` | Total World GDP | Summary | - | SUM(`Country_Economy__c.GDP__c`) | None |
| `Total_World_Imports__c` | Total World Imports (£) | Currency | 18, 2 | - | None |
| `Total_World_Population__c` | Total World Population | Summary | - | SUM(`Country_Economy__c.Population__c`) | None |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 255 | - | External ID, Unique |

---

## Custom Object: `Economy_Import_Event__e` (Economy Import Event)
- **Sharing Model:** `N/A (Custom Event)`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Analysis_Id__c` | Analysis Id | Text | 18 | - | None |
| `Diagnostic_Message__c` | Diagnostic Message | Text | 255 | - | None |
| `Record_Count__c` | Record Count | Number | 18, 0 | - | None |
| `Status__c` | Status | Text | 20 | - | None |

---

## Custom Object: `Factory_Economy__c` (Factory Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Average_Wage__c` | Average Wage (£/person) | Currency | 18, 4 | `IF(Employees__c > 0, Wages_Paid__c / Employees__c, 0.0)` | None |
| `Building_Type__c` | Building Type | Text | 100 | - | Required |
| `Capital_Reserves__c` | Capital Reserves (£) | Currency | 18, 2 | - | None |
| `Country_Economy__c` | Country Economy | Lookup | - | Target: `Country_Economy__c`, Rel: `Factory_Economies` | Required |
| `Economy_Analysis__c` | Economy Analysis | MasterDetail | - | Target: `Economy_Analysis__c`, Rel: `Factory_Economies` | None |
| `Employees__c` | Employees | Number | 18, 0 | - | None |
| `Factory_GDP__c` | Factory GDP (£) | Currency | 18, 2 | - | None |
| `Injected_Money__c` | Injected Money (£) | Currency | 18, 2 | - | None |
| `Input_Cost__c` | Input Cost (£) | Currency | 18, 2 | - | None |
| `Level__c` | Level | Number | 4, 0 | - | None |
| `Occurrence_Index__c` | Occurrence Index | Number | 4, 0 | - | Required |
| `Output_Quantity__c` | Output Quantity | Number | 18, 2 | - | None |
| `Product__c` | Product | Lookup | - | Target: `Product__c`, Rel: `Factory_Economies` | None |
| `Productivity__c` | Productivity (£/person) | Currency | 18, 4 | `IF(Employees__c > 0, Factory_GDP__c / Employees__c, 0.0)` | None |
| `Profit_Rank__c` | Profit Rank | Number | 6, 0 | - | None |
| `Profit__c` | Profit (£) | Currency | 18, 2 | `Revenue__c - Input_Cost__c - Wages_Paid__c` | None |
| `Revenue__c` | Revenue (£) | Currency | 18, 2 | - | None |
| `State_Economy__c` | State Economy | Lookup | - | Target: `State_Economy__c`, Rel: `Factory_Economies` | Required |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 255 | - | External ID, Unique, Required |
| `Unsold_Quantity__c` | Unsold Quantity | Number | 18, 2 | - | None |
| `Wages_Paid__c` | Wages Paid (£) | Currency | 18, 2 | - | None |

---

## Custom Object: `Product_Economy__c` (Product Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Base_Price__c` | Base Price | Currency | 18, 4 | - | None |
| `Economy_Analysis__c` | Economy Analysis | MasterDetail | - | Target: `Economy_Analysis__c`, Rel: `Product_Economies` | None |
| `Inflation_Percent__c` | Inflation % | Percent | 6, 2 | `IF(Base_Price__c > 0, (Price__c - Base_Price__c) / Base_Price__c, 0.0)` | None |
| `Max_Demand__c` | Max Demand | Number | 18, 4 | - | None |
| `Overproduction_Percent__c` | Overproduction % | Percent | 6, 2 | `IF(Real_Demand__c > 0, (Total_World_Supply__c / Real_Demand__c) * 100, 0.0)` | None |
| `Price__c` | Price | Currency | 18, 4 | - | None |
| `Product_Code__c` | Product Code | Text | 50 | - | None |
| `Product__c` | Product | Lookup | - | Target: `Product__c`, Rel: `Product_Economies` | Required |
| `Real_Demand__c` | Real Demand | Number | 18, 4 | - | None |
| `Total_World_Supply__c` | Total World Supply | Number | 18, 4 | - | None |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 100 | - | External ID, Unique, Required |

---

## Custom Object: `Product__c` (Product)
- **Sharing Model:** `ReadWrite`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Base_Price__c` | Base Price | Currency | 18, 4 | - | None |
| `Code__c` | Product Code | Text | 50 | - | External ID, Unique, Required |

---

## Custom Object: `Province_Economy__c` (Province Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Artisan_GDP__c` | Artisan GDP (£) | Currency | 18, 2 | - | None |
| `Artisan_Income__c` | Artisan Income (£) | Currency | 18, 2 | - | None |
| `Artisan_Spending__c` | Artisan Spending (£) | Currency | 18, 2 | - | None |
| `Colony__c` | Colony | Checkbox | - | - | None |
| `Country_Economy__c` | Country Economy | MasterDetail | - | Target: `Country_Economy__c`, Rel: `Province_Economies` | None |
| `Population__c` | Population | Number | 18, 0 | - | None |
| `Province__c` | Province | Lookup | - | Target: `Province__c`, Rel: `Province_Economies` | Required |
| `RGO_GDP__c` | RGO GDP (£) | Currency | 18, 2 | - | None |
| `RGO_Income__c` | RGO Income (£) | Currency | 18, 2 | - | None |
| `RGO_Production__c` | RGO Production | Number | 18, 4 | - | None |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 150 | - | External ID, Unique, Required |

---

## Custom Object: `Province__c` (Province)
- **Sharing Model:** `ReadWrite`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Country__c` | Country | Lookup | - | Target: `Country__c`, Rel: `Provinces` | None |
| `External_Province_Id__c` | External Province ID | Text | 50 | - | External ID, Unique, Required |

---

## Custom Object: `State_Economy__c` (State Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `AGDP__c` | AGDP (£) | Currency | 18, 2 | - | None |
| `Country_Economy__c` | Country Economy | Lookup | - | Target: `Country_Economy__c`, Rel: `State_Economies` | Required |
| `Economy_Analysis__c` | Economy Analysis | MasterDetail | - | Target: `Economy_Analysis__c`, Rel: `State_Economies` | None |
| `FGDP__c` | FGDP (£) | Currency | 18, 2 | - | None |
| `Factory_Employees__c` | Factory Employees | Number | 18, 0 | - | None |
| `Factory_Profit__c` | Factory Profit (£) | Currency | 18, 2 | - | None |
| `Factory_Revenue__c` | Factory Revenue (£) | Currency | 18, 2 | - | None |
| `GDP_Per_Capita__c` | GDP Per Capita (£) | Currency | 18, 2 | `IF(Population__c > 0, GDP__c / Population__c, 0.0)` | None |
| `GDP_Rank__c` | GDP Rank | Number | 6, 0 | - | None |
| `GDP__c` | GDP (£) | Currency | 18, 2 | - | None |
| `PGDP__c` | PGDP (£) | Currency | 18, 2 | - | None |
| `Population__c` | Population | Number | 18, 0 | - | None |
| `RGO_Income__c` | RGO Income (£) | Currency | 18, 2 | - | None |
| `State__c` | State | Lookup | - | Target: `State__c`, Rel: `State_Economies` | Required |
| `Unique_Snapshot_Key__c` | Unique Snapshot Key | Text | 100 | - | External ID, Unique, Required |

---

## Custom Object: `State__c` (State)
- **Sharing Model:** `ReadWrite`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Country__c` | Country | Lookup | - | Target: `Country__c`, Rel: `States` | Required |
| `State_Code__c` | State Code | Text | 50 | - | External ID, Unique, Required |

---


# Track B — Full Save-Game Model
This section details the expanded save-game entities and custom fields added in Track B to represent the full Clausewitz save structure.

## AccumulatedLosse__c ('AccumulatedLosse') — 1 custom fields
- `Value__c` (Number) — Value

## ActiveInvention__c ('ActiveInvention') — 1 custom fields
- `Value__c` (Number) — Value

## ActiveParty__c ('ActiveParty') — 0 custom fields

## ActiveWar__c ('ActiveWar') — 7 custom fields
- `Action__c` (Text) — Action
- `Defender__c` (Text) — Defender
- `History__c` (Lookup) — History [Ref: Save_Game__c]
- `Name__c` (Text) — Name
- `Original_attacker__c` (Text) — Original attacker
- `Original_defender__c` (Text) — Original defender
- `Original_wargoal__c` (Lookup) — Original wargoal [Ref: Save_Game__c]

## ActualSoldDomestic__c ('ActualSoldDomestic') — 0 custom fields

## AiHardStrategy__c ('AiHardStrategy') — 5 custom fields
- `Consolidate__c` (Checkbox) — Consolidate
- `Date__c` (Text) — Date
- `Initialized__c` (Checkbox) — Initialized
- `Personality__c` (Text) — Personality
- `Static__c` (Checkbox) — Static

## Ai__c ('Ai') — 14 custom fields
- `Antagonize__c` (Lookup) — Antagonize [Ref: Save_Game__c]
- `Befriend__c` (Lookup) — Befriend [Ref: Save_Game__c]
- `Building_prov__c` (Lookup) — Building prov [Ref: Save_Game__c]
- `Consolidate__c` (Checkbox) — Consolidate
- `Date__c` (Text) — Date
- `Initialized__c` (Checkbox) — Initialized
- `Military_access__c` (Lookup) — Military access [Ref: Save_Game__c]
- `Personality__c` (Text) — Personality
- `Protect__c` (Lookup) — Protect [Ref: Save_Game__c]
- `Rival__c` (Lookup) — Rival [Ref: Save_Game__c]
- `Static__c` (Checkbox) — Static
- `Status__c` (Number) — Status
- `Threat__c` (Lookup) — Threat [Ref: Save_Game__c]
- `War_with__c` (Lookup) — War with [Ref: Save_Game__c]

## Alliance__c ('Alliance') — 4 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date

## AnarchoLiberal__c ('AnarchoLiberal') — 1 custom fields
- `Enable__c` (Text) — Enable

## Antagonize__c ('Antagonize') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Army__c ('Army') — 11 custom fields
- `Base__c` (Number) — Base
- `Dig_in__c` (Number) — Dig in
- `Dig_in_last_date__c` (Text) — Dig in last date
- `Location__c` (Number) — Location
- `Movement_progress__c` (Number) — Movement progress
- `Name__c` (Text) — Name
- `Path__c` (Lookup) — Path [Ref: Save_Game__c]
- `Previous__c` (Number) — Previous
- `Regiment__c` (Lookup) — Regiment [Ref: Save_Game__c]
- `Supplies__c` (Number) — Supplies
- `Target__c` (Number) — Target

## Article__c ('Article') — 2 custom fields
- `News_scope__c` (Lookup) — News scope [Ref: Save_Game__c]
- `Size__c` (Text) — Size

## Attacker__c ('Attacker') — 8 custom fields
- `Accumulated_losses__c` (Lookup) — Accumulated losses [Ref: Save_Game__c]
- `Back__c` (Lookup) — Back [Ref: Save_Game__c]
- `Country__c` (Text) — Country
- `Dice__c` (Number) — Dice
- `Front__c` (Lookup) — Front [Ref: Save_Game__c]
- `Irregular__c` (Number) — Irregular
- `Leader__c` (Text) — Leader
- `Losses__c` (Number) — Losses

## Back__c ('Back') — 0 custom fields

## Battle__c ('Battle') — 5 custom fields
- `Attacker__c` (Lookup) — Attacker [Ref: Save_Game__c]
- `Defender__c` (Lookup) — Defender [Ref: Save_Game__c]
- `Location__c` (Number) — Location
- `Name__c` (Text) — Name
- `Result__c` (Checkbox) — Result

## Befriend__c ('Befriend') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## BudgetBalance__c ('BudgetBalance') — 1 custom fields
- `Value__c` (Number) — Value

## BuildingProv__c ('BuildingProv') — 3 custom fields
- `Id__c` (Number) — Id
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## BuiltNew__c ('BuiltNew') — 5 custom fields
- `Date__c` (Text) — Date
- `Is_read__c` (Checkbox) — Is read
- `Seed__c` (Number) — Seed
- `Style__c` (Number) — Style
- `Title_image__c` (Text) — Title image

## BuyDomestic__c ('BuyDomestic') — 0 custom fields

## Canal__c ('Canal') — 1 custom fields
- `Value__c` (Number) — Value

## CasusBelli__c ('CasusBelli') — 5 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date
- `Type__c` (Text) — Type

## Colonize__c ('Colonize') — 1 custom fields
- `N_283__c` (Number) — N 283

## Colony__c ('Colony') — 4 custom fields
- `Date__c` (Text) — Date
- `Invest__c` (Number) — Invest
- `Points__c` (Number) — Points
- `Tag__c` (Text) — Tag

## Combat__c ('Combat') — 0 custom fields

## Communist__c ('Communist') — 0 custom fields

## ConquerProv__c ('ConquerProv') — 2 custom fields
- `Id__c` (Number) — Id
- `Value__c` (Number) — Value

## Construction__c ('Construction') — 5 custom fields
- `Building__c` (Number) — Building
- `Country__c` (Text) — Country
- `Date__c` (Text) — Date
- `Location__c` (Number) — Location
- `Start_date__c` (Text) — Start date

## Consumption_Cache__c ('Consumption Cache') — 0 custom fields

## Country_Country_Ref__c ('Country Country Ref') — 4 custom fields
- `Country_Save_State__c` (MasterDetail) — Country Save State [Ref: Country_Save_State__c]
- `Country__c` (Lookup) — Country [Ref: Country__c]
- `Relationship_Type__c` (Text) — Relationship Type
- `Target_Country_Tag__c` (Text) — Target Country Tag

## Country_Save_State__c ('Country Save State') — 123 custom fields
- `Active_inventions__c` (Lookup) — Active inventions [Ref: Save_Game__c]
- `Actual_sold_domestic__c` (Lookup) — Actual sold domestic [Ref: Save_Game__c]
- `Admin_reform__c` (Text) — Admin reform
- `Ai__c` (Lookup) — Ai [Ref: Save_Game__c]
- `Ai_hard_strategy__c` (Lookup) — Ai hard strategy [Ref: Save_Game__c]
- `Army__c` (Lookup) — Army [Ref: Save_Game__c]
- `Army_schools__c` (Text) — Army schools
- `Auto_assign_leaders__c` (Checkbox) — Auto assign leaders
- `Auto_create_leaders__c` (Checkbox) — Auto create leaders
- `Badboy__c` (Number) — Badboy
- `Ban_embassy__c` (Text) — Ban embassy
- `Ban_embassy_country__c` (Text) — Ban embassy country
- `Buy_domestic__c` (Lookup) — Buy domestic [Ref: Save_Game__c]
- `Campaign_counter__c` (Number) — Campaign counter
- `Capital__c` (Number) — Capital
- `Civilized__c` (Checkbox) — Civilized
- `Colonize__c` (Lookup) — Colonize [Ref: Save_Game__c]
- `Creditor__c` (Lookup) — Creditor [Ref: Save_Game__c]
- `Culture__c` (Lookup) — Culture [Ref: Save_Game__c]
- `Diplomatic_points__c` (Number) — Diplomatic points
- `Discredit__c` (Text) — Discredit
- `Discreditor__c` (Text) — Discreditor
- `Domain_region__c` (Text) — Domain region
- `Domestic_demand_pool__c` (Lookup) — Domestic demand pool [Ref: Save_Game__c]
- `Domestic_supply_pool__c` (Lookup) — Domestic supply pool [Ref: Save_Game__c]
- `Education_reform__c` (Text) — Education reform
- `Election__c` (Text) — Election
- `Expenses__c` (Lookup) — Expenses [Ref: Save_Game__c]
- `Finance_reform__c` (Text) — Finance reform
- `Flags__c` (Lookup) — Flags [Ref: Save_Game__c]
- `Foreign_investment__c` (Lookup) — Foreign investment [Ref: Save_Game__c]
- `Foreign_naval_officers__c` (Text) — Foreign naval officers
- `Foreign_navies__c` (Text) — Foreign navies
- `Foreign_officers__c` (Text) — Foreign officers
- `Foreign_training__c` (Text) — Foreign training
- `Foreign_weapons__c` (Text) — Foreign weapons
- `Government__c` (Text) — Government
- `Government_flag__c` (Lookup) — Government flag [Ref: Save_Game__c]
- `Health_care__c` (Text) — Health care
- `Human__c` (Checkbox) — Human
- `Illegal_inventions__c` (Lookup) — Illegal inventions [Ref: Save_Game__c]
- `Incomes__c` (Lookup) — Incomes [Ref: Save_Game__c]
- `Industrial_construction__c` (Text) — Industrial construction
- `Influence__c` (Lookup) — Influence [Ref: Save_Game__c]
- `Influence_overflow__c` (Number) — Influence overflow
- `Influence_value__c` (Number) — Influence value
- `Interesting_countries__c` (Lookup) — Interesting countries [Ref: Save_Game__c]
- `Is_releasable_vassal__c` (Checkbox) — Is releasable vassal
- `Land_reform__c` (Text) — Land reform
- `Last_bankrupt__c` (Text) — Last bankrupt
- `Last_election__c` (Text) — Last election
- `Last_greatness_date__c` (Text) — Last greatness date
- `Last_lost_war__c` (Text) — Last lost war
- `Last_mission_cancel__c` (Text) — Last mission cancel
- `Last_reform__c` (Text) — Last reform
- `Last_send_diplomat__c` (Text) — Last send diplomat
- `Last_war__c` (Text) — Last war
- `Leader__c` (Lookup) — Leader [Ref: Save_Game__c]
- `Leadership__c` (Number) — Leadership
- `Level__c` (Number) — Level
- `Level_changed_date__c` (Text) — Level changed date
- `Max_bought__c` (Lookup) — Max bought [Ref: Save_Game__c]
- `Max_tariff__c` (Number) — Max tariff
- `Middle_tax__c` (Lookup) — Middle tax [Ref: Save_Game__c]
- `Military_access__c` (Checkbox) — Military access
- `Military_constructions__c` (Text) — Military constructions
- `Mobilize__c` (Checkbox) — Mobilize
- `Modifier__c` (Lookup) — Modifier [Ref: Save_Game__c]
- `Money__c` (Number) — Money
- `Movement__c` (Lookup) — Movement [Ref: Save_Game__c]
- `National_focus__c` (Lookup) — National focus [Ref: Save_Game__c]
- `Nationalvalue__c` (Text) — Nationalvalue
- `Naval_schools__c` (Text) — Naval schools
- `Navy__c` (Lookup) — Navy [Ref: Save_Game__c]
- `Next_quarterly_pulse__c` (Text) — Next quarterly pulse
- `Next_yearly_pulse__c` (Text) — Next yearly pulse
- `Overseas_penalty__c` (Number) — Overseas penalty
- `Pensions__c` (Text) — Pensions
- `Plurality__c` (Number) — Plurality
- `Political_parties__c` (Text) — Political parties
- `Poor_tax__c` (Lookup) — Poor tax [Ref: Save_Game__c]
- `Possible_inventions__c` (Lookup) — Possible inventions [Ref: Save_Game__c]
- `Pre_indust__c` (Text) — Pre indust
- `Press_rights__c` (Text) — Press rights
- `Prestige__c` (Number) — Prestige
- `Primary_culture__c` (Text) — Primary culture
- `Public_meetings__c` (Text) — Public meetings
- `Railroads__c` (Lookup) — Railroads [Ref: Save_Game__c]
- `Religion__c` (Text) — Religion
- `Research__c` (Lookup) — Research [Ref: Save_Game__c]
- `Research_points__c` (Number) — Research points
- `Revanchism__c` (Number) — Revanchism
- `Rich_tax__c` (Lookup) — Rich tax [Ref: Save_Game__c]
- `Ruling_party__c` (Number) — Ruling party
- `Safety_regulations__c` (Text) — Safety regulations
- `Saved_country_supply__c` (Lookup) — Saved country supply [Ref: Save_Game__c]
- `School_reforms__c` (Text) — School reforms
- `Schools__c` (Text) — Schools
- `Slavery__c` (Text) — Slavery
- `Sold_supply_pool__c` (Lookup) — Sold supply pool [Ref: Save_Game__c]
- `State__c` (Lookup) — State [Ref: Save_Game__c]
- `Suppression__c` (Number) — Suppression
- `Tag__c` (Text) — Tag
- `Tariffs__c` (Number) — Tariffs
- `Tax_base__c` (Number) — Tax base
- `Technology__c` (Lookup) — Technology [Ref: Save_Game__c]
- `Trade__c` (Lookup) — Trade [Ref: Save_Game__c]
- `Trade_cap_land__c` (Number) — Trade cap land
- `Trade_cap_naval__c` (Number) — Trade cap naval
- `Trade_cap_projects__c` (Number) — Trade cap projects
- `Trade_unions__c` (Text) — Trade unions
- `Transport_improv__c` (Text) — Transport improv
- `Truce_until__c` (Text) — Truce until
- `Unemployment_subsidies__c` (Text) — Unemployment subsidies
- `Upper_house__c` (Lookup) — Upper house [Ref: Save_Game__c]
- `Upper_house_composition__c` (Text) — Upper house composition
- `Value__c` (Number) — Value
- `Variables__c` (Lookup) — Variables [Ref: Save_Game__c]
- `Vote_franschise__c` (Text) — Vote franschise
- `Voting_system__c` (Text) — Voting system
- `Wage_reform__c` (Text) — Wage reform
- `War_exhaustion__c` (Number) — War exhaustion
- `Work_hours__c` (Text) — Work hours

## Creditor__c ('Creditor') — 4 custom fields
- `Country__c` (Text) — Country
- `Debt__c` (Number) — Debt
- `Interest__c` (Number) — Interest
- `Was_paid__c` (Checkbox) — Was paid

## CrisisManager__c ('CrisisManager') — 1 custom fields
- `Date__c` (Text) — Date

## Culture__c ('Culture') — 1 custom fields
- `Value__c` (Text) — Value

## Date__c ('Date') — 1 custom fields
- `Value__c` (Text) — Value

## Defender__c ('Defender') — 9 custom fields
- `Accumulated_losses__c` (Lookup) — Accumulated losses [Ref: Save_Game__c]
- `Back__c` (Lookup) — Back [Ref: Save_Game__c]
- `Country__c` (Text) — Country
- `Dice__c` (Number) — Dice
- `Front__c` (Lookup) — Front [Ref: Save_Game__c]
- `Infantry__c` (Number) — Infantry
- `Irregular__c` (Number) — Irregular
- `Leader__c` (Text) — Leader
- `Losses__c` (Number) — Losses

## Diplomacy__c ('Diplomacy') — 4 custom fields
- `Alliance__c` (Lookup) — Alliance [Ref: Save_Game__c]
- `Casus_belli__c` (Lookup) — Casus belli [Ref: Save_Game__c]
- `Substate__c` (Lookup) — Substate [Ref: Save_Game__c]
- `Vassal__c` (Lookup) — Vassal [Ref: Save_Game__c]

## DomesticDemandPool__c ('DomesticDemandPool') — 0 custom fields

## DomesticSupplyPool__c ('DomesticSupplyPool') — 0 custom fields

## Employee__c ('Employee') — 1 custom fields
- `Count__c` (Number) — Count

## Employment__c ('Employment') — 1 custom fields
- `State_province_id__c` (Number) — State province id

## Expense__c ('Expense') — 1 custom fields
- `Value__c` (Number) — Value

## Fascist__c ('Fascist') — 0 custom fields

## Fired_Event__c ('Fired Event') — 2 custom fields
- `Id__c` (Number) — Id
- `Type__c` (Number) — Type

## Fired_Events__c ('Fired Events') — 0 custom fields

## Flag__c ('Flag') — 59 custom fields
- `Apache_wars__c` (Checkbox) — Apache wars
- `Bixby_letter_sent__c` (Checkbox) — Bixby letter sent
- `Bonnie_blue_flag__c` (Checkbox) — Bonnie blue flag
- `Botanical_expedition_threatened__c` (Checkbox) — Botanical expedition threatened
- `Cavour_has_done_his__c` (Checkbox) — Cavour has done his
- `Clay_and_douglas_draft_enacted__c` (Checkbox) — Clay and douglas draft enacted
- `Code_of_laws__c` (Checkbox) — Code of laws
- `Corn_laws_repealed_flag__c` (Checkbox) — Corn laws repealed flag
- `Corwin_amendment_enacted__c` (Checkbox) — Corwin amendment enacted
- `Crisis_on_the_rhine__c` (Checkbox) — Crisis on the rhine
- `Dar_al_funun_built__c` (Checkbox) — Dar al funun built
- `Dred_scott_decision__c` (Checkbox) — Dred scott decision
- `Emigrant_aid_company__c` (Checkbox) — Emigrant aid company
- `Facundo__c` (Checkbox) — Facundo
- `French_foreign_legion_supported__c` (Checkbox) — French foreign legion supported
- `Fugitive_slave_act_enacted__c` (Checkbox) — Fugitive slave act enacted
- `Had_liberal_revolution__c` (Checkbox) — Had liberal revolution
- `Had_orange_river_convention__c` (Checkbox) — Had orange river convention
- `Hasmanifestdestiny__c` (Checkbox) — Hasmanifestdestiny
- `House_gag_rule_enacted__c` (Checkbox) — House gag rule enacted
- `HungarianLanguage__c` (Checkbox) — HungarianLanguage
- `IlyaGarashinin__c` (Checkbox) — IlyaGarashinin
- `Is_negusa_nagast__c` (Checkbox) — Is negusa nagast
- `Italia_ulterior__c` (Checkbox) — Italia ulterior
- `John_browns_raid__c` (Checkbox) — John browns raid
- `Kansas_nebraska_act_acting__c` (Checkbox) — Kansas nebraska act acting
- `Kanun_i_esasi_here__c` (Checkbox) — Kanun i esasi here
- `Kellys_irish_brigade__c` (Checkbox) — Kellys irish brigade
- `Lambert_has_been_chartered__c` (Checkbox) — Lambert has been chartered
- `Liberal_revolution_in_progress__c` (Checkbox) — Liberal revolution in progress
- `LouisNapoleonExtradited__c` (Checkbox) — LouisNapoleonExtradited
- `LouisPioFirst__c` (Checkbox) — LouisPioFirst
- `Mendizabal_confiscated__c` (Checkbox) — Mendizabal confiscated
- `Merina_monarchy_is_over__c` (Checkbox) — Merina monarchy is over
- `MozartFest1838__c` (Checkbox) — MozartFest1838
- `Nashville_convention_held__c` (Checkbox) — Nashville convention held
- `NoGoToNile__c` (Checkbox) — NoGoToNile
- `Participates_in_botanical_expedition__c` (Checkbox) — Participates in botanical expedition
- `Presbyteries_introduced__c` (Checkbox) — Presbyteries introduced
- `Princes_recieve_foreign_education__c` (Checkbox) — Princes recieve foreign education
- `SCAStudent__c` (Checkbox) — SCAStudent
- `Sepoy_rebellion__c` (Checkbox) — Sepoy rebellion
- `Serfdom_not_abolished__c` (Checkbox) — Serfdom not abolished
- `Signed_treay_of_london__c` (Checkbox) — Signed treay of london
- `State_controlled_rite__c` (Checkbox) — State controlled rite
- `That_book_written__c` (Checkbox) — That book written
- `The_slavery_debate__c` (Checkbox) — The slavery debate
- `Usstatehood_we_have_applied__c` (Checkbox) — Usstatehood we have applied
- `Value__c` (Text) — Value
- `Victoria_regina__c` (Checkbox) — Victoria regina
- `Von_moltke__c` (Checkbox) — Von moltke
- `Voule_ton_ellinon__c` (Checkbox) — Voule ton ellinon
- `Walhalla__c` (Checkbox) — Walhalla
- `Watching_the_rhine__c` (Checkbox) — Watching the rhine
- `Webster_ashburton_signed__c` (Checkbox) — Webster ashburton signed
- `YesGoToNileThird__c` (Checkbox) — YesGoToNileThird
- `YesGoToNile__c` (Checkbox) — YesGoToNile
- `You_did_try__c` (Checkbox) — You did try
- `Zul_cb_taken__c` (Checkbox) — Zul cb taken

## ForeignInvestment__c ('ForeignInvestment') — 1 custom fields
- `Value__c` (Number) — Value

## Front__c ('Front') — 0 custom fields

## Game_Flag__c ('Game Flag') — 2 custom fields
- `Flag_Name__c` (Text) — Flag Name
- `Flag_Value__c` (Checkbox) — Flag Value

## Gameplay_Settings__c ('Gameplay Settings') — 1 custom fields
- `Setgameplayoptions__c` (Lookup) — Setgameplayoptions [Ref: Save_Game__c]

## Goods_Vector_Line__c ('Goods Vector Line') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## GovernmentFlag__c ('GovernmentFlag') — 1 custom fields
- `Hms_government__c` (Text) — Hms government

## GreatNation__c ('GreatNation') — 1 custom fields
- `Value__c` (Number) — Value

## History__c ('History') — 11 custom fields
- `N_1870_11_12__c` (Lookup) — N 1870 11 12 [Ref: Save_Game__c]
- `N_1870_4_29__c` (Lookup) — N 1870 4 29 [Ref: Save_Game__c]
- `N_1870_6_28__c` (Lookup) — N 1870 6 28 [Ref: Save_Game__c]
- `N_1871_11_3__c` (Lookup) — N 1871 11 3 [Ref: Save_Game__c]
- `N_1871_5_24__c` (Lookup) — N 1871 5 24 [Ref: Save_Game__c]
- `N_1871_6_1__c` (Lookup) — N 1871 6 1 [Ref: Save_Game__c]
- `N_1871_8_25__c` (Lookup) — N 1871 8 25 [Ref: Save_Game__c]
- `N_1871_9_8__c` (Lookup) — N 1871 9 8 [Ref: Save_Game__c]
- `N_1872_2_17__c` (Lookup) — N 1872 2 17 [Ref: Save_Game__c]
- `N_1872_8_20__c` (Lookup) — N 1872 8 20 [Ref: Save_Game__c]
- `Name__c` (Text) — Name

## IllegalInvention__c ('IllegalInvention') — 1 custom fields
- `Value__c` (Number) — Value

## Income__c ('Income') — 1 custom fields
- `Value__c` (Number) — Value

## Influence__c ('Influence') — 51 custom fields
- `AFG__c` (Text) — AFG
- `ALD__c` (Text) — ALD
- `ANH__c` (Text) — ANH
- `AST__c` (Text) — AST
- `BAD__c` (Text) — BAD
- `BAL__c` (Text) — BAL
- `BEL__c` (Text) — BEL
- `BHU__c` (Text) — BHU
- `BRE__c` (Text) — BRE
- `BUK__c` (Text) — BUK
- `BUR__c` (Text) — BUR
- `CHI__c` (Text) — CHI
- `CLM__c` (Text) — CLM
- `CSA__c` (Text) — CSA
- `D02__c` (Text) — D02
- `D03__c` (Text) — D03
- `DAI__c` (Text) — DAI
- `HDJ__c` (Text) — HDJ
- `HEK__c` (Text) — HEK
- `HND__c` (Text) — HND
- `HOL__c` (Text) — HOL
- `ITA__c` (Text) — ITA
- `KAL__c` (Text) — KAL
- `KHI__c` (Text) — KHI
- `KOR__c` (Text) — KOR
- `KRA__c` (Text) — KRA
- `LIP__c` (Text) — LIP
- `LUA__c` (Text) — LUA
- `LUX__c` (Text) — LUX
- `MAK__c` (Text) — MAK
- `MCK__c` (Text) — MCK
- `MEX__c` (Text) — MEX
- `MGL__c` (Text) — MGL
- `MOL__c` (Text) — MOL
- `MON__c` (Text) — MON
- `NET__c` (Text) — NET
- `OMA__c` (Text) — OMA
- `PAN__c` (Text) — PAN
- `PER__c` (Text) — PER
- `ROM__c` (Text) — ROM
- `SIK__c` (Text) — SIK
- `SIN__c` (Text) — SIN
- `SOK__c` (Text) — SOK
- `SWE__c` (Text) — SWE
- `SWI__c` (Text) — SWI
- `TUN__c` (Text) — TUN
- `UCA__c` (Text) — UCA
- `WAL__c` (Text) — WAL
- `WUR__c` (Text) — WUR
- `XBI__c` (Text) — XBI
- `XIN__c` (Text) — XIN

## InputGood__c ('InputGood') — 1 custom fields
- `Money__c` (Number) — Money

## InterestingCountrie__c ('InterestingCountrie') — 1 custom fields
- `Value__c` (Number) — Value

## Invention__c ('Invention') — 1 custom fields
- `Value__c` (Number) — Value

## Leader__c ('Leader') — 8 custom fields
- `Background__c` (Text) — Background
- `Country__c` (Text) — Country
- `Date__c` (Text) — Date
- `Name__c` (Text) — Name
- `Personality__c` (Text) — Personality
- `Picture__c` (Text) — Picture
- `Prestige__c` (Number) — Prestige
- `Type__c` (Text) — Type

## Market_Line__c ('Market Line') — 3 custom fields
- `Key__c` (Text) — Key
- `Kind__c` (Text) — Kind
- `Value__c` (Number) — Value

## MaxBought__c ('MaxBought') — 0 custom fields

## MiddleTax__c ('MiddleTax') — 8 custom fields
- `Current__c` (Number) — Current
- `Max_tax__c` (Number) — Max tax
- `Min_tax__c` (Number) — Min tax
- `RangeLimitMax__c` (Number) — RangeLimitMax
- `RangeLimitMin__c` (Number) — RangeLimitMin
- `Tax_eff__c` (Lookup) — Tax eff [Ref: Save_Game__c]
- `Tax_income__c` (Lookup) — Tax income [Ref: Save_Game__c]
- `Total__c` (Number) — Total

## MilitaryAcces__c ('MilitaryAcces') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Modifier__c ('Modifier') — 2 custom fields
- `Date__c` (Text) — Date
- `Modifier__c` (Text) — Modifier

## Movement__c ('Movement') — 5 custom fields
- `Cache__c` (Number) — Cache
- `Issue__c` (Text) — Issue
- `Radicalism__c` (Number) — Radicalism
- `Support__c` (Number) — Support
- `Tag__c` (Text) — Tag

## NationalFocu__c ('NationalFocu') — 142 custom fields
- `N_100__c` (Text) — N 100
- `N_101__c` (Text) — N 101
- `N_103__c` (Text) — N 103
- `N_105__c` (Text) — N 105
- `N_10__c` (Text) — N 10
- `N_110__c` (Text) — N 110
- `N_113__c` (Text) — N 113
- `N_114__c` (Text) — N 114
- `N_117__c` (Text) — N 117
- `N_121__c` (Text) — N 121
- `N_129__c` (Text) — N 129
- `N_132__c` (Text) — N 132
- `N_133__c` (Text) — N 133
- `N_135__c` (Text) — N 135
- `N_136__c` (Text) — N 136
- `N_13__c` (Text) — N 13
- `N_147__c` (Text) — N 147
- `N_148__c` (Text) — N 148
- `N_158__c` (Text) — N 158
- `N_163__c` (Text) — N 163
- `N_166__c` (Text) — N 166
- `N_175__c` (Text) — N 175
- `N_183__c` (Text) — N 183
- `N_184__c` (Text) — N 184
- `N_190__c` (Text) — N 190
- `N_194__c` (Text) — N 194
- `N_202__c` (Text) — N 202
- `N_207__c` (Text) — N 207
- `N_208__c` (Text) — N 208
- `N_209__c` (Text) — N 209
- `N_212__c` (Text) — N 212
- `N_213__c` (Text) — N 213
- `N_214__c` (Text) — N 214
- `N_230__c` (Text) — N 230
- `N_233__c` (Text) — N 233
- `N_235__c` (Text) — N 235
- `N_236__c` (Text) — N 236
- `N_240__c` (Text) — N 240
- `N_241__c` (Text) — N 241
- `N_242__c` (Text) — N 242
- `N_246__c` (Text) — N 246
- `N_249__c` (Text) — N 249
- `N_250__c` (Text) — N 250
- `N_253__c` (Text) — N 253
- `N_254__c` (Text) — N 254
- `N_255__c` (Text) — N 255
- `N_256__c` (Text) — N 256
- `N_257__c` (Text) — N 257
- `N_258__c` (Text) — N 258
- `N_261__c` (Text) — N 261
- `N_262__c` (Text) — N 262
- `N_263__c` (Text) — N 263
- `N_267__c` (Text) — N 267
- `N_268__c` (Text) — N 268
- `N_269__c` (Text) — N 269
- `N_26__c` (Text) — N 26
- `N_274__c` (Text) — N 274
- `N_276__c` (Text) — N 276
- `N_281__c` (Text) — N 281
- `N_282__c` (Text) — N 282
- `N_283__c` (Text) — N 283
- `N_285__c` (Text) — N 285
- `N_290__c` (Text) — N 290
- `N_349__c` (Text) — N 349
- `N_370__c` (Text) — N 370
- `N_372__c` (Text) — N 372
- `N_373__c` (Text) — N 373
- `N_377__c` (Text) — N 377
- `N_380__c` (Text) — N 380
- `N_382__c` (Text) — N 382
- `N_394__c` (Text) — N 394
- `N_397__c` (Text) — N 397
- `N_3__c` (Text) — N 3
- `N_402__c` (Text) — N 402
- `N_404__c` (Text) — N 404
- `N_406__c` (Text) — N 406
- `N_408__c` (Text) — N 408
- `N_409__c` (Text) — N 409
- `N_410__c` (Text) — N 410
- `N_413__c` (Text) — N 413
- `N_414__c` (Text) — N 414
- `N_415__c` (Text) — N 415
- `N_416__c` (Text) — N 416
- `N_418__c` (Text) — N 418
- `N_41__c` (Text) — N 41
- `N_429__c` (Text) — N 429
- `N_445__c` (Text) — N 445
- `N_446__c` (Text) — N 446
- `N_453__c` (Text) — N 453
- `N_455__c` (Text) — N 455
- `N_458__c` (Text) — N 458
- `N_470__c` (Text) — N 470
- `N_478__c` (Text) — N 478
- `N_481__c` (Text) — N 481
- `N_484__c` (Text) — N 484
- `N_4__c` (Text) — N 4
- `N_501__c` (Text) — N 501
- `N_503__c` (Text) — N 503
- `N_505__c` (Text) — N 505
- `N_507__c` (Text) — N 507
- `N_509__c` (Text) — N 509
- `N_50__c` (Text) — N 50
- `N_517__c` (Text) — N 517
- `N_51__c` (Text) — N 51
- `N_522__c` (Text) — N 522
- `N_523__c` (Text) — N 523
- `N_524__c` (Text) — N 524
- `N_525__c` (Text) — N 525
- `N_526__c` (Text) — N 526
- `N_527__c` (Text) — N 527
- `N_529__c` (Text) — N 529
- `N_530__c` (Text) — N 530
- `N_532__c` (Text) — N 532
- `N_533__c` (Text) — N 533
- `N_534__c` (Text) — N 534
- `N_535__c` (Text) — N 535
- `N_536__c` (Text) — N 536
- `N_537__c` (Text) — N 537
- `N_538__c` (Text) — N 538
- `N_539__c` (Text) — N 539
- `N_53__c` (Text) — N 53
- `N_540__c` (Text) — N 540
- `N_544__c` (Text) — N 544
- `N_55__c` (Text) — N 55
- `N_56__c` (Text) — N 56
- `N_57__c` (Text) — N 57
- `N_58__c` (Text) — N 58
- `N_60__c` (Text) — N 60
- `N_61__c` (Text) — N 61
- `N_67__c` (Text) — N 67
- `N_68__c` (Text) — N 68
- `N_69__c` (Text) — N 69
- `N_6__c` (Text) — N 6
- `N_72__c` (Text) — N 72
- `N_76__c` (Text) — N 76
- `N_7__c` (Text) — N 7
- `N_80__c` (Text) — N 80
- `N_86__c` (Text) — N 86
- `N_89__c` (Text) — N 89
- `N_90__c` (Text) — N 90
- `N_95__c` (Text) — N 95
- `N_99__c` (Text) — N 99

## Navy__c ('Navy') — 10 custom fields
- `Army__c` (Lookup) — Army [Ref: Save_Game__c]
- `At_sea__c` (Number) — At sea
- `Dig_in_last_date__c` (Text) — Dig in last date
- `Location__c` (Number) — Location
- `Movement_progress__c` (Number) — Movement progress
- `Name__c` (Text) — Name
- `Path__c` (Lookup) — Path [Ref: Save_Game__c]
- `Previous__c` (Number) — Previous
- `Ship__c` (Lookup) — Ship [Ref: Save_Game__c]
- `Supplies__c` (Number) — Supplies

## NewsCollector__c ('NewsCollector') — 3 custom fields
- `Date__c` (Text) — Date
- `Flags__c` (Lookup) — Flags [Ref: Save_Game__c]
- `Tension__c` (Number) — Tension

## NewsScope__c ('NewsScope') — 7 custom fields
- `Dates__c` (Lookup) — Dates [Ref: Save_Game__c]
- `Freshness__c` (Number) — Freshness
- `Name__c` (Text) — Name
- `Strings__c` (Lookup) — Strings [Ref: Save_Game__c]
- `Tags__c` (Lookup) — Tags [Ref: Save_Game__c]
- `Type__c` (Text) — Type
- `Values__c` (Lookup) — Values [Ref: Save_Game__c]

## News_Scope_Value__c ('News Scope Value') — 1 custom fields
- `Value__c` (Number) — Value

## OriginalWargoal__c ('OriginalWargoal') — 8 custom fields
- `Actor__c` (Text) — Actor
- `Casus_belli__c` (Text) — Casus belli
- `Change__c` (Number) — Change
- `Date__c` (Text) — Date
- `Is_fulfilled__c` (Checkbox) — Is fulfilled
- `Receiver__c` (Text) — Receiver
- `Score__c` (Number) — Score
- `State_province_id__c` (Number) — State province id

## Outliner__c ('Outliner') — 1 custom fields
- `Value__c` (Number) — Value

## Overseas_Penalty__c ('Overseas Penalty') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## Path__c ('Path') — 1 custom fields
- `Value__c` (Number) — Value

## PlayerMonthlyPopGrowth__c ('PlayerMonthlyPopGrowth') — 1 custom fields
- `Value__c` (Number) — Value

## PoorTax__c ('PoorTax') — 8 custom fields
- `Current__c` (Number) — Current
- `Max_tax__c` (Number) — Max tax
- `Min_tax__c` (Number) — Min tax
- `RangeLimitMax__c` (Number) — RangeLimitMax
- `RangeLimitMin__c` (Number) — RangeLimitMin
- `Tax_eff__c` (Lookup) — Tax eff [Ref: Save_Game__c]
- `Tax_income__c` (Lookup) — Tax income [Ref: Save_Game__c]
- `Total__c` (Number) — Total

## Pop_Need__c ('Pop Need') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## Pop_Stockpile__c ('Pop Stockpile') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## Pop__c ('Pop') — 33 custom fields
- `Bank__c` (Number) — Bank
- `Con__c` (Number) — Con
- `Con_factor__c` (Number) — Con factor
- `Converted__c` (Number) — Converted
- `Current_producing__c` (Number) — Current producing
- `Demoted__c` (Number) — Demoted
- `Id__c` (Number) — Id
- `Ideology_Key__c` (Text) — Ideology Key
- `Ideology_Value__c` (Number) — Ideology Value
- `Ideology__c` (Lookup) — Ideology [Ref: Save_Game__c]
- `Issue_Key__c` (Text) — Issue Key
- `Issue_Value__c` (Number) — Issue Value
- `Issues__c` (Lookup) — Issues [Ref: Save_Game__c]
- `Last_spending__c` (Number) — Last spending
- `Leftover__c` (Number) — Leftover
- `Literacy__c` (Number) — Literacy
- `Luxury_needs__c` (Number) — Luxury needs
- `Mil__c` (Number) — Mil
- `Money__c` (Number) — Money
- `Native_american_minor__c` (Text) — Native american minor
- `Needs_cost__c` (Number) — Needs cost
- `Percent_afforded__c` (Number) — Percent afforded
- `Percent_sold_domestic__c` (Number) — Percent sold domestic
- `Percent_sold_export__c` (Number) — Percent sold export
- `Pop_Type__c` (Text) — Pop Type
- `Production_income__c` (Number) — Production income
- `Production_type__c` (Text) — Production type
- `Promoted__c` (Number) — Promoted
- `Random__c` (Number) — Random
- `Russian__c` (Text) — Russian
- `Size__c` (Number) — Size
- `Throttle__c` (Number) — Throttle
- `Type__c` (Number) — Type

## Popproject__c ('Popproject') — 8 custom fields
- `Building__c` (Number) — Building
- `Index__c` (Number) — Index
- `Input_goods__c` (Lookup) — Input goods [Ref: Save_Game__c]
- `Money2__c` (Checkbox) — Money2
- `Money__c` (Number) — Money
- `Pop__c` (Number) — Pop
- `Province__c` (Number) — Province
- `Type__c` (Number) — Type

## PossibleInvention__c ('PossibleInvention') — 1 custom fields
- `Value__c` (Number) — Value

## PreviousWar__c ('PreviousWar') — 6 custom fields
- `Action__c` (Text) — Action
- `History__c` (Lookup) — History [Ref: Save_Game__c]
- `Name__c` (Text) — Name
- `Original_attacker__c` (Text) — Original attacker
- `Original_defender__c` (Text) — Original defender
- `Original_wargoal__c` (Lookup) — Original wargoal [Ref: Save_Game__c]

## Price_Snapshot__c ('Price Snapshot') — 48 custom fields
- `Aeroplanes__c` (Number) — Aeroplanes
- `Ammunition__c` (Number) — Ammunition
- `Artillery__c` (Number) — Artillery
- `Automobiles__c` (Number) — Automobiles
- `Barrels__c` (Number) — Barrels
- `Canned_food__c` (Number) — Canned food
- `Cattle__c` (Number) — Cattle
- `Cement__c` (Number) — Cement
- `Clipper_convoy__c` (Number) — Clipper convoy
- `Coal__c` (Number) — Coal
- `Coffee__c` (Number) — Coffee
- `Cotton__c` (Number) — Cotton
- `Dye__c` (Number) — Dye
- `Electric_gear__c` (Number) — Electric gear
- `Explosives__c` (Number) — Explosives
- `Fabric__c` (Number) — Fabric
- `Fertilizer__c` (Number) — Fertilizer
- `Fish__c` (Number) — Fish
- `Fruit__c` (Number) — Fruit
- `Fuel__c` (Number) — Fuel
- `Furniture__c` (Number) — Furniture
- `Glass__c` (Number) — Glass
- `Grain__c` (Number) — Grain
- `Iron__c` (Number) — Iron
- `Liquor__c` (Number) — Liquor
- `Lumber__c` (Number) — Lumber
- `Luxury_clothes__c` (Number) — Luxury clothes
- `Luxury_furniture__c` (Number) — Luxury furniture
- `Machine_parts__c` (Number) — Machine parts
- `Oil__c` (Number) — Oil
- `Opium__c` (Number) — Opium
- `Paper__c` (Number) — Paper
- `Precious_metal__c` (Number) — Precious metal
- `Radio__c` (Number) — Radio
- `Regular_clothes__c` (Number) — Regular clothes
- `Rubber__c` (Number) — Rubber
- `Silk__c` (Number) — Silk
- `Small_arms__c` (Number) — Small arms
- `Steamer_convoy__c` (Number) — Steamer convoy
- `Steel__c` (Number) — Steel
- `Sulphur__c` (Number) — Sulphur
- `Tea__c` (Number) — Tea
- `Telephones__c` (Number) — Telephones
- `Timber__c` (Number) — Timber
- `Tobacco__c` (Number) — Tobacco
- `Tropical_wood__c` (Number) — Tropical wood
- `Wine__c` (Number) — Wine
- `Wool__c` (Number) — Wool

## ProfitHistoryEntry__c ('ProfitHistoryEntry') — 1 custom fields
- `Value__c` (Number) — Value

## Protect__c ('Protect') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Province_Save_State__c ('Province Save State') — 13 custom fields
- `Building_construction__c` (Lookup) — Building construction [Ref: Save_Game__c]
- `Colonial__c` (Number) — Colonial
- `Controller__c` (Text) — Controller
- `Core__c` (Text) — Core
- `Garrison__c` (Number) — Garrison
- `Last_controller_change__c` (Text) — Last controller change
- `Last_imigration__c` (Text) — Last imigration
- `Life_rating__c` (Number) — Life rating
- `Name__c` (Text) — Name
- `Nationalism__c` (Number) — Nationalism
- `Owner__c` (Text) — Owner
- `Rgo__c` (Lookup) — Rgo [Ref: Save_Game__c]
- `Value__c` (Number) — Value

## RGO_Employment__c ('RGO Employment') — 1 custom fields
- `Province_id__c` (Number) — Province id

## RGO__c ('RGO') — 3 custom fields
- `Employment__c` (Lookup) — Employment [Ref: Save_Game__c]
- `Goods_type__c` (Text) — Goods type
- `Last_income__c` (Number) — Last income

## Railroad__c ('Railroad') — 1 custom fields
- `Path__c` (Lookup) — Path [Ref: Save_Game__c]

## RebelFaction__c ('RebelFaction') — 10 custom fields
- `Country__c` (Text) — Country
- `Culture__c` (Text) — Culture
- `Government__c` (Text) — Government
- `Independence__c` (Text) — Independence
- `Name__c` (Text) — Name
- `Next_unit__c` (Number) — Next unit
- `Organization__c` (Number) — Organization
- `Province__c` (Number) — Province
- `Religion__c` (Text) — Religion
- `Type__c` (Text) — Type

## Regiment__c ('Regiment') — 6 custom fields
- `Count__c` (Number) — Count
- `Experience__c` (Number) — Experience
- `Name__c` (Text) — Name
- `Organisation__c` (Number) — Organisation
- `Strength__c` (Number) — Strength
- `Type__c` (Text) — Type

## Region__c ('Region') — 3 custom fields
- `Index__c` (Number) — Index
- `Phase__c` (Number) — Phase
- `Temperature__c` (Number) — Temperature

## Research__c ('Research') — 5 custom fields
- `Active__c` (Checkbox) — Active
- `Cost__c` (Number) — Cost
- `Last_spending__c` (Number) — Last spending
- `Max_producing__c` (Number) — Max producing
- `Technology__c` (Text) — Technology

## RichTax__c ('RichTax') — 8 custom fields
- `Current__c` (Number) — Current
- `Max_tax__c` (Number) — Max tax
- `Min_tax__c` (Number) — Min tax
- `RangeLimitMax__c` (Number) — RangeLimitMax
- `RangeLimitMin__c` (Number) — RangeLimitMin
- `Tax_eff__c` (Lookup) — Tax eff [Ref: Save_Game__c]
- `Tax_income__c` (Lookup) — Tax income [Ref: Save_Game__c]
- `Total__c` (Number) — Total

## Rival__c ('Rival') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Save_Game_Country_Ref__c ('Save Game Country Ref') — 4 custom fields
- `Country__c` (Lookup) — Country [Ref: Country__c]
- `Reference_Key__c` (Text) — Reference Key
- `Reference_Kind__c` (Text) — Reference Kind
- `Save_Game__c` (MasterDetail) — Save Game [Ref: Save_Game__c]

## Save_Game__c ('Save Game') — 30 custom fields
- `Anarcho_liberal__c` (Lookup) — Anarcho liberal [Ref: Save_Game__c]
- `Automate_sliders__c` (Number) — Automate sliders
- `Automate_trade__c` (Checkbox) — Automate trade
- `Budget_balance__c` (Lookup) — Budget balance [Ref: Save_Game__c]
- `Canals__c` (Lookup) — Canals [Ref: Save_Game__c]
- `Combat__c` (Lookup) — Combat [Ref: Save_Game__c]
- `Communist__c` (Lookup) — Communist [Ref: Save_Game__c]
- `Crisis_manager__c` (Lookup) — Crisis manager [Ref: Save_Game__c]
- `Date__c` (Text) — Date
- `Diplomacy__c` (Lookup) — Diplomacy [Ref: Save_Game__c]
- `Fascist__c` (Lookup) — Fascist [Ref: Save_Game__c]
- `Fired_events__c` (Lookup) — Fired events [Ref: Save_Game__c]
- `Gameplaysettings__c` (Lookup) — Gameplaysettings [Ref: Save_Game__c]
- `Government__c` (Number) — Government
- `Great_nations__c` (Lookup) — Great nations [Ref: Save_Game__c]
- `Great_wars_enabled__c` (Checkbox) — Great wars enabled
- `Invention__c` (Lookup) — Invention [Ref: Save_Game__c]
- `News_collector__c` (Lookup) — News collector [Ref: Save_Game__c]
- `Outliner__c` (Lookup) — Outliner [Ref: Save_Game__c]
- `Player__c` (Text) — Player
- `Player_monthly_pop_growth__c` (Lookup) — Player monthly pop growth [Ref: Save_Game__c]
- `Player_monthly_pop_growth_date__c` (Text) — Player monthly pop growth date
- `Player_monthly_pop_growth_tag__c` (Text) — Player monthly pop growth tag
- `Rebel__c` (Number) — Rebel
- `Socialist__c` (Lookup) — Socialist [Ref: Save_Game__c]
- `Start_date__c` (Text) — Start date
- `Start_pop_index__c` (Number) — Start pop index
- `State__c` (Number) — State
- `Unit__c` (Number) — Unit
- `Worldmarket__c` (Lookup) — Worldmarket [Ref: Save_Game__c]

## SavedCountrySupply__c ('SavedCountrySupply') — 0 custom fields

## Setgameplayoption__c ('Setgameplayoption') — 1 custom fields
- `Value__c` (Number) — Value

## Ship__c ('Ship') — 6 custom fields
- `Count__c` (Number) — Count
- `Experience__c` (Number) — Experience
- `Name__c` (Text) — Name
- `Organisation__c` (Number) — Organisation
- `Strength__c` (Number) — Strength
- `Type__c` (Text) — Type

## SiegeCombat__c ('SiegeCombat') — 6 custom fields
- `Attacker__c` (Lookup) — Attacker [Ref: Save_Game__c]
- `Day__c` (Number) — Day
- `Defender__c` (Lookup) — Defender [Ref: Save_Game__c]
- `Duration__c` (Number) — Duration
- `Location__c` (Number) — Location
- `Total__c` (Number) — Total

## Socialist__c ('Socialist') — 1 custom fields
- `Enable__c` (Text) — Enable

## SoldSupplyPool__c ('SoldSupplyPool') — 0 custom fields

## StateBuilding__c ('StateBuilding') — 22 custom fields
- `Building__c` (Text) — Building
- `Construction_time_left__c` (Number) — Construction time left
- `Days_without_input__c` (Number) — Days without input
- `Employment__c` (Lookup) — Employment [Ref: Save_Game__c]
- `Injected_days__c` (Number) — Injected days
- `Injected_money__c` (Number) — Injected money
- `Input_goods__c` (Lookup) — Input goods [Ref: Save_Game__c]
- `Last_income__c` (Number) — Last income
- `Last_investment__c` (Number) — Last investment
- `Last_spending__c` (Number) — Last spending
- `Leftover__c` (Number) — Leftover
- `Level__c` (Number) — Level
- `Money__c` (Number) — Money
- `Pops_paychecks__c` (Number) — Pops paychecks
- `Priority__c` (Number) — Priority
- `Produces__c` (Number) — Produces
- `Profit_history_current__c` (Number) — Profit history current
- `Profit_history_days__c` (Number) — Profit history days
- `Profit_history_entry__c` (Lookup) — Profit history entry [Ref: Save_Game__c]
- `Stockpile__c` (Lookup) — Stockpile [Ref: Save_Game__c]
- `Subsidised__c` (Checkbox) — Subsidised
- `Unprofitable_days__c` (Number) — Unprofitable days

## State_Save_State__c ('State Save State') — 9 custom fields
- `Crisis__c` (Text) — Crisis
- `Flashpoint__c` (Checkbox) — Flashpoint
- `Interest__c` (Number) — Interest
- `Is_colonial__c` (Number) — Is colonial
- `Is_slave__c` (Checkbox) — Is slave
- `Popproject__c` (Lookup) — Popproject [Ref: Save_Game__c]
- `Provinces__c` (Lookup) — Provinces [Ref: Save_Game__c]
- `Savings__c` (Number) — Savings
- `State_buildings__c` (Lookup) — State buildings [Ref: Save_Game__c]

## Stockpile__c ('Stockpile') — 0 custom fields

## String__c ('String') — 1 custom fields
- `Value__c` (Text) — Value

## Substate__c ('Substate') — 4 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date

## Tag__c ('Tag') — 1 custom fields
- `Value__c` (Text) — Value

## TaxEff__c ('TaxEff') — 1 custom fields
- `Value__c` (Number) — Value

## TaxIncome__c ('TaxIncome') — 1 custom fields
- `Value__c` (Number) — Value

## Technology_Toggle__c ('Technology Toggle') — 2 custom fields
- `Technology__c` (Text) — Technology
- `Value__c` (Number) — Value

## Technology__c ('Technology') — 0 custom fields

## Threat__c ('Threat') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Trade_Good__c ('Trade Good') — 4 custom fields
- `Automate_trade__c` (Checkbox) — Automate trade
- `Buy__c` (Checkbox) — Buy
- `Good__c` (Text) — Good
- `Limit__c` (Number) — Limit

## Trade__c ('Trade') — 0 custom fields

## Unit_Cost__c ('Unit Cost') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## UpperHouse__c ('UpperHouse') — 0 custom fields

## Variable__c ('Variable') — 0 custom fields

## Vassal__c ('Vassal') — 4 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date

## WarGoal__c ('WarGoal') — 8 custom fields
- `Actor__c` (Text) — Actor
- `Casus_belli__c` (Text) — Casus belli
- `Change__c` (Number) — Change
- `Date__c` (Text) — Date
- `Is_fulfilled__c` (Checkbox) — Is fulfilled
- `Receiver__c` (Text) — Receiver
- `Score__c` (Number) — Score
- `State_province_id__c` (Number) — State province id

## WarWith__c ('WarWith') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## War_History_Entry__c ('War History Entry') — 6 custom fields
- `Add_attacker__c` (Text) — Add attacker
- `Add_defender__c` (Text) — Add defender
- `Battle__c` (Lookup) — Battle [Ref: Save_Game__c]
- `Date__c` (Text) — Date
- `Rem_attacker__c` (Text) — Rem attacker
- `Rem_defender__c` (Text) — Rem defender

## World_Market__c ('World Market') — 1 custom fields
- `Price_history_last_update__c` (Text) — Price history last update

**Track B Total:** 126 Custom Objects, 861 Custom Fields.


# Track B — Full Save-Game Model
This section details the expanded save-game entities and custom fields added in Track B to represent the full Clausewitz save structure.

## AccumulatedLosse__c ('AccumulatedLosse') — 1 custom fields
- `Value__c` (Number) — Value

## ActiveInvention__c ('ActiveInvention') — 1 custom fields
- `Value__c` (Number) — Value

## ActiveParty__c ('ActiveParty') — 0 custom fields

## ActiveWar__c ('ActiveWar') — 7 custom fields
- `Action__c` (Text) — Action
- `Defender__c` (Text) — Defender
- `History__c` (Lookup) — History [Ref: History__c]
- `Name__c` (Text) — Name
- `Original_attacker__c` (Text) — Original attacker
- `Original_defender__c` (Text) — Original defender
- `Original_wargoal__c` (Lookup) — Original wargoal [Ref: Original_wargoal__c]

## ActualSoldDomestic__c ('ActualSoldDomestic') — 0 custom fields

## AiHardStrategy__c ('AiHardStrategy') — 5 custom fields
- `Consolidate__c` (Checkbox) — Consolidate
- `Date__c` (Text) — Date
- `Initialized__c` (Checkbox) — Initialized
- `Personality__c` (Text) — Personality
- `Static__c` (Checkbox) — Static

## Ai__c ('Ai') — 14 custom fields
- `Antagonize__c` (Lookup) — Antagonize [Ref: Antagonize__c]
- `Befriend__c` (Lookup) — Befriend [Ref: Befriend__c]
- `Building_prov__c` (Lookup) — Building prov [Ref: Building_prov__c]
- `Consolidate__c` (Checkbox) — Consolidate
- `Date__c` (Text) — Date
- `Initialized__c` (Checkbox) — Initialized
- `Military_access__c` (Lookup) — Military access [Ref: Military_access__c]
- `Personality__c` (Text) — Personality
- `Protect__c` (Lookup) — Protect [Ref: Protect__c]
- `Rival__c` (Lookup) — Rival [Ref: Rival__c]
- `Static__c` (Checkbox) — Static
- `Status__c` (Number) — Status
- `Threat__c` (Lookup) — Threat [Ref: Threat__c]
- `War_with__c` (Lookup) — War with [Ref: War_with__c]

## Alliance__c ('Alliance') — 4 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date

## AnarchoLiberal__c ('AnarchoLiberal') — 1 custom fields
- `Enable__c` (Text) — Enable

## Antagonize__c ('Antagonize') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Army__c ('Army') — 11 custom fields
- `Base__c` (Number) — Base
- `Dig_in__c` (Number) — Dig in
- `Dig_in_last_date__c` (Text) — Dig in last date
- `Location__c` (Number) — Location
- `Movement_progress__c` (Number) — Movement progress
- `Name__c` (Text) — Name
- `Path__c` (Lookup) — Path [Ref: Path__c]
- `Previous__c` (Number) — Previous
- `Regiment__c` (Lookup) — Regiment [Ref: Regiment__c]
- `Supplies__c` (Number) — Supplies
- `Target__c` (Number) — Target

## Article__c ('Article') — 2 custom fields
- `News_scope__c` (Lookup) — News scope [Ref: News_scope__c]
- `Size__c` (Text) — Size

## Attacker__c ('Attacker') — 8 custom fields
- `Accumulated_losses__c` (Lookup) — Accumulated losses [Ref: Accumulated_losses__c]
- `Back__c` (Lookup) — Back [Ref: Back__c]
- `Country__c` (Text) — Country
- `Dice__c` (Number) — Dice
- `Front__c` (Lookup) — Front [Ref: Front__c]
- `Irregular__c` (Number) — Irregular
- `Leader__c` (Text) — Leader
- `Losses__c` (Number) — Losses

## Back__c ('Back') — 0 custom fields

## Battle__c ('Battle') — 5 custom fields
- `Attacker__c` (Lookup) — Attacker [Ref: Attacker__c]
- `Defender__c` (Lookup) — Defender [Ref: Defender__c]
- `Location__c` (Number) — Location
- `Name__c` (Text) — Name
- `Result__c` (Checkbox) — Result

## Befriend__c ('Befriend') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## BudgetBalance__c ('BudgetBalance') — 1 custom fields
- `Value__c` (Number) — Value

## BuildingProv__c ('BuildingProv') — 3 custom fields
- `Id__c` (Number) — Id
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## BuiltNew__c ('BuiltNew') — 5 custom fields
- `Date__c` (Text) — Date
- `Is_read__c` (Checkbox) — Is read
- `Seed__c` (Number) — Seed
- `Style__c` (Number) — Style
- `Title_image__c` (Text) — Title image

## BuyDomestic__c ('BuyDomestic') — 0 custom fields

## Canal__c ('Canal') — 1 custom fields
- `Value__c` (Number) — Value

## CasusBelli__c ('CasusBelli') — 5 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date
- `Type__c` (Text) — Type

## Colonize__c ('Colonize') — 1 custom fields
- `N_283__c` (Number) — N 283

## Colony__c ('Colony') — 4 custom fields
- `Date__c` (Text) — Date
- `Invest__c` (Number) — Invest
- `Points__c` (Number) — Points
- `Tag__c` (Text) — Tag

## Combat__c ('Combat') — 0 custom fields

## Communist__c ('Communist') — 0 custom fields

## ConquerProv__c ('ConquerProv') — 2 custom fields
- `Id__c` (Number) — Id
- `Value__c` (Number) — Value

## Construction__c ('Construction') — 5 custom fields
- `Building__c` (Number) — Building
- `Country__c` (Text) — Country
- `Date__c` (Text) — Date
- `Location__c` (Number) — Location
- `Start_date__c` (Text) — Start date

## Consumption_Cache__c ('Consumption Cache') — 0 custom fields

## Country_Country_Ref__c ('Country Country Ref') — 4 custom fields
- `Country_Save_State__c` (MasterDetail) — Country Save State [Ref: Country_Save_State__c]
- `Country__c` (Lookup) — Country [Ref: Country__c]
- `Relationship_Type__c` (Text) — Relationship Type
- `Target_Country_Tag__c` (Text) — Target Country Tag

## Country_Save_State__c ('Country Save State') — 123 custom fields
- `Active_inventions__c` (Lookup) — Active inventions [Ref: Active_inventions__c]
- `Actual_sold_domestic__c` (Lookup) — Actual sold domestic [Ref: Actual_sold_domestic__c]
- `Admin_reform__c` (Text) — Admin reform
- `Ai__c` (Lookup) — Ai [Ref: Ai__c]
- `Ai_hard_strategy__c` (Lookup) — Ai hard strategy [Ref: Ai_hard_strategy__c]
- `Army__c` (Lookup) — Army [Ref: Army__c]
- `Army_schools__c` (Text) — Army schools
- `Auto_assign_leaders__c` (Checkbox) — Auto assign leaders
- `Auto_create_leaders__c` (Checkbox) — Auto create leaders
- `Badboy__c` (Number) — Badboy
- `Ban_embassy__c` (Text) — Ban embassy
- `Ban_embassy_country__c` (Text) — Ban embassy country
- `Buy_domestic__c` (Lookup) — Buy domestic [Ref: Buy_domestic__c]
- `Campaign_counter__c` (Number) — Campaign counter
- `Capital__c` (Number) — Capital
- `Civilized__c` (Checkbox) — Civilized
- `Colonize__c` (Lookup) — Colonize [Ref: Colonize__c]
- `Creditor__c` (Lookup) — Creditor [Ref: Creditor__c]
- `Culture__c` (Lookup) — Culture [Ref: Culture__c]
- `Diplomatic_points__c` (Number) — Diplomatic points
- `Discredit__c` (Text) — Discredit
- `Discreditor__c` (Text) — Discreditor
- `Domain_region__c` (Text) — Domain region
- `Domestic_demand_pool__c` (Lookup) — Domestic demand pool [Ref: Domestic_demand_pool__c]
- `Domestic_supply_pool__c` (Lookup) — Domestic supply pool [Ref: Domestic_supply_pool__c]
- `Education_reform__c` (Text) — Education reform
- `Election__c` (Text) — Election
- `Expenses__c` (Lookup) — Expenses [Ref: Expenses__c]
- `Finance_reform__c` (Text) — Finance reform
- `Flags__c` (Lookup) — Flags [Ref: Flags__c]
- `Foreign_investment__c` (Lookup) — Foreign investment [Ref: Foreign_investment__c]
- `Foreign_naval_officers__c` (Text) — Foreign naval officers
- `Foreign_navies__c` (Text) — Foreign navies
- `Foreign_officers__c` (Text) — Foreign officers
- `Foreign_training__c` (Text) — Foreign training
- `Foreign_weapons__c` (Text) — Foreign weapons
- `Government__c` (Text) — Government
- `Government_flag__c` (Lookup) — Government flag [Ref: Government_flag__c]
- `Health_care__c` (Text) — Health care
- `Human__c` (Checkbox) — Human
- `Illegal_inventions__c` (Lookup) — Illegal inventions [Ref: Illegal_inventions__c]
- `Incomes__c` (Lookup) — Incomes [Ref: Incomes__c]
- `Industrial_construction__c` (Text) — Industrial construction
- `Influence__c` (Lookup) — Influence [Ref: Influence__c]
- `Influence_overflow__c` (Number) — Influence overflow
- `Influence_value__c` (Number) — Influence value
- `Interesting_countries__c` (Lookup) — Interesting countries [Ref: Interesting_countries__c]
- `Is_releasable_vassal__c` (Checkbox) — Is releasable vassal
- `Land_reform__c` (Text) — Land reform
- `Last_bankrupt__c` (Text) — Last bankrupt
- `Last_election__c` (Text) — Last election
- `Last_greatness_date__c` (Text) — Last greatness date
- `Last_lost_war__c` (Text) — Last lost war
- `Last_mission_cancel__c` (Text) — Last mission cancel
- `Last_reform__c` (Text) — Last reform
- `Last_send_diplomat__c` (Text) — Last send diplomat
- `Last_war__c` (Text) — Last war
- `Leader__c` (Lookup) — Leader [Ref: Leader__c]
- `Leadership__c` (Number) — Leadership
- `Level__c` (Number) — Level
- `Level_changed_date__c` (Text) — Level changed date
- `Max_bought__c` (Lookup) — Max bought [Ref: Max_bought__c]
- `Max_tariff__c` (Number) — Max tariff
- `Middle_tax__c` (Lookup) — Middle tax [Ref: Middle_tax__c]
- `Military_access__c` (Checkbox) — Military access
- `Military_constructions__c` (Text) — Military constructions
- `Mobilize__c` (Checkbox) — Mobilize
- `Modifier__c` (Lookup) — Modifier [Ref: Modifier__c]
- `Money__c` (Number) — Money
- `Movement__c` (Lookup) — Movement [Ref: Movement__c]
- `National_focus__c` (Lookup) — National focus [Ref: National_focus__c]
- `Nationalvalue__c` (Text) — Nationalvalue
- `Naval_schools__c` (Text) — Naval schools
- `Navy__c` (Lookup) — Navy [Ref: Navy__c]
- `Next_quarterly_pulse__c` (Text) — Next quarterly pulse
- `Next_yearly_pulse__c` (Text) — Next yearly pulse
- `Overseas_penalty__c` (Number) — Overseas penalty
- `Pensions__c` (Text) — Pensions
- `Plurality__c` (Number) — Plurality
- `Political_parties__c` (Text) — Political parties
- `Poor_tax__c` (Lookup) — Poor tax [Ref: Poor_tax__c]
- `Possible_inventions__c` (Lookup) — Possible inventions [Ref: Possible_inventions__c]
- `Pre_indust__c` (Text) — Pre indust
- `Press_rights__c` (Text) — Press rights
- `Prestige__c` (Number) — Prestige
- `Primary_culture__c` (Text) — Primary culture
- `Public_meetings__c` (Text) — Public meetings
- `Railroads__c` (Lookup) — Railroads [Ref: Railroads__c]
- `Religion__c` (Text) — Religion
- `Research__c` (Lookup) — Research [Ref: Research__c]
- `Research_points__c` (Number) — Research points
- `Revanchism__c` (Number) — Revanchism
- `Rich_tax__c` (Lookup) — Rich tax [Ref: Rich_tax__c]
- `Ruling_party__c` (Number) — Ruling party
- `Safety_regulations__c` (Text) — Safety regulations
- `Saved_country_supply__c` (Lookup) — Saved country supply [Ref: Saved_country_supply__c]
- `School_reforms__c` (Text) — School reforms
- `Schools__c` (Text) — Schools
- `Slavery__c` (Text) — Slavery
- `Sold_supply_pool__c` (Lookup) — Sold supply pool [Ref: Sold_supply_pool__c]
- `State__c` (Lookup) — State [Ref: State_Save_State__c]
- `Suppression__c` (Number) — Suppression
- `Tag__c` (Text) — Tag
- `Tariffs__c` (Number) — Tariffs
- `Tax_base__c` (Number) — Tax base
- `Technology__c` (Lookup) — Technology [Ref: Technology__c]
- `Trade__c` (Lookup) — Trade [Ref: Trade__c]
- `Trade_cap_land__c` (Number) — Trade cap land
- `Trade_cap_naval__c` (Number) — Trade cap naval
- `Trade_cap_projects__c` (Number) — Trade cap projects
- `Trade_unions__c` (Text) — Trade unions
- `Transport_improv__c` (Text) — Transport improv
- `Truce_until__c` (Text) — Truce until
- `Unemployment_subsidies__c` (Text) — Unemployment subsidies
- `Upper_house__c` (Lookup) — Upper house [Ref: Upper_house__c]
- `Upper_house_composition__c` (Text) — Upper house composition
- `Value__c` (Number) — Value
- `Variables__c` (Lookup) — Variables [Ref: Variables__c]
- `Vote_franschise__c` (Text) — Vote franschise
- `Voting_system__c` (Text) — Voting system
- `Wage_reform__c` (Text) — Wage reform
- `War_exhaustion__c` (Number) — War exhaustion
- `Work_hours__c` (Text) — Work hours

## Creditor__c ('Creditor') — 4 custom fields
- `Country__c` (Text) — Country
- `Debt__c` (Number) — Debt
- `Interest__c` (Number) — Interest
- `Was_paid__c` (Checkbox) — Was paid

## CrisisManager__c ('CrisisManager') — 1 custom fields
- `Date__c` (Text) — Date

## Culture__c ('Culture') — 1 custom fields
- `Value__c` (Text) — Value

## Date__c ('Date') — 1 custom fields
- `Value__c` (Text) — Value

## Defender__c ('Defender') — 9 custom fields
- `Accumulated_losses__c` (Lookup) — Accumulated losses [Ref: Accumulated_losses__c]
- `Back__c` (Lookup) — Back [Ref: Back__c]
- `Country__c` (Text) — Country
- `Dice__c` (Number) — Dice
- `Front__c` (Lookup) — Front [Ref: Front__c]
- `Infantry__c` (Number) — Infantry
- `Irregular__c` (Number) — Irregular
- `Leader__c` (Text) — Leader
- `Losses__c` (Number) — Losses

## Diplomacy__c ('Diplomacy') — 4 custom fields
- `Alliance__c` (Lookup) — Alliance [Ref: Alliance__c]
- `Casus_belli__c` (Lookup) — Casus belli [Ref: Casus_belli__c]
- `Substate__c` (Lookup) — Substate [Ref: Substate__c]
- `Vassal__c` (Lookup) — Vassal [Ref: Vassal__c]

## DomesticDemandPool__c ('DomesticDemandPool') — 0 custom fields

## DomesticSupplyPool__c ('DomesticSupplyPool') — 0 custom fields

## Employee__c ('Employee') — 1 custom fields
- `Count__c` (Number) — Count

## Employment__c ('Employment') — 1 custom fields
- `State_province_id__c` (Number) — State province id

## Expense__c ('Expense') — 1 custom fields
- `Value__c` (Number) — Value

## Fascist__c ('Fascist') — 0 custom fields

## Fired_Event__c ('Fired Event') — 2 custom fields
- `Id__c` (Number) — Id
- `Type__c` (Number) — Type

## Fired_Events__c ('Fired Events') — 0 custom fields

## Flag__c ('Flag') — 59 custom fields
- `Apache_wars__c` (Checkbox) — Apache wars
- `Bixby_letter_sent__c` (Checkbox) — Bixby letter sent
- `Bonnie_blue_flag__c` (Checkbox) — Bonnie blue flag
- `Botanical_expedition_threatened__c` (Checkbox) — Botanical expedition threatened
- `Cavour_has_done_his__c` (Checkbox) — Cavour has done his
- `Clay_and_douglas_draft_enacted__c` (Checkbox) — Clay and douglas draft enacted
- `Code_of_laws__c` (Checkbox) — Code of laws
- `Corn_laws_repealed_flag__c` (Checkbox) — Corn laws repealed flag
- `Corwin_amendment_enacted__c` (Checkbox) — Corwin amendment enacted
- `Crisis_on_the_rhine__c` (Checkbox) — Crisis on the rhine
- `Dar_al_funun_built__c` (Checkbox) — Dar al funun built
- `Dred_scott_decision__c` (Checkbox) — Dred scott decision
- `Emigrant_aid_company__c` (Checkbox) — Emigrant aid company
- `Facundo__c` (Checkbox) — Facundo
- `French_foreign_legion_supported__c` (Checkbox) — French foreign legion supported
- `Fugitive_slave_act_enacted__c` (Checkbox) — Fugitive slave act enacted
- `Had_liberal_revolution__c` (Checkbox) — Had liberal revolution
- `Had_orange_river_convention__c` (Checkbox) — Had orange river convention
- `Hasmanifestdestiny__c` (Checkbox) — Hasmanifestdestiny
- `House_gag_rule_enacted__c` (Checkbox) — House gag rule enacted
- `HungarianLanguage__c` (Checkbox) — HungarianLanguage
- `IlyaGarashinin__c` (Checkbox) — IlyaGarashinin
- `Is_negusa_nagast__c` (Checkbox) — Is negusa nagast
- `Italia_ulterior__c` (Checkbox) — Italia ulterior
- `John_browns_raid__c` (Checkbox) — John browns raid
- `Kansas_nebraska_act_acting__c` (Checkbox) — Kansas nebraska act acting
- `Kanun_i_esasi_here__c` (Checkbox) — Kanun i esasi here
- `Kellys_irish_brigade__c` (Checkbox) — Kellys irish brigade
- `Lambert_has_been_chartered__c` (Checkbox) — Lambert has been chartered
- `Liberal_revolution_in_progress__c` (Checkbox) — Liberal revolution in progress
- `LouisNapoleonExtradited__c` (Checkbox) — LouisNapoleonExtradited
- `LouisPioFirst__c` (Checkbox) — LouisPioFirst
- `Mendizabal_confiscated__c` (Checkbox) — Mendizabal confiscated
- `Merina_monarchy_is_over__c` (Checkbox) — Merina monarchy is over
- `MozartFest1838__c` (Checkbox) — MozartFest1838
- `Nashville_convention_held__c` (Checkbox) — Nashville convention held
- `NoGoToNile__c` (Checkbox) — NoGoToNile
- `Participates_in_botanical_expedition__c` (Checkbox) — Participates in botanical expedition
- `Presbyteries_introduced__c` (Checkbox) — Presbyteries introduced
- `Princes_recieve_foreign_education__c` (Checkbox) — Princes recieve foreign education
- `SCAStudent__c` (Checkbox) — SCAStudent
- `Sepoy_rebellion__c` (Checkbox) — Sepoy rebellion
- `Serfdom_not_abolished__c` (Checkbox) — Serfdom not abolished
- `Signed_treay_of_london__c` (Checkbox) — Signed treay of london
- `State_controlled_rite__c` (Checkbox) — State controlled rite
- `That_book_written__c` (Checkbox) — That book written
- `The_slavery_debate__c` (Checkbox) — The slavery debate
- `Usstatehood_we_have_applied__c` (Checkbox) — Usstatehood we have applied
- `Value__c` (Text) — Value
- `Victoria_regina__c` (Checkbox) — Victoria regina
- `Von_moltke__c` (Checkbox) — Von moltke
- `Voule_ton_ellinon__c` (Checkbox) — Voule ton ellinon
- `Walhalla__c` (Checkbox) — Walhalla
- `Watching_the_rhine__c` (Checkbox) — Watching the rhine
- `Webster_ashburton_signed__c` (Checkbox) — Webster ashburton signed
- `YesGoToNileThird__c` (Checkbox) — YesGoToNileThird
- `YesGoToNile__c` (Checkbox) — YesGoToNile
- `You_did_try__c` (Checkbox) — You did try
- `Zul_cb_taken__c` (Checkbox) — Zul cb taken

## ForeignInvestment__c ('ForeignInvestment') — 1 custom fields
- `Value__c` (Number) — Value

## Front__c ('Front') — 0 custom fields

## Game_Flag__c ('Game Flag') — 2 custom fields
- `Flag_Name__c` (Text) — Flag Name
- `Flag_Value__c` (Checkbox) — Flag Value

## Gameplay_Settings__c ('Gameplay Settings') — 1 custom fields
- `Setgameplayoptions__c` (Lookup) — Setgameplayoptions [Ref: Setgameplayoptions__c]

## Goods_Vector_Line__c ('Goods Vector Line') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## GovernmentFlag__c ('GovernmentFlag') — 1 custom fields
- `Hms_government__c` (Text) — Hms government

## GreatNation__c ('GreatNation') — 1 custom fields
- `Value__c` (Number) — Value

## History__c ('History') — 11 custom fields
- `N_1870_11_12__c` (Lookup) — N 1870 11 12 [Ref: N_1870_11_12__c]
- `N_1870_4_29__c` (Lookup) — N 1870 4 29 [Ref: N_1870_4_29__c]
- `N_1870_6_28__c` (Lookup) — N 1870 6 28 [Ref: N_1870_6_28__c]
- `N_1871_11_3__c` (Lookup) — N 1871 11 3 [Ref: N_1871_11_3__c]
- `N_1871_5_24__c` (Lookup) — N 1871 5 24 [Ref: N_1871_5_24__c]
- `N_1871_6_1__c` (Lookup) — N 1871 6 1 [Ref: N_1871_6_1__c]
- `N_1871_8_25__c` (Lookup) — N 1871 8 25 [Ref: N_1871_8_25__c]
- `N_1871_9_8__c` (Lookup) — N 1871 9 8 [Ref: N_1871_9_8__c]
- `N_1872_2_17__c` (Lookup) — N 1872 2 17 [Ref: N_1872_2_17__c]
- `N_1872_8_20__c` (Lookup) — N 1872 8 20 [Ref: N_1872_8_20__c]
- `Name__c` (Text) — Name

## IllegalInvention__c ('IllegalInvention') — 1 custom fields
- `Value__c` (Number) — Value

## Income__c ('Income') — 1 custom fields
- `Value__c` (Number) — Value

## Influence__c ('Influence') — 51 custom fields
- `AFG__c` (Text) — AFG
- `ALD__c` (Text) — ALD
- `ANH__c` (Text) — ANH
- `AST__c` (Text) — AST
- `BAD__c` (Text) — BAD
- `BAL__c` (Text) — BAL
- `BEL__c` (Text) — BEL
- `BHU__c` (Text) — BHU
- `BRE__c` (Text) — BRE
- `BUK__c` (Text) — BUK
- `BUR__c` (Text) — BUR
- `CHI__c` (Text) — CHI
- `CLM__c` (Text) — CLM
- `CSA__c` (Text) — CSA
- `D02__c` (Text) — D02
- `D03__c` (Text) — D03
- `DAI__c` (Text) — DAI
- `HDJ__c` (Text) — HDJ
- `HEK__c` (Text) — HEK
- `HND__c` (Text) — HND
- `HOL__c` (Text) — HOL
- `ITA__c` (Text) — ITA
- `KAL__c` (Text) — KAL
- `KHI__c` (Text) — KHI
- `KOR__c` (Text) — KOR
- `KRA__c` (Text) — KRA
- `LIP__c` (Text) — LIP
- `LUA__c` (Text) — LUA
- `LUX__c` (Text) — LUX
- `MAK__c` (Text) — MAK
- `MCK__c` (Text) — MCK
- `MEX__c` (Text) — MEX
- `MGL__c` (Text) — MGL
- `MOL__c` (Text) — MOL
- `MON__c` (Text) — MON
- `NET__c` (Text) — NET
- `OMA__c` (Text) — OMA
- `PAN__c` (Text) — PAN
- `PER__c` (Text) — PER
- `ROM__c` (Text) — ROM
- `SIK__c` (Text) — SIK
- `SIN__c` (Text) — SIN
- `SOK__c` (Text) — SOK
- `SWE__c` (Text) — SWE
- `SWI__c` (Text) — SWI
- `TUN__c` (Text) — TUN
- `UCA__c` (Text) — UCA
- `WAL__c` (Text) — WAL
- `WUR__c` (Text) — WUR
- `XBI__c` (Text) — XBI
- `XIN__c` (Text) — XIN

## InputGood__c ('InputGood') — 1 custom fields
- `Money__c` (Number) — Money

## InterestingCountrie__c ('InterestingCountrie') — 1 custom fields
- `Value__c` (Number) — Value

## Invention__c ('Invention') — 1 custom fields
- `Value__c` (Number) — Value

## Leader__c ('Leader') — 8 custom fields
- `Background__c` (Text) — Background
- `Country__c` (Text) — Country
- `Date__c` (Text) — Date
- `Name__c` (Text) — Name
- `Personality__c` (Text) — Personality
- `Picture__c` (Text) — Picture
- `Prestige__c` (Number) — Prestige
- `Type__c` (Text) — Type

## Market_Line__c ('Market Line') — 3 custom fields
- `Key__c` (Text) — Key
- `Kind__c` (Text) — Kind
- `Value__c` (Number) — Value

## MaxBought__c ('MaxBought') — 0 custom fields

## MiddleTax__c ('MiddleTax') — 8 custom fields
- `Current__c` (Number) — Current
- `Max_tax__c` (Number) — Max tax
- `Min_tax__c` (Number) — Min tax
- `RangeLimitMax__c` (Number) — RangeLimitMax
- `RangeLimitMin__c` (Number) — RangeLimitMin
- `Tax_eff__c` (Lookup) — Tax eff [Ref: Tax_eff__c]
- `Tax_income__c` (Lookup) — Tax income [Ref: Tax_income__c]
- `Total__c` (Number) — Total

## MilitaryAcces__c ('MilitaryAcces') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Modifier__c ('Modifier') — 2 custom fields
- `Date__c` (Text) — Date
- `Modifier__c` (Text) — Modifier

## Movement__c ('Movement') — 5 custom fields
- `Cache__c` (Number) — Cache
- `Issue__c` (Text) — Issue
- `Radicalism__c` (Number) — Radicalism
- `Support__c` (Number) — Support
- `Tag__c` (Text) — Tag

## NationalFocu__c ('NationalFocu') — 142 custom fields
- `N_100__c` (Text) — N 100
- `N_101__c` (Text) — N 101
- `N_103__c` (Text) — N 103
- `N_105__c` (Text) — N 105
- `N_10__c` (Text) — N 10
- `N_110__c` (Text) — N 110
- `N_113__c` (Text) — N 113
- `N_114__c` (Text) — N 114
- `N_117__c` (Text) — N 117
- `N_121__c` (Text) — N 121
- `N_129__c` (Text) — N 129
- `N_132__c` (Text) — N 132
- `N_133__c` (Text) — N 133
- `N_135__c` (Text) — N 135
- `N_136__c` (Text) — N 136
- `N_13__c` (Text) — N 13
- `N_147__c` (Text) — N 147
- `N_148__c` (Text) — N 148
- `N_158__c` (Text) — N 158
- `N_163__c` (Text) — N 163
- `N_166__c` (Text) — N 166
- `N_175__c` (Text) — N 175
- `N_183__c` (Text) — N 183
- `N_184__c` (Text) — N 184
- `N_190__c` (Text) — N 190
- `N_194__c` (Text) — N 194
- `N_202__c` (Text) — N 202
- `N_207__c` (Text) — N 207
- `N_208__c` (Text) — N 208
- `N_209__c` (Text) — N 209
- `N_212__c` (Text) — N 212
- `N_213__c` (Text) — N 213
- `N_214__c` (Text) — N 214
- `N_230__c` (Text) — N 230
- `N_233__c` (Text) — N 233
- `N_235__c` (Text) — N 235
- `N_236__c` (Text) — N 236
- `N_240__c` (Text) — N 240
- `N_241__c` (Text) — N 241
- `N_242__c` (Text) — N 242
- `N_246__c` (Text) — N 246
- `N_249__c` (Text) — N 249
- `N_250__c` (Text) — N 250
- `N_253__c` (Text) — N 253
- `N_254__c` (Text) — N 254
- `N_255__c` (Text) — N 255
- `N_256__c` (Text) — N 256
- `N_257__c` (Text) — N 257
- `N_258__c` (Text) — N 258
- `N_261__c` (Text) — N 261
- `N_262__c` (Text) — N 262
- `N_263__c` (Text) — N 263
- `N_267__c` (Text) — N 267
- `N_268__c` (Text) — N 268
- `N_269__c` (Text) — N 269
- `N_26__c` (Text) — N 26
- `N_274__c` (Text) — N 274
- `N_276__c` (Text) — N 276
- `N_281__c` (Text) — N 281
- `N_282__c` (Text) — N 282
- `N_283__c` (Text) — N 283
- `N_285__c` (Text) — N 285
- `N_290__c` (Text) — N 290
- `N_349__c` (Text) — N 349
- `N_370__c` (Text) — N 370
- `N_372__c` (Text) — N 372
- `N_373__c` (Text) — N 373
- `N_377__c` (Text) — N 377
- `N_380__c` (Text) — N 380
- `N_382__c` (Text) — N 382
- `N_394__c` (Text) — N 394
- `N_397__c` (Text) — N 397
- `N_3__c` (Text) — N 3
- `N_402__c` (Text) — N 402
- `N_404__c` (Text) — N 404
- `N_406__c` (Text) — N 406
- `N_408__c` (Text) — N 408
- `N_409__c` (Text) — N 409
- `N_410__c` (Text) — N 410
- `N_413__c` (Text) — N 413
- `N_414__c` (Text) — N 414
- `N_415__c` (Text) — N 415
- `N_416__c` (Text) — N 416
- `N_418__c` (Text) — N 418
- `N_41__c` (Text) — N 41
- `N_429__c` (Text) — N 429
- `N_445__c` (Text) — N 445
- `N_446__c` (Text) — N 446
- `N_453__c` (Text) — N 453
- `N_455__c` (Text) — N 455
- `N_458__c` (Text) — N 458
- `N_470__c` (Text) — N 470
- `N_478__c` (Text) — N 478
- `N_481__c` (Text) — N 481
- `N_484__c` (Text) — N 484
- `N_4__c` (Text) — N 4
- `N_501__c` (Text) — N 501
- `N_503__c` (Text) — N 503
- `N_505__c` (Text) — N 505
- `N_507__c` (Text) — N 507
- `N_509__c` (Text) — N 509
- `N_50__c` (Text) — N 50
- `N_517__c` (Text) — N 517
- `N_51__c` (Text) — N 51
- `N_522__c` (Text) — N 522
- `N_523__c` (Text) — N 523
- `N_524__c` (Text) — N 524
- `N_525__c` (Text) — N 525
- `N_526__c` (Text) — N 526
- `N_527__c` (Text) — N 527
- `N_529__c` (Text) — N 529
- `N_530__c` (Text) — N 530
- `N_532__c` (Text) — N 532
- `N_533__c` (Text) — N 533
- `N_534__c` (Text) — N 534
- `N_535__c` (Text) — N 535
- `N_536__c` (Text) — N 536
- `N_537__c` (Text) — N 537
- `N_538__c` (Text) — N 538
- `N_539__c` (Text) — N 539
- `N_53__c` (Text) — N 53
- `N_540__c` (Text) — N 540
- `N_544__c` (Text) — N 544
- `N_55__c` (Text) — N 55
- `N_56__c` (Text) — N 56
- `N_57__c` (Text) — N 57
- `N_58__c` (Text) — N 58
- `N_60__c` (Text) — N 60
- `N_61__c` (Text) — N 61
- `N_67__c` (Text) — N 67
- `N_68__c` (Text) — N 68
- `N_69__c` (Text) — N 69
- `N_6__c` (Text) — N 6
- `N_72__c` (Text) — N 72
- `N_76__c` (Text) — N 76
- `N_7__c` (Text) — N 7
- `N_80__c` (Text) — N 80
- `N_86__c` (Text) — N 86
- `N_89__c` (Text) — N 89
- `N_90__c` (Text) — N 90
- `N_95__c` (Text) — N 95
- `N_99__c` (Text) — N 99

## Navy__c ('Navy') — 10 custom fields
- `Army__c` (Lookup) — Army [Ref: Army__c]
- `At_sea__c` (Number) — At sea
- `Dig_in_last_date__c` (Text) — Dig in last date
- `Location__c` (Number) — Location
- `Movement_progress__c` (Number) — Movement progress
- `Name__c` (Text) — Name
- `Path__c` (Lookup) — Path [Ref: Path__c]
- `Previous__c` (Number) — Previous
- `Ship__c` (Lookup) — Ship [Ref: Ship__c]
- `Supplies__c` (Number) — Supplies

## NewsCollector__c ('NewsCollector') — 3 custom fields
- `Date__c` (Text) — Date
- `Flags__c` (Lookup) — Flags [Ref: Flags__c]
- `Tension__c` (Number) — Tension

## NewsScope__c ('NewsScope') — 7 custom fields
- `Dates__c` (Lookup) — Dates [Ref: Dates__c]
- `Freshness__c` (Number) — Freshness
- `Name__c` (Text) — Name
- `Strings__c` (Lookup) — Strings [Ref: Strings__c]
- `Tags__c` (Lookup) — Tags [Ref: Tags__c]
- `Type__c` (Text) — Type
- `Values__c` (Lookup) — Values [Ref: Values__c]

## News_Scope_Value__c ('News Scope Value') — 1 custom fields
- `Value__c` (Number) — Value

## OriginalWargoal__c ('OriginalWargoal') — 8 custom fields
- `Actor__c` (Text) — Actor
- `Casus_belli__c` (Text) — Casus belli
- `Change__c` (Number) — Change
- `Date__c` (Text) — Date
- `Is_fulfilled__c` (Checkbox) — Is fulfilled
- `Receiver__c` (Text) — Receiver
- `Score__c` (Number) — Score
- `State_province_id__c` (Number) — State province id

## Outliner__c ('Outliner') — 1 custom fields
- `Value__c` (Number) — Value

## Overseas_Penalty__c ('Overseas Penalty') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## Path__c ('Path') — 1 custom fields
- `Value__c` (Number) — Value

## PlayerMonthlyPopGrowth__c ('PlayerMonthlyPopGrowth') — 1 custom fields
- `Value__c` (Number) — Value

## PoorTax__c ('PoorTax') — 8 custom fields
- `Current__c` (Number) — Current
- `Max_tax__c` (Number) — Max tax
- `Min_tax__c` (Number) — Min tax
- `RangeLimitMax__c` (Number) — RangeLimitMax
- `RangeLimitMin__c` (Number) — RangeLimitMin
- `Tax_eff__c` (Lookup) — Tax eff [Ref: Tax_eff__c]
- `Tax_income__c` (Lookup) — Tax income [Ref: Tax_income__c]
- `Total__c` (Number) — Total

## Pop_Need__c ('Pop Need') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## Pop_Stockpile__c ('Pop Stockpile') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## Pop__c ('Pop') — 33 custom fields
- `Bank__c` (Number) — Bank
- `Con__c` (Number) — Con
- `Con_factor__c` (Number) — Con factor
- `Converted__c` (Number) — Converted
- `Current_producing__c` (Number) — Current producing
- `Demoted__c` (Number) — Demoted
- `Id__c` (Number) — Id
- `Ideology_Key__c` (Text) — Ideology Key
- `Ideology_Value__c` (Number) — Ideology Value
- `Ideology__c` (Lookup) — Ideology [Ref: Ideology__c]
- `Issue_Key__c` (Text) — Issue Key
- `Issue_Value__c` (Number) — Issue Value
- `Issues__c` (Lookup) — Issues [Ref: Issues__c]
- `Last_spending__c` (Number) — Last spending
- `Leftover__c` (Number) — Leftover
- `Literacy__c` (Number) — Literacy
- `Luxury_needs__c` (Number) — Luxury needs
- `Mil__c` (Number) — Mil
- `Money__c` (Number) — Money
- `Native_american_minor__c` (Text) — Native american minor
- `Needs_cost__c` (Number) — Needs cost
- `Percent_afforded__c` (Number) — Percent afforded
- `Percent_sold_domestic__c` (Number) — Percent sold domestic
- `Percent_sold_export__c` (Number) — Percent sold export
- `Pop_Type__c` (Text) — Pop Type
- `Production_income__c` (Number) — Production income
- `Production_type__c` (Text) — Production type
- `Promoted__c` (Number) — Promoted
- `Random__c` (Number) — Random
- `Russian__c` (Text) — Russian
- `Size__c` (Number) — Size
- `Throttle__c` (Number) — Throttle
- `Type__c` (Number) — Type

## Popproject__c ('Popproject') — 8 custom fields
- `Building__c` (Number) — Building
- `Index__c` (Number) — Index
- `Input_goods__c` (Lookup) — Input goods [Ref: Input_goods__c]
- `Money2__c` (Checkbox) — Money2
- `Money__c` (Number) — Money
- `Pop__c` (Number) — Pop
- `Province__c` (Number) — Province
- `Type__c` (Number) — Type

## PossibleInvention__c ('PossibleInvention') — 1 custom fields
- `Value__c` (Number) — Value

## PreviousWar__c ('PreviousWar') — 6 custom fields
- `Action__c` (Text) — Action
- `History__c` (Lookup) — History [Ref: History__c]
- `Name__c` (Text) — Name
- `Original_attacker__c` (Text) — Original attacker
- `Original_defender__c` (Text) — Original defender
- `Original_wargoal__c` (Lookup) — Original wargoal [Ref: Original_wargoal__c]

## Price_Snapshot__c ('Price Snapshot') — 48 custom fields
- `Aeroplanes__c` (Number) — Aeroplanes
- `Ammunition__c` (Number) — Ammunition
- `Artillery__c` (Number) — Artillery
- `Automobiles__c` (Number) — Automobiles
- `Barrels__c` (Number) — Barrels
- `Canned_food__c` (Number) — Canned food
- `Cattle__c` (Number) — Cattle
- `Cement__c` (Number) — Cement
- `Clipper_convoy__c` (Number) — Clipper convoy
- `Coal__c` (Number) — Coal
- `Coffee__c` (Number) — Coffee
- `Cotton__c` (Number) — Cotton
- `Dye__c` (Number) — Dye
- `Electric_gear__c` (Number) — Electric gear
- `Explosives__c` (Number) — Explosives
- `Fabric__c` (Number) — Fabric
- `Fertilizer__c` (Number) — Fertilizer
- `Fish__c` (Number) — Fish
- `Fruit__c` (Number) — Fruit
- `Fuel__c` (Number) — Fuel
- `Furniture__c` (Number) — Furniture
- `Glass__c` (Number) — Glass
- `Grain__c` (Number) — Grain
- `Iron__c` (Number) — Iron
- `Liquor__c` (Number) — Liquor
- `Lumber__c` (Number) — Lumber
- `Luxury_clothes__c` (Number) — Luxury clothes
- `Luxury_furniture__c` (Number) — Luxury furniture
- `Machine_parts__c` (Number) — Machine parts
- `Oil__c` (Number) — Oil
- `Opium__c` (Number) — Opium
- `Paper__c` (Number) — Paper
- `Precious_metal__c` (Number) — Precious metal
- `Radio__c` (Number) — Radio
- `Regular_clothes__c` (Number) — Regular clothes
- `Rubber__c` (Number) — Rubber
- `Silk__c` (Number) — Silk
- `Small_arms__c` (Number) — Small arms
- `Steamer_convoy__c` (Number) — Steamer convoy
- `Steel__c` (Number) — Steel
- `Sulphur__c` (Number) — Sulphur
- `Tea__c` (Number) — Tea
- `Telephones__c` (Number) — Telephones
- `Timber__c` (Number) — Timber
- `Tobacco__c` (Number) — Tobacco
- `Tropical_wood__c` (Number) — Tropical wood
- `Wine__c` (Number) — Wine
- `Wool__c` (Number) — Wool

## ProfitHistoryEntry__c ('ProfitHistoryEntry') — 1 custom fields
- `Value__c` (Number) — Value

## Protect__c ('Protect') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Province_Save_State__c ('Province Save State') — 13 custom fields
- `Building_construction__c` (Lookup) — Building construction [Ref: Building_construction__c]
- `Colonial__c` (Number) — Colonial
- `Controller__c` (Text) — Controller
- `Core__c` (Text) — Core
- `Garrison__c` (Number) — Garrison
- `Last_controller_change__c` (Text) — Last controller change
- `Last_imigration__c` (Text) — Last imigration
- `Life_rating__c` (Number) — Life rating
- `Name__c` (Text) — Name
- `Nationalism__c` (Number) — Nationalism
- `Owner__c` (Text) — Owner
- `Rgo__c` (Lookup) — Rgo [Ref: Rgo__c]
- `Value__c` (Number) — Value

## RGO_Employment__c ('RGO Employment') — 1 custom fields
- `Province_id__c` (Number) — Province id

## RGO__c ('RGO') — 3 custom fields
- `Employment__c` (Lookup) — Employment [Ref: Employment__c]
- `Goods_type__c` (Text) — Goods type
- `Last_income__c` (Number) — Last income

## Railroad__c ('Railroad') — 1 custom fields
- `Path__c` (Lookup) — Path [Ref: Path__c]

## RebelFaction__c ('RebelFaction') — 10 custom fields
- `Country__c` (Text) — Country
- `Culture__c` (Text) — Culture
- `Government__c` (Text) — Government
- `Independence__c` (Text) — Independence
- `Name__c` (Text) — Name
- `Next_unit__c` (Number) — Next unit
- `Organization__c` (Number) — Organization
- `Province__c` (Number) — Province
- `Religion__c` (Text) — Religion
- `Type__c` (Text) — Type

## Regiment__c ('Regiment') — 6 custom fields
- `Count__c` (Number) — Count
- `Experience__c` (Number) — Experience
- `Name__c` (Text) — Name
- `Organisation__c` (Number) — Organisation
- `Strength__c` (Number) — Strength
- `Type__c` (Text) — Type

## Region__c ('Region') — 3 custom fields
- `Index__c` (Number) — Index
- `Phase__c` (Number) — Phase
- `Temperature__c` (Number) — Temperature

## Research__c ('Research') — 5 custom fields
- `Active__c` (Checkbox) — Active
- `Cost__c` (Number) — Cost
- `Last_spending__c` (Number) — Last spending
- `Max_producing__c` (Number) — Max producing
- `Technology__c` (Text) — Technology

## RichTax__c ('RichTax') — 8 custom fields
- `Current__c` (Number) — Current
- `Max_tax__c` (Number) — Max tax
- `Min_tax__c` (Number) — Min tax
- `RangeLimitMax__c` (Number) — RangeLimitMax
- `RangeLimitMin__c` (Number) — RangeLimitMin
- `Tax_eff__c` (Lookup) — Tax eff [Ref: Tax_eff__c]
- `Tax_income__c` (Lookup) — Tax income [Ref: Tax_income__c]
- `Total__c` (Number) — Total

## Rival__c ('Rival') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Save_Game_Country_Ref__c ('Save Game Country Ref') — 4 custom fields
- `Country__c` (Lookup) — Country [Ref: Country__c]
- `Reference_Key__c` (Text) — Reference Key
- `Reference_Kind__c` (Text) — Reference Kind
- `Save_Game__c` (MasterDetail) — Save Game [Ref: Save_Game__c]

## Save_Game__c ('Save Game') — 30 custom fields
- `Anarcho_liberal__c` (Lookup) — Anarcho liberal [Ref: Anarcho_liberal__c]
- `Automate_sliders__c` (Number) — Automate sliders
- `Automate_trade__c` (Checkbox) — Automate trade
- `Budget_balance__c` (Lookup) — Budget balance [Ref: Budget_balance__c]
- `Canals__c` (Lookup) — Canals [Ref: Canals__c]
- `Combat__c` (Lookup) — Combat [Ref: Combat__c]
- `Communist__c` (Lookup) — Communist [Ref: Communist__c]
- `Crisis_manager__c` (Lookup) — Crisis manager [Ref: Crisis_manager__c]
- `Date__c` (Text) — Date
- `Diplomacy__c` (Lookup) — Diplomacy [Ref: Diplomacy__c]
- `Fascist__c` (Lookup) — Fascist [Ref: Fascist__c]
- `Fired_events__c` (Lookup) — Fired events [Ref: Fired_events__c]
- `Gameplaysettings__c` (Lookup) — Gameplaysettings [Ref: Gameplaysettings__c]
- `Government__c` (Number) — Government
- `Great_nations__c` (Lookup) — Great nations [Ref: Great_nations__c]
- `Great_wars_enabled__c` (Checkbox) — Great wars enabled
- `Invention__c` (Lookup) — Invention [Ref: Invention__c]
- `News_collector__c` (Lookup) — News collector [Ref: News_collector__c]
- `Outliner__c` (Lookup) — Outliner [Ref: Outliner__c]
- `Player__c` (Text) — Player
- `Player_monthly_pop_growth__c` (Lookup) — Player monthly pop growth [Ref: Player_monthly_pop_growth__c]
- `Player_monthly_pop_growth_date__c` (Text) — Player monthly pop growth date
- `Player_monthly_pop_growth_tag__c` (Text) — Player monthly pop growth tag
- `Rebel__c` (Number) — Rebel
- `Socialist__c` (Lookup) — Socialist [Ref: Socialist__c]
- `Start_date__c` (Text) — Start date
- `Start_pop_index__c` (Number) — Start pop index
- `State__c` (Number) — State
- `Unit__c` (Number) — Unit
- `Worldmarket__c` (Lookup) — Worldmarket [Ref: Worldmarket__c]

## SavedCountrySupply__c ('SavedCountrySupply') — 0 custom fields

## Setgameplayoption__c ('Setgameplayoption') — 1 custom fields
- `Value__c` (Number) — Value

## Ship__c ('Ship') — 6 custom fields
- `Count__c` (Number) — Count
- `Experience__c` (Number) — Experience
- `Name__c` (Text) — Name
- `Organisation__c` (Number) — Organisation
- `Strength__c` (Number) — Strength
- `Type__c` (Text) — Type

## SiegeCombat__c ('SiegeCombat') — 6 custom fields
- `Attacker__c` (Lookup) — Attacker [Ref: Attacker__c]
- `Day__c` (Number) — Day
- `Defender__c` (Lookup) — Defender [Ref: Defender__c]
- `Duration__c` (Number) — Duration
- `Location__c` (Number) — Location
- `Total__c` (Number) — Total

## Socialist__c ('Socialist') — 1 custom fields
- `Enable__c` (Text) — Enable

## SoldSupplyPool__c ('SoldSupplyPool') — 0 custom fields

## StateBuilding__c ('StateBuilding') — 22 custom fields
- `Building__c` (Text) — Building
- `Construction_time_left__c` (Number) — Construction time left
- `Days_without_input__c` (Number) — Days without input
- `Employment__c` (Lookup) — Employment [Ref: Employment__c]
- `Injected_days__c` (Number) — Injected days
- `Injected_money__c` (Number) — Injected money
- `Input_goods__c` (Lookup) — Input goods [Ref: Input_goods__c]
- `Last_income__c` (Number) — Last income
- `Last_investment__c` (Number) — Last investment
- `Last_spending__c` (Number) — Last spending
- `Leftover__c` (Number) — Leftover
- `Level__c` (Number) — Level
- `Money__c` (Number) — Money
- `Pops_paychecks__c` (Number) — Pops paychecks
- `Priority__c` (Number) — Priority
- `Produces__c` (Number) — Produces
- `Profit_history_current__c` (Number) — Profit history current
- `Profit_history_days__c` (Number) — Profit history days
- `Profit_history_entry__c` (Lookup) — Profit history entry [Ref: Profit_history_entry__c]
- `Stockpile__c` (Lookup) — Stockpile [Ref: Stockpile__c]
- `Subsidised__c` (Checkbox) — Subsidised
- `Unprofitable_days__c` (Number) — Unprofitable days

## State_Save_State__c ('State Save State') — 9 custom fields
- `Crisis__c` (Text) — Crisis
- `Flashpoint__c` (Checkbox) — Flashpoint
- `Interest__c` (Number) — Interest
- `Is_colonial__c` (Number) — Is colonial
- `Is_slave__c` (Checkbox) — Is slave
- `Popproject__c` (Lookup) — Popproject [Ref: Popproject__c]
- `Provinces__c` (Lookup) — Provinces [Ref: Provinces__c]
- `Savings__c` (Number) — Savings
- `State_buildings__c` (Lookup) — State buildings [Ref: State_buildings__c]

## Stockpile__c ('Stockpile') — 0 custom fields

## String__c ('String') — 1 custom fields
- `Value__c` (Text) — Value

## Substate__c ('Substate') — 4 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date

## Tag__c ('Tag') — 1 custom fields
- `Value__c` (Text) — Value

## TaxEff__c ('TaxEff') — 1 custom fields
- `Value__c` (Number) — Value

## TaxIncome__c ('TaxIncome') — 1 custom fields
- `Value__c` (Number) — Value

## Technology_Toggle__c ('Technology Toggle') — 2 custom fields
- `Technology__c` (Text) — Technology
- `Value__c` (Number) — Value

## Technology__c ('Technology') — 0 custom fields

## Threat__c ('Threat') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## Trade_Good__c ('Trade Good') — 4 custom fields
- `Automate_trade__c` (Checkbox) — Automate trade
- `Buy__c` (Checkbox) — Buy
- `Good__c` (Text) — Good
- `Limit__c` (Number) — Limit

## Trade__c ('Trade') — 0 custom fields

## Unit_Cost__c ('Unit Cost') — 2 custom fields
- `Key__c` (Text) — Key
- `Value__c` (Number) — Value

## UpperHouse__c ('UpperHouse') — 0 custom fields

## Variable__c ('Variable') — 0 custom fields

## Vassal__c ('Vassal') — 4 custom fields
- `End_date__c` (Text) — End date
- `First__c` (Text) — First
- `Second__c` (Text) — Second
- `Start_date__c` (Text) — Start date

## WarGoal__c ('WarGoal') — 8 custom fields
- `Actor__c` (Text) — Actor
- `Casus_belli__c` (Text) — Casus belli
- `Change__c` (Number) — Change
- `Date__c` (Text) — Date
- `Is_fulfilled__c` (Checkbox) — Is fulfilled
- `Receiver__c` (Text) — Receiver
- `Score__c` (Number) — Score
- `State_province_id__c` (Number) — State province id

## WarWith__c ('WarWith') — 2 custom fields
- `Id__c` (Text) — Id
- `Value__c` (Number) — Value

## War_History_Entry__c ('War History Entry') — 6 custom fields
- `Add_attacker__c` (Text) — Add attacker
- `Add_defender__c` (Text) — Add defender
- `Battle__c` (Lookup) — Battle [Ref: Battle__c]
- `Date__c` (Text) — Date
- `Rem_attacker__c` (Text) — Rem attacker
- `Rem_defender__c` (Text) — Rem defender

## World_Market__c ('World Market') — 1 custom fields
- `Price_history_last_update__c` (Text) — Price history last update

**Track B Total:** 126 Custom Objects, 861 Custom Fields.
