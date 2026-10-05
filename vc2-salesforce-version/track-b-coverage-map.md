# Track B — Coverage Mapping Table

**Source Model:** `salesforce_model_compact.txt` (126 objects)
**Target Metadata:** `force-app/main/default/objects/` (139 object folders)
**Status:** 100% Reconciled (126 / 126 objects accounted for)

## Summary of Dispositions

| Disposition | Count | Description |
|---|---:|---|
| **REPRODUCED** | 120 | Direct 1:1 object metadata creation with identical API name |
| **RENAMED** | 4 | Renamed to prevent collision with master objects or reserved names |
| **FLATTENED** | 2 | Sub-objects flattened into parent object custom fields |
| **TOTAL COMPACT OBJECTS** | **126** | **100% accounted for** |

*Note: In addition to the 126 compact save-game objects mapped below, 2 junction objects (`Save_Game_Country_Ref__c`, `Country_Country_Ref__c`) were created to resolve relationship governor limit constraints, bringing total new Track B metadata objects to 123, plus 13 protected economy artifacts (4 sharing master names: Country__c, Province__c, State__c, Product__c), totaling 139 custom object folders in the metadata tree.*

## 1:1 Coverage Mapping Table

| Compact Model Object | Disposition | Delivered API Name | Notes |
|---|---|---|---|
| `Save_Game__c` | `REPRODUCED` | `Save_Game__c` | Direct reproduction |
| `Game_Flag__c` | `REPRODUCED` | `Game_Flag__c` | Direct reproduction |
| `Gameplay_Settings__c` | `REPRODUCED` | `Gameplay_Settings__c` | Direct reproduction |
| `Setgameplayoption__c` | `REPRODUCED` | `Setgameplayoption__c` | Direct reproduction |
| `World_Market__c` | `REPRODUCED` | `World_Market__c` | Direct reproduction |
| `Price_Snapshot__c` | `REPRODUCED` | `Price_Snapshot__c` | Direct reproduction |
| `Consumption_Cache__c` | `REPRODUCED` | `Consumption_Cache__c` | Direct reproduction |
| `Overseas_Penalty__c` | `REPRODUCED` | `Overseas_Penalty__c` | Direct reproduction |
| `Unit_Cost__c` | `REPRODUCED` | `Unit_Cost__c` | Direct reproduction |
| `BudgetBalance__c` | `REPRODUCED` | `BudgetBalance__c` | Direct reproduction |
| `PlayerMonthlyPopGrowth__c` | `REPRODUCED` | `PlayerMonthlyPopGrowth__c` | Direct reproduction |
| `Fascist__c` | `REPRODUCED` | `Fascist__c` | Direct reproduction |
| `Socialist__c` | `REPRODUCED` | `Socialist__c` | Direct reproduction |
| `Communist__c` | `REPRODUCED` | `Communist__c` | Direct reproduction |
| `AnarchoLiberal__c` | `REPRODUCED` | `AnarchoLiberal__c` | Direct reproduction |
| `Canal__c` | `REPRODUCED` | `Canal__c` | Direct reproduction |
| `Goods_Vector_Line__c` | `REPRODUCED` | `Goods_Vector_Line__c` | Direct reproduction |
| `Fired_Events__c` | `REPRODUCED` | `Fired_Events__c` | Direct reproduction |
| `Fired_Event__c` | `REPRODUCED` | `Fired_Event__c` | Direct reproduction |
| `Province__c` | `RENAMED` | `Province_Save_State__c` | Renamed to avoid collision with master Province__c |
| `Pop__c` | `REPRODUCED` | `Pop__c` | Direct reproduction |
| `Ideology__c` | `FLATTENED` | `Pop__c fields` | Flattened into Pop__c custom fields (Ideology_Key__c, Ideology_Value__c) |
| `Issue__c` | `FLATTENED` | `Pop__c fields` | Flattened into Pop__c custom fields (Issue_Key__c, Issue_Value__c) |
| `Pop_Stockpile__c` | `REPRODUCED` | `Pop_Stockpile__c` | Direct reproduction |
| `Pop_Need__c` | `REPRODUCED` | `Pop_Need__c` | Direct reproduction |
| `Construction__c` | `REPRODUCED` | `Construction__c` | Direct reproduction |
| `RGO__c` | `REPRODUCED` | `RGO__c` | Direct reproduction |
| `RGO_Employment__c` | `REPRODUCED` | `RGO_Employment__c` | Direct reproduction |
| `Employee__c` | `REPRODUCED` | `Employee__c` | Direct reproduction |
| `Flag__c` | `REPRODUCED` | `Flag__c` | Direct reproduction |
| `Variable__c` | `REPRODUCED` | `Variable__c` | Direct reproduction |
| `Technology__c` | `REPRODUCED` | `Technology__c` | Direct reproduction |
| `UpperHouse__c` | `REPRODUCED` | `UpperHouse__c` | Direct reproduction |
| `RichTax__c` | `REPRODUCED` | `RichTax__c` | Direct reproduction |
| `TaxIncome__c` | `REPRODUCED` | `TaxIncome__c` | Direct reproduction |
| `TaxEff__c` | `REPRODUCED` | `TaxEff__c` | Direct reproduction |
| `MiddleTax__c` | `REPRODUCED` | `MiddleTax__c` | Direct reproduction |
| `PoorTax__c` | `REPRODUCED` | `PoorTax__c` | Direct reproduction |
| `Leader__c` | `REPRODUCED` | `Leader__c` | Direct reproduction |
| `Army__c` | `REPRODUCED` | `Army__c` | Direct reproduction |
| `Path__c` | `REPRODUCED` | `Path__c` | Direct reproduction |
| `Regiment__c` | `REPRODUCED` | `Regiment__c` | Direct reproduction |
| `IllegalInvention__c` | `REPRODUCED` | `IllegalInvention__c` | Direct reproduction |
| `GovernmentFlag__c` | `REPRODUCED` | `GovernmentFlag__c` | Direct reproduction |
| `AiHardStrategy__c` | `REPRODUCED` | `AiHardStrategy__c` | Direct reproduction |
| `Ai__c` | `REPRODUCED` | `Ai__c` | Direct reproduction |
| `BuyDomestic__c` | `REPRODUCED` | `BuyDomestic__c` | Direct reproduction |
| `Trade__c` | `REPRODUCED` | `Trade__c` | Direct reproduction |
| `DomesticSupplyPool__c` | `REPRODUCED` | `DomesticSupplyPool__c` | Direct reproduction |
| `SoldSupplyPool__c` | `REPRODUCED` | `SoldSupplyPool__c` | Direct reproduction |
| `DomesticDemandPool__c` | `REPRODUCED` | `DomesticDemandPool__c` | Direct reproduction |
| `ActualSoldDomestic__c` | `REPRODUCED` | `ActualSoldDomestic__c` | Direct reproduction |
| `SavedCountrySupply__c` | `REPRODUCED` | `SavedCountrySupply__c` | Direct reproduction |
| `MaxBought__c` | `REPRODUCED` | `MaxBought__c` | Direct reproduction |
| `NationalFocu__c` | `REPRODUCED` | `NationalFocu__c` | Direct reproduction |
| `Expense__c` | `REPRODUCED` | `Expense__c` | Direct reproduction |
| `Income__c` | `REPRODUCED` | `Income__c` | Direct reproduction |
| `Research__c` | `REPRODUCED` | `Research__c` | Direct reproduction |
| `ActiveParty__c` | `REPRODUCED` | `ActiveParty__c` | Direct reproduction |
| `Modifier__c` | `REPRODUCED` | `Modifier__c` | Direct reproduction |
| `Navy__c` | `REPRODUCED` | `Navy__c` | Direct reproduction |
| `Ship__c` | `REPRODUCED` | `Ship__c` | Direct reproduction |
| `ActiveInvention__c` | `REPRODUCED` | `ActiveInvention__c` | Direct reproduction |
| `PossibleInvention__c` | `REPRODUCED` | `PossibleInvention__c` | Direct reproduction |
| `ConquerProv__c` | `REPRODUCED` | `ConquerProv__c` | Direct reproduction |
| `Threat__c` | `REPRODUCED` | `Threat__c` | Direct reproduction |
| `Antagonize__c` | `REPRODUCED` | `Antagonize__c` | Direct reproduction |
| `Befriend__c` | `REPRODUCED` | `Befriend__c` | Direct reproduction |
| `Protect__c` | `REPRODUCED` | `Protect__c` | Direct reproduction |
| `Rival__c` | `REPRODUCED` | `Rival__c` | Direct reproduction |
| `ForeignInvestment__c` | `REPRODUCED` | `ForeignInvestment__c` | Direct reproduction |
| `Culture__c` | `REPRODUCED` | `Culture__c` | Direct reproduction |
| `Movement__c` | `REPRODUCED` | `Movement__c` | Direct reproduction |
| `State__c` | `RENAMED` | `State_Save_State__c` | Renamed to avoid collision with master State__c |
| `Colonize__c` | `REPRODUCED` | `Colonize__c` | Direct reproduction |
| `Influence__c` | `REPRODUCED` | `Influence__c` | Direct reproduction |
| `InterestingCountrie__c` | `REPRODUCED` | `InterestingCountrie__c` | Direct reproduction |
| `Railroad__c` | `REPRODUCED` | `Railroad__c` | Direct reproduction |
| `StateBuilding__c` | `REPRODUCED` | `StateBuilding__c` | Direct reproduction |
| `Employment__c` | `REPRODUCED` | `Employment__c` | Direct reproduction |
| `ProfitHistoryEntry__c` | `REPRODUCED` | `ProfitHistoryEntry__c` | Direct reproduction |
| `BuildingProv__c` | `REPRODUCED` | `BuildingProv__c` | Direct reproduction |
| `Popproject__c` | `REPRODUCED` | `Popproject__c` | Direct reproduction |
| `Creditor__c` | `REPRODUCED` | `Creditor__c` | Direct reproduction |
| `Stockpile__c` | `REPRODUCED` | `Stockpile__c` | Direct reproduction |
| `InputGood__c` | `REPRODUCED` | `InputGood__c` | Direct reproduction |
| `WarWith__c` | `REPRODUCED` | `WarWith__c` | Direct reproduction |
| `MilitaryAcces__c` | `REPRODUCED` | `MilitaryAcces__c` | Direct reproduction |
| `RebelFaction__c` | `REPRODUCED` | `RebelFaction__c` | Direct reproduction |
| `Diplomacy__c` | `REPRODUCED` | `Diplomacy__c` | Direct reproduction |
| `Vassal__c` | `REPRODUCED` | `Vassal__c` | Direct reproduction |
| `Alliance__c` | `REPRODUCED` | `Alliance__c` | Direct reproduction |
| `Substate__c` | `REPRODUCED` | `Substate__c` | Direct reproduction |
| `CasusBelli__c` | `REPRODUCED` | `CasusBelli__c` | Direct reproduction |
| `Combat__c` | `REPRODUCED` | `Combat__c` | Direct reproduction |
| `SiegeCombat__c` | `REPRODUCED` | `SiegeCombat__c` | Direct reproduction |
| `Attacker__c` | `REPRODUCED` | `Attacker__c` | Direct reproduction |
| `AccumulatedLosse__c` | `REPRODUCED` | `AccumulatedLosse__c` | Direct reproduction |
| `Front__c` | `REPRODUCED` | `Front__c` | Direct reproduction |
| `Back__c` | `REPRODUCED` | `Back__c` | Direct reproduction |
| `Defender__c` | `REPRODUCED` | `Defender__c` | Direct reproduction |
| `ActiveWar__c` | `REPRODUCED` | `ActiveWar__c` | Direct reproduction |
| `History__c` | `REPRODUCED` | `History__c` | Direct reproduction |
| `Battle__c` | `REPRODUCED` | `Battle__c` | Direct reproduction |
| `OriginalWargoal__c` | `REPRODUCED` | `OriginalWargoal__c` | Direct reproduction |
| `WarGoal__c` | `REPRODUCED` | `WarGoal__c` | Direct reproduction |
| `PreviousWar__c` | `REPRODUCED` | `PreviousWar__c` | Direct reproduction |
| `Invention__c` | `REPRODUCED` | `Invention__c` | Direct reproduction |
| `GreatNation__c` | `REPRODUCED` | `GreatNation__c` | Direct reproduction |
| `Outliner__c` | `REPRODUCED` | `Outliner__c` | Direct reproduction |
| `NewsCollector__c` | `REPRODUCED` | `NewsCollector__c` | Direct reproduction |
| `NewsScope__c` | `REPRODUCED` | `NewsScope__c` | Direct reproduction |
| `Tag__c` | `REPRODUCED` | `Tag__c` | Direct reproduction |
| `String__c` | `REPRODUCED` | `String__c` | Direct reproduction |
| `Date__c` | `REPRODUCED` | `Date__c` | Direct reproduction |
| `BuiltNew__c` | `REPRODUCED` | `BuiltNew__c` | Direct reproduction |
| `Article__c` | `REPRODUCED` | `Article__c` | Direct reproduction |
| `Value__c` | `RENAMED` | `News_Scope_Value__c` | Renamed to avoid generic naming collision under NewsScope__c |
| `CrisisManager__c` | `REPRODUCED` | `CrisisManager__c` | Direct reproduction |
| `Region__c` | `REPRODUCED` | `Region__c` | Direct reproduction |
| `Colony__c` | `REPRODUCED` | `Colony__c` | Direct reproduction |
| `Country__c` | `RENAMED` | `Country_Save_State__c` | Renamed to avoid collision with master Country__c |
| `Technology_Toggle__c` | `REPRODUCED` | `Technology_Toggle__c` | Direct reproduction |
| `Trade_Good__c` | `REPRODUCED` | `Trade_Good__c` | Direct reproduction |
| `War_History_Entry__c` | `REPRODUCED` | `War_History_Entry__c` | Direct reproduction |
| `Market_Line__c` | `REPRODUCED` | `Market_Line__c` | Direct reproduction |

## Compact Model Fields Not Reproduced / Flattened Rationale

| Compact Object | Compact Field | Disposition | Rationale |
|---|---|---|---|
| `Ideology__c` | All fields | `FLATTENED` | Ideology key-value pairs flattened into `Pop__c` custom fields (`Ideology_Key__c`, `Ideology_Value__c`). |
| `Issue__c` | All fields | `FLATTENED` | Issue key-value pairs flattened into `Pop__c` custom fields (`Issue_Key__c`, `Issue_Value__c`). |
| `Save_Game__c` | 271 Country LK fields | `JUNCTIONED` | Replaced 271 direct lookup fields with junction object `Save_Game_Country_Ref__c` to satisfy 40 lookup governor limit. |
| `Country_Save_State__c` | 116 Country LK fields | `JUNCTIONED` | Replaced 116 direct lookup fields with junction object `Country_Country_Ref__c` to satisfy 40 lookup governor limit. |
