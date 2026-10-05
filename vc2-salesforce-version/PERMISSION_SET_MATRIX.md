# Victoria 2 Economy Analyzer — Permission Set Access Matrix

## Summary Metrics
- **Total objects:** 139
- **Total fields:** 997
- **Total Apex classes:** 9 (6 User, 9 Admin)
- **Total tabs:** none

---

| Object | User Read | User Edit | User Create | User Delete | Admin Read | Admin Edit | Admin Create | Admin Delete | Rationale |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---|
| `AccumulatedLosse__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `ActiveInvention__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `ActiveParty__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `ActiveWar__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `ActualSoldDomestic__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `AiHardStrategy__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Ai__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Alliance__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `AnarchoLiberal__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Antagonize__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Army__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Article__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Artisan_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Attacker__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Back__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Battle__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Befriend__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `BudgetBalance__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `BuildingProv__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `BuiltNew__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `BuyDomestic__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Canal__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `CasusBelli__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Colonize__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Colony__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Combat__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Communist__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `ConquerProv__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Construction__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Consumption_Cache__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Country_Country_Ref__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Country_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Country_Product_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Country_Save_State__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Country__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Creditor__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `CrisisManager__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Culture__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Date__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Defender__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Diplomacy__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `DomesticDemandPool__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `DomesticSupplyPool__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Economy_Analysis__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Economy_Import_Event__e` | true | false | true | false | true | false | true | false | Platform event (special) — create required to publish events |
| `Employee__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Employment__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Expense__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Factory_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Fascist__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Fired_Event__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Fired_Events__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Flag__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `ForeignInvestment__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Front__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Game_Flag__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Gameplay_Settings__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Goods_Vector_Line__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `GovernmentFlag__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `GreatNation__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `History__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `IllegalInvention__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Income__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Influence__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `InputGood__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `InterestingCountrie__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Invention__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Leader__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Market_Line__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `MaxBought__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `MiddleTax__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `MilitaryAcces__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Modifier__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Movement__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `NationalFocu__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Navy__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `NewsCollector__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `NewsScope__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `News_Scope_Value__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `OriginalWargoal__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Outliner__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Overseas_Penalty__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Path__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `PlayerMonthlyPopGrowth__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `PoorTax__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Pop_Need__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Pop_Stockpile__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Pop__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Popproject__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `PossibleInvention__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `PreviousWar__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Price_Snapshot__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Product_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Product__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `ProfitHistoryEntry__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Protect__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Province_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Province_Save_State__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Province__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `RGO_Employment__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `RGO__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Railroad__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `RebelFaction__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Regiment__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Region__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Research__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `RichTax__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Rival__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Save_Game_Country_Ref__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Save_Game__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `SavedCountrySupply__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Setgameplayoption__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Ship__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `SiegeCombat__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Socialist__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `SoldSupplyPool__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `StateBuilding__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `State_Economy__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `State_Save_State__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `State__c` | true | false | false | false | true | true | true | true | Protected economy object — read-only for user, full write/import for admin |
| `Stockpile__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `String__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Substate__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Tag__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `TaxEff__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `TaxIncome__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Technology_Toggle__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Technology__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Threat__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Trade_Good__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Trade__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Unit_Cost__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `UpperHouse__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Variable__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `Vassal__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `WarGoal__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `WarWith__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `War_History_Entry__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
| `World_Market__c` | true | false | false | false | true | true | true | true | Save-game / junction object — read-only by design for user, full write for admin |
