# Track E — Data Model Remediation Diff Summary

## 1. Overview
This document details the exact before-and-after changes applied across all 58 defects (15 BLOCKING + 43 MAJOR) in `salesforce_model_expanded.txt`.

---

## 2. Itemized Diff Table (58 Defects)

| Defect # | Object API Name | Context / Field | Change Type | Before | After | Verified |
|---|---|---|---|---|---|---|
| **1** | `Save_Game__c` | Direct `<Country_Ref__c>` Lookups | Line Removal | `- <Country_Ref__c> (Lookup(Country_Save_State_Save_State__c)) // 271 lookup fields...` | *(Removed line entirely)* | ✅ |
| **2** | `Save_Game__c` | `<Country_Ref__c>` Target / Junction | Junction Enforcement | Direct lookups to non-existent target | Enforced `Save_Game_Country_Ref__c` junction | ✅ |
| **3** | `Country_Save_State__c` | Direct `<Country_Ref__c>` Lookups | Line Removal | `- <Country_Ref__c> (Lookup(Country_Save_State_Save_State__c)) // 116 lookup fields...` | *(Removed line entirely)* | ✅ |
| **4** | `Country_Save_State__c` | `<Country_Ref__c>` Target / Junction | Junction Enforcement | Direct lookups to non-existent target | Enforced `Country_Country_Ref__c` junction | ✅ |
| **5** | `Pop__c` | `Ideology__c` Field & Child | Line Removal | `- Ideology__c (Lookup(Ideology__c))` / `- Ideology__c (LK, from ideology)` | *(Removed lines; retained flattened fields)* | ✅ |
| **6** | `Pop__c` | `Issues__c` Field & Child | Line Removal | `- Issues__c (Lookup(Issue__c))` / `- Issue__c (LK, from issues)` | *(Removed lines; retained flattened fields)* | ✅ |
| **7** | `Construction__c` | `Country_Save_State_Save_State__c` | Rename | `- Country_Save_State_Save_State__c (Text)` | `- Country_Save_State__c (Text)` | ✅ |
| **8** | `Leader__c` | `Country_Save_State_Save_State__c` | Rename | `- Country_Save_State_Save_State__c (Text)` | `- Country_Save_State__c (Text)` | ✅ |
| **9** | `State_Save_State__c` | `Provinces__c` Lookup Target | Retarget | `- Provinces__c (Lookup(Province_Save_State_Save_State__c))` | `- Provinces__c (Lookup(Province_Save_State__c))` | ✅ |
| **10** | `Popproject__c` | `Province_Save_State_Save_State__c` | Rename | `- Province_Save_State_Save_State__c (Number(16,5))` | `- Province_Save_State__c (Number(16,5))` | ✅ |
| **11** | `Creditor__c` | `Country_Save_State_Save_State__c` | Rename | `- Country_Save_State_Save_State__c (Text)` | `- Country_Save_State__c (Text)` | ✅ |
| **12** | `RebelFaction__c` | `Country_Save_State_Save_State__c` | Rename | `- Country_Save_State_Save_State__c (Text)` | `- Country_Save_State__c (Text)` | ✅ |
| **13** | `RebelFaction__c` | `Province_Save_State_Save_State__c` | Rename | `- Province_Save_State_Save_State__c (Number(16,5))` | `- Province_Save_State__c (Number(16,5))` | ✅ |
| **14** | `Attacker__c` | `Country_Save_State_Save_State__c` | Rename | `- Country_Save_State_Save_State__c (Text)` | `- Country_Save_State__c (Text)` | ✅ |
| **15** | `Defender__c` | `Country_Save_State_Save_State__c` | Rename | `- Country_Save_State_Save_State__c (Text)` | `- Country_Save_State__c (Text)` | ✅ |
| **16** | `Save_Game_Country_Ref__c` | `Country__c` Field Name & Target | Rename & Retarget | `- Country__c (Lookup(Country__c))` | `- Country_Save_State__c (Lookup(Country_Save_State__c))` | ✅ |
| **17** | `Country_Country_Ref__c` | `Country__c` Field Name & Target | Rename & Retarget | `- Country__c (Lookup(Country__c))` | `- Target_Country_Save_State__c (Lookup(Country_Save_State__c))` | ✅ |
| **18** | `Game_Flag__c` | `Flag_News_Scope_Value__c` | Revert Rename | `- Flag_News_Scope_Value__c (Checkbox)` | `- Flag_Value__c (Checkbox)` | ✅ |
| **19** | `Setgameplayoption__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **20** | `Overseas_Penalty__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **21** | `Unit_Cost__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **22** | `BudgetBalance__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **23** | `PlayerMonthlyPopGrowth__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **24** | `Fascist__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **25** | `Socialist__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **26** | `Communist__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **27** | `AnarchoLiberal__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **28** | `Canal__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **29** | `Goods_Vector_Line__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **30** | `Pop_Stockpile__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **31** | `Pop_Need__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **32** | `Flag__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **33** | `Variable__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **34** | `UpperHouse__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **35** | `RichTax__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **36** | `TaxIncome__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **37** | `TaxEff__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **38** | `MiddleTax__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **39** | `PoorTax__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **40** | `BuyDomestic__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **41** | `DomesticSupplyPool__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **42** | `SoldSupplyPool__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **43** | `DomesticDemandPool__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **44** | `ActualSoldDomestic__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **45** | `SavedCountrySupply__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **46** | `MaxBought__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **47** | `Expense__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **48** | `Income__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **49** | `Research__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **50** | `ForeignInvestment__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **51** | `Culture__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **52** | `Influence__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **53** | `InterestingCountrie__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **54** | `ProfitHistoryEntry__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **55** | `Stockpile__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **56** | `InputGood__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **57** | `AccumulatedLosse__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Number(16,5))` | `- Value__c (Number(16,5))` | ✅ |
| **58** | `Tag__c` / `String__c` / `Date__c` | `News_Scope_Value__c` | Revert Rename | `- News_Scope_Value__c (Text)` | `- Value__c (Text)` | ✅ |
