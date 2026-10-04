# 13. Salesforce Field Lineage and Transformation Rules

## Overview
This document details the exact path tracing from source `.v2` save game paths to target Salesforce object fields.

---

## Path Lineage Map

| Target Salesforce Field | Raw `.v2` Save Game Path | Canonical Domain Attribute | Transformation / Calculation Formula |
| ----------------------- | ------------------------ | -------------------------- | ------------------------------------ |
| `Economy_Analysis__c.Ingame_Date__c` | `date="1872.9.25"` | SaveSnapshot.IngameDate | Parsed from YYYY.M.D to Salesforce Date. |
| `Economy_Analysis__c.Player_Country_Tag__c` | `player="TUR"` | SaveSnapshot.PlayerCountryTag | Uppercase string copy. |
| `Country_Economy__c.Population__c` | `<TAG>` province POP sizes | CountrySnapshot.Population | Sum of POP `size` * 4 for country provinces. |
| `Country_Economy__c.Core_Population__c` | `<TAG>` non-colony POP sizes | CountrySnapshot.CorePopulation | Sum of non-colony POP `size` * 4. |
| `Country_Economy__c.GDP__c` | Industry outputs | CountrySnapshot.GDP | Factory_GDP + Province_GDP + Artisan_GDP. |
| `Country_Economy__c.GDP_Per_Capita__c` | Derived | CountrySnapshot.GDPPerCapita | `IF(Core_Population__c > 0, GDP__c / Core_Population__c, 0.0)` |
| `Product_Economy__c.Price__c` | `worldmarket.price_pool.<good>` | ProductSnapshot.Price | Direct float value conversion. |
| `Product_Economy__c.Total_World_Supply__c` | `worldmarket.supply_pool.<good>` | ProductSnapshot.TotalWorldSupply | Direct float value conversion. |
| `Country_Product_Economy__c.Import_Value__c` | Market consumption | CountryProduct.ImportValue | `Bought_Quantity__c * Product_Price` |
| `Country_Product_Economy__c.Export_Value__c` | Market sales | CountryProduct.ExportValue | `Sold_Quantity__c * Product_Price` |
| `Factory_Economy__c.Profit__c` | `state_buildings` data | FactorySnapshot.Profit | `Revenue__c - Input_Cost__c - Wages_Paid__c` |
