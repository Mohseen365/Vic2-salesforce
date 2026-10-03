# Victoria 2 Economy Analyzer — Salesforce Field Inventory

This document provides the authoritative inventory of all Custom Objects, Custom Fields, Data Types, Precisions, Formulas, External IDs, and Relationships created in **Phase 1 (Data Model Setup)**.

## Summary Metrics
- **Custom Objects:** 8
- **Custom Fields:** 72

---

## Custom Object: `Country_Economy__c` (Country Economy)
- **Sharing Model:** `ControlledByParent`

| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Country_Tag__c` | Country Tag | Text | 10 | - | None |
| `Country__c` | Country | Lookup | - | Target: `Country__c`, Rel: `Country_Economies` | Required |
| `Economy_Analysis__c` | Economy Analysis | MasterDetail | - | Target: `Economy_Analysis__c`, Rel: `Country_Economies` | None |
| `Employment_Factory__c` | Employment Factory | Number | 18, 0 | - | None |
| `Employment_RGO__c` | Employment RGO | Number | 18, 0 | - | None |
| `Employment__c` | Employment | Number | 18, 0 | - | None |
| `GDP_Per_Capita__c` | GDP Per Capita (£/100k) | Currency | 18, 2 | `IF(Population__c > 0, (GDP__c / Population__c) * 100000, 0.0)` | None |
| `GDP_Rank__c` | GDP Rank | Number | 6, 0 | - | None |
| `GDP_Share_Percent__c` | GDP Share % | Percent | 6, 4 | `IF(Economy_Analysis__r.Total_World_GDP__c > 0, GDP__c / Economy_Analysis__r.Total_World_GDP__c, 0.0)` | None |
| `GDP__c` | GDP (£) | Currency | 18, 2 | - | None |
| `Gold_Income__c` | Gold Income (£) | Currency | 18, 2 | - | None |
| `Population__c` | Population | Number | 18, 0 | - | None |
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
| `Country_Economy__c` | Country Economy | MasterDetail | - | Target: `Country_Economy__c`, Rel: `Province_Economies` | None |
| `Population__c` | Population | Number | 18, 0 | - | None |
| `Province__c` | Province | Lookup | - | Target: `Province__c`, Rel: `Province_Economies` | Required |
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
