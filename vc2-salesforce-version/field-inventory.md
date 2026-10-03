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
