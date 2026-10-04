# 12. Salesforce Custom Field Inventory

## Summary
The verified Salesforce target model consists of **13 Custom Objects** and **138 Custom Fields**.

---

## Detailed Inventory by Object

### 1. `Economy_Analysis__c` (12 fields)
- `Save_File_Name__c` (Text, External ID, Unique)
- `Source_Save_File_Name__c` (Text)
- `Ingame_Date__c` (Date)
- `Analysis_Timestamp__c` (DateTime)
- `Player_Country_Tag__c` (Text)
- `Total_World_GDP__c` (Summary - Rollup sum Country_Economy__c.GDP__c)
- `Total_World_Population__c` (Summary - Rollup sum Country_Economy__c.Population__c)
- `Total_World_Imports__c` (Currency)
- `Total_World_Exports__c` (Currency)
- `Import_Status__c` (Picklist: RECEIVED, PROCESSING, CALCULATING, COMPLETED, FAILED)
- `Import_Diagnostic_Message__c` (LongTextArea)
- `Unique_Snapshot_Key__c` (Text, External ID, Unique)

### 2. `Country_Economy__c` (26 fields)
- `Country_Tag__c` (Text)
- `Country__c` (Lookup -> Country__c)
- `Economy_Analysis__c` (MasterDetail -> Economy_Analysis__c)
- `Population__c` (Number)
- `Core_Population__c` (Number)
- `Colony_Population__c` (Number)
- `GDP__c` (Currency)
- `GDP_Rank__c` (Number)
- `GDP_Per_Capita__c` (Formula Currency: `IF(Core_Population__c > 0, GDP__c / Core_Population__c, 0.0)`)
- `GDP_Share_Percent__c` (Formula Percent: `IF(Economy_Analysis__r.Total_World_GDP__c > 0, GDP__c / Economy_Analysis__r.Total_World_GDP__c, 0.0)`)
- `Workforce__c`, `Employment__c`, `Unemployment_Rate__c` (Formula)
- `Workforce_Factory__c`, `Employment_Factory__c`, `Unemployment_Rate_Factory__c` (Formula)
- `Workforce_RGO__c`, `Employment_RGO__c`, `Unemployment_Rate_RGO__c` (Formula)
- `Factory_GDP__c`, `Province_GDP__c`, `Artisan_GDP__c`, `Gold_Income__c` (Currency)
- `Total_Imports_Value__c`, `Total_Exports_Value__c` (Rollup Summaries)
- `Unique_Snapshot_Key__c` (Text, External ID, Unique)

### 3. `Product_Economy__c` (11 fields)
- `Product_Code__c` (Text), `Product__c` (Lookup -> Product__c), `Economy_Analysis__c` (MasterDetail)
- `Base_Price__c`, `Price__c`, `Total_World_Supply__c`, `Real_Demand__c`, `Max_Demand__c`
- `Inflation_Percent__c` (Formula), `Overproduction_Percent__c` (Formula)
- `Unique_Snapshot_Key__c` (External ID)

### 4. `Country_Product_Economy__c` (19 fields)
- `Country_Economy__c` (MasterDetail), `Product_Economy__c` (Lookup), `Product__c` (Lookup)
- `Product_Code__c`, `Sold_Domestic__c`, `Bought_Quantity__c`, `Sold_Quantity__c`, `Thrown_To_Market__c`
- `Import_Value__c`, `Export_Value__c`, `Domestic_Sales_Value__c`, `GDP_Contribution__c`
- `Actual_Demand_Pounds__c`, `Actual_Supply_Pounds__c`, `Total_Supply_Pounds__c`
- `Unique_Snapshot_Key__c` (External ID)

### 5. `State_Economy__c` (15 fields), `Province_Economy__c` (11 fields), `Factory_Economy__c` (21 fields), `Artisan_Economy__c` (11 fields).
