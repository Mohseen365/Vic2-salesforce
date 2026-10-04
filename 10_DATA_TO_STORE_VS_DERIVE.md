# 10. Victoria 2 Data Storage Strategy: Persisted vs Derived

## Overview
To optimize Salesforce custom object record limits, storage capacity, and query speed, this document establishes strict boundaries between data that is persisted in Salesforce, data that is dynamically calculated via Apex/Formulas, and transient raw data.

---

## Classification Matrix

| Metric / Attribute | Strategy | Reason | Mechanism / Implementation |
| ------------------ | -------- | ------ | -------------------------- |
| Treasury & Bank Cash | **STORE** | Raw state directly from save | Number Field (`Currency`) |
| Commodity Base Price & Market Price | **STORE** | Raw market equilibrium values | Number Field (`Currency`) |
| Domestic Quantity Sold / Bought | **STORE** | Raw trade volumes from save | Number Field (`Number`) |
| Country Total Import Value | **DERIVE (Rollup)** | Sum of Country-Product Import Values | Rollup Summary Field `Total_Imports_Value__c` |
| Country Total Export Value | **DERIVE (Rollup)** | Sum of Country-Product Export Values | Rollup Summary Field `Total_Exports_Value__c` |
| Country GDP | **STORE & DERIVE** | Engine computes sum of domestic industry, persists to field | Calculated in `EconomyCalculationEngine.cls` |
| Country GDP Per Capita | **DERIVE (Formula)** | Dynamic formula `GDP__c / Core_Population__c` | Custom Formula Field `GDP_Per_Capita__c` |
| GDP Share Percent | **DERIVE (Formula)** | Dynamic formula `GDP__c / Analysis.Total_World_GDP__c` | Custom Formula Field `GDP_Share_Percent__c` |
| Commodity Overproduction % | **DERIVE (Formula)** | Dynamic formula `(Supply / Real Demand) * 100` | Custom Formula Field `Overproduction_Percent__c` |
| Factory Productivity | **DERIVE (Formula)** | Dynamic formula `Factory_GDP__c / Employees__c` | Custom Formula Field `Productivity__c` |
| Factory Profit | **DERIVE (Formula)** | Dynamic formula `Revenue - Input_Cost - Wages` | Custom Formula Field `Profit__c` |
| Raw POP Demographics (46K records) | **TRANSIENT** | Prevents Salesforce LDV governor limit breach | Off-heap JSON payload, unpersisted |
