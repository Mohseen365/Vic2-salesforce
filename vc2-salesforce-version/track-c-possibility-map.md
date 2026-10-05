# Track C — Master Data Model Possibility Map & Capability Catalogue

## 1. Executive Summary

This document serves as the master capability index for Track C, mapping the entire 136-object Victoria 2 Save-Game Salesforce Data Model (`salesforce_model_expanded.txt`) to actionable application capabilities and user-facing features.

A total of **125 distinct capabilities** were enumerated across 12 save-game domains. These capabilities have been grouped into **16 high-level features**, evaluated for effort, business value, technical risk, and code reuse.

---

## 2. Capability Enumeration by Domain (125 Capabilities)

### 2.1 Save Envelope Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-001` | What is the in-game calendar date and active player tag? | `Save_Game__c` | `Date__c`, `Player__c` | `economyAnalysisHeader` | `SaveHeaderDTO` |
| `CAP-002` | What automation settings and difficulty options are enabled? | `Save_Game__c`, `Gameplay_Settings__c` | `Automate_trade__c`, `Automate_sliders__c`, `Great_wars_enabled__c` | None | `SaveSettingsController` |
| `CAP-003` | Which global gameplay flags have been set in this save state? | `Game_Flag__c` | `Name__c`, `Value__c` | None | `GameFlagsDTO` |
| `CAP-004` | What is the historical pop index and start date of the scenario? | `Save_Game__c` | `Start_date__c`, `Start_pop_index__c` | `AnalysisSummaryDTO` | None |
| `CAP-005` | Which canals are constructed and open to world navigation? | `Canal__c` | `Name__c`, `Value__c` | None | `CanalStatusSelector` |
| `CAP-006` | What major historical events have been fired globally? | `Fired_Events__c`, `Fired_Event__c` | `Name__c`, `Id__c` | None | `GlobalEventSelector` |
| `CAP-007` | What player monthly pop growth tag and date are registered? | `Save_Game__c` | `Player_monthly_pop_growth_tag__c`, `Player_monthly_pop_growth_date__c` | None | `PopGrowthHeaderDTO` |
| `CAP-008` | What gameplay setting toggles (ai, rules) are saved in setgameplayoption? | `Setgameplayoption__c` | `Value__c` | None | `GameplayOptionSelector` |

### 2.2 World Market Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-009` | What is the world market price trend for every commodity? | `Price_Snapshot__c`, `Market_Line__c` | `Price__c`, `Good__c`, `Value__c` | `ProductSelector`, `productListView` | `MarketTrendDTO` |
| `CAP-010` | What is the global supply and demand pool for raw goods vs manufactured goods? | `Market_Line__c` | `Supply_pool__c`, `Actual_sold__c` | `globalEconomyDashboard` | `MarketSupplyDemandSelector` |
| `CAP-011` | What goods are in the player POP consumption cache? | `Consumption_Cache__c` | `Good__c`, `Amount__c` | None | `PopConsumptionDTO` |
| `CAP-012` | Which goods experienced the highest price volatility between saves? | `Price_Snapshot__c`, `World_Market__c` | `Price_change__c`, `Price__c` | `productDashboard` | `PriceVolatilityCalculator` |
| `CAP-013` | Which goods are currently undersupplied on the world market? | `Market_Line__c` | `Supply_pool__c`, `Demand_pool__c` | `productListView` | `ShortageDTO` |
| `CAP-014` | When was the world market price history last updated? | `World_Market__c` | `Price_history_last_update__c` | None | `MarketUpdateDTO` |
| `CAP-015` | What are the world market discovered goods flags? | `World_Market__c`, `Market_Line__c` | `Good__c`, `Value__c` | `productListView` | `DiscoveredGoodSelector` |
| `CAP-016` | What is the last price history vector recorded for trade goods? | `Price_Snapshot__c` | `Price__c`, `Good__c` | `ProductSelector` | None |
| `CAP-017` | What is the actual sold domestic supply versus global market sales? | `Market_Line__c` | `Actual_sold__c`, `Supply_pool__c` | `CountryProductSummaryDTO` | `MarketSalesDTO` |
| `CAP-018` | What is the world market pool balance for strategic military goods? | `Market_Line__c` | `Supply_pool__c`, `Demand_pool__c` | `productListView` | `StrategicGoodsDTO` |

### 2.3 Economy Parameters Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-019` | What is the player monthly pop growth rate and active tag? | `PlayerMonthlyPopGrowth__c` | `Tag__c`, `Value__c` | None | `PopGrowthDTO` |
| `CAP-020` | What is the naval overseas penalty for each country? | `Overseas_Penalty__c` | `Tag__c`, `Value__c` | `CountrySummaryDTO` | `OverseasPenaltySelector` |
| `CAP-021` | What are the regiment and ship unit costs by country? | `Unit_Cost__c` | `Unit_type__c`, `Value__c` | None | `MilitaryCostDTO` |
| `CAP-022` | What is the national budget balance history across factions? | `BudgetBalance__c` | `Tag__c`, `Value__c` | `EconomyCalculationEngine` | `BudgetBalanceDTO` |
| `CAP-023` | What is the global popularity index of Fascist ideology? | `Fascist__c` | `Value__c` | None | `IdeologyTrendDTO` |
| `CAP-024` | What is the global popularity index of Socialist ideology? | `Socialist__c` | `Value__c` | None | `IdeologyTrendDTO` |
| `CAP-025` | What is the global popularity index of Communist ideology? | `Communist__c` | `Value__c` | None | `IdeologyTrendDTO` |
| `CAP-026` | What is the global popularity index of Anarcho-Liberal ideology? | `AnarchoLiberal__c` | `Value__c` | None | `IdeologyTrendDTO` |
| `CAP-027` | What is the goods vector line configuration for trade automation? | `Goods_Vector_Line__c` | `Good__c`, `Value__c` | None | `GoodsVectorDTO` |
| `CAP-028` | What is the overall financial stability score across world powers? | `BudgetBalance__c`, `Country_Save_State__c` | `Value__c`, `Tax_base__c` | `EconomyCalculationEngine` | `FinancialStabilityEngine` |

### 2.4 Province & POP Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-029` | What is the demographic breakdown (type, culture, religion) of each province? | `Pop__c`, `Province_Save_State__c` | `Pop_Type__c`, `Culture__c`, `Religion__c`, `Size__c` | None | `PopDemographicSelector` |
| `CAP-030` | What is the literacy, consciousness, and militancy level of each POP? | `Pop__c` | `Literacy__c`, `Con__c`, `Mil__c` | None | `PopDemographicDTO` |
| `CAP-031` | What are the life, everyday, and luxury need fulfillment ratios for POPs? | `Pop_Need__c` | `Need_Type__c`, `Value__c` | None | `PopNeedFulfillmentEngine` |
| `CAP-032` | Which provinces have active infrastructure or naval base constructions? | `Construction__c` | `Type__c`, `Progress__c` | `stateDashboard` | `ConstructionDTO` |
| `CAP-033` | What is the RGO production capacity and employment level per province? | `RGO__c`, `RGO_Employment__c` | `Output_Good__c`, `Employment__c` | `ProvinceSummaryDTO` | `RgoDetailSelector` |
| `CAP-034` | What is the cash stockpile held by individual POPs? | `Pop_Stockpile__c`, `Pop__c` | `Money__c`, `Bank__c` | None | `PopWealthDTO` |
| `CAP-035` | What is the total population count per country and province? | `Pop__c` | `Size__c` | `CountrySummaryDTO` | `PopAggregationEngine` |
| `CAP-036` | What is the employee distribution across factory job types in a state? | `Employee__c` | `Type__c`, `Count__c` | `factoryDashboard` | `EmploymentBreakdownDTO` |
| `CAP-037` | What is the Native American Minor population status in applicable provinces? | `Pop__c` | `Native_american_minor__c`, `Size__c` | None | `MinorityPopDTO` |
| `CAP-038` | What is the bank savings held by craftsmen and clerks in industrial centers? | `Pop__c` | `Bank__c`, `Pop_Type__c` | None | `IndustrialSavingsDTO` |
| `CAP-039` | Which provinces are undergoing railroad level upgrades? | `Railroad__c`, `Province_Save_State__c` | `Level__c` | `stateDashboard` | `InfrastructureSelector` |
| `CAP-040` | What is the life rating of each province affecting pop growth? | `Province_Save_State__c` | `Life_rating__c` | `ProvinceSummaryDTO` | None |
| `CAP-041` | What is the crime level and active crime flags in provinces? | `Province_Save_State__c` | `Crime__c` | None | `ProvinceCrimeDTO` |
| `CAP-042` | What is the core cultural claim status on each province? | `Province_Save_State__c` | `Cores__c` | None | `TerritorialCoreSelector` |

### 2.5 Country Political Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-043` | What is the ruling party, government type, and political reform level of each country? | `Country_Save_State__c`, `ActiveParty__c` | `Government__c`, `Ruling_party__c` | `countryDashboard` | `PoliticalDetailDTO` |
| `CAP-044` | What is the breakdown of Upper House ideological representation? | `UpperHouse__c` | `Ideology__c`, `Value__c` | None | `UpperHouseChartLWC` |
| `CAP-045` | What are the effective tax rates and revenue for Rich, Middle, and Poor strata? | `RichTax__c`, `MiddleTax__c`, `PoorTax__c`, `TaxEff__c` | `Tax_rate__c`, `Value__c` | `CountrySummaryDTO` | `TaxationDetailDTO` |
| `CAP-046` | Which technologies and active inventions have been unlocked by each nation? | `Technology__c`, `ActiveInvention__c`, `Invention__c` | `Name__c`, `Folder__c` | None | `TechTreeVisualizerLWC` |
| `CAP-047` | What political or social movements are active and what is their radicalism score? | `Movement__c` | `Name__c`, `Radicalism__c`, `Pops__c` | None | `MovementSelector` |
| `CAP-048` | Who are the national creditors and debt holders for each sovereign state? | `Creditor__c` | `Country_Save_State__c`, `Debt_amount__c` | None | `NationalDebtDTO` |
| `CAP-049` | What active national modifiers and flags are affecting a country? | `Modifier__c`, `Flag__c` | `Name__c`, `Expiry_date__c` | None | `ModifierSelector` |
| `CAP-050` | What are the active party policies on trade, economy, religion, and war? | `ActiveParty__c` | `Trade_policy__c`, `Economic_policy__c` | None | `PartyPolicyDTO` |
| `CAP-051` | When was the last election held and when is the next election due? | `Country_Save_State__c` | `Last_election__c` | `countryDashboard` | None |
| `CAP-052` | What is the social security and wage reform level in effect? | `Country_Save_State__c` | `Wage_reform__c`, `Work_hours__c` | `countryDashboard` | `SocialReformDTO` |
| `CAP-053` | What is the safety regulations and unemployment subsidies status? | `Country_Save_State__c` | `Safety_regulations__c`, `Unemployment_subsidies__c` | None | `ReformStatusDTO` |
| `CAP-054` | What technology toggles are enabled for specific research branches? | `Technology_Toggle__c` | `Name__c`, `Value__c` | None | `TechToggleSelector` |
| `CAP-055` | What custom variables are attached to a country save state? | `Variable__c` | `Name__c`, `Value__c` | None | `VariableSelector` |
| `CAP-056` | What government flags are active on a sovereign nation? | `GovernmentFlag__c` | `Name__c`, `Value__c` | None | `GovernmentFlagDTO` |
| `CAP-057` | What is the overall tax base calculation score for a country? | `Country_Save_State__c` | `Tax_base__c` | `CountrySummaryDTO` | None |
| `CAP-058` | What is the capital province ID of each country? | `Country_Save_State__c` | `Capital__c` | `countryDashboard` | None |

### 2.6 Military Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-059` | What is the army and navy order of battle (OOB) for every nation? | `Army__c`, `Navy__c`, `Regiment__c`, `Ship__c` | `Name__c`, `Location__c`, `Count__c` | None | `MilitaryOOBSelector` |
| `CAP-060` | What is the unit composition (infantry, cavalry, artillery, ironclads) of armies/navies? | `Regiment__c`, `Ship__c` | `Type__c`, `Strength__c` | None | `MilitaryCompositionDTO` |
| `CAP-061` | Who are the active generals/admirals, and what are their background traits? | `Leader__c` | `Name__c`, `Personality__c`, `Background__c` | None | `LeaderSelector` |
| `CAP-062` | What is the dig-in status, supply level, and movement path of marching armies? | `Army__c`, `Path__c` | `Dig_in_last_date__c`, `Supplies__c` | None | `ArmyMovementDTO` |
| `CAP-063` | What is the total standing brigade count vs mobilization potential? | `Army__c`, `Regiment__c` | `Count__c` | None | `MobilizationCalculator` |
| `CAP-064` | Which naval ships are damaged or under repair in naval bases? | `Ship__c` | `Strength__c`, `Location__c` | None | `NavalMaintenanceDTO` |
| `CAP-065` | What is the military access permissions matrix between countries? | `MilitaryAcces__c` | `Source_tag__c`, `Target_tag__c` | None | `MilitaryAccessSelector` |
| `CAP-066` | What is the base province assignment of armies and navies? | `Army__c`, `Navy__c` | `Base__c` | None | `BaseAssignmentDTO` |
| `CAP-067` | What is the movement target province of marching units? | `Army__c`, `Path__c` | `Target__c` | None | None |
| `CAP-068` | What is the experience and morale score of regiments? | `Regiment__c` | `Experience__c`, `Morale__c` | None | `UnitStatDTO` |
| `CAP-069` | What naval transport capacity is available in active fleets? | `Ship__c`, `Navy__c` | `Type__c`, `Count__c` | None | `NavalCapacityDTO` |
| `CAP-070` | What is the military leadership pool capacity and officer pop density? | `Leader__c`, `Pop__c` | `Leadership__c`, `Size__c` | None | `LeadershipPoolDTO` |

### 2.7 AI Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-071` | What is the AI personality type and strategic focus of non-player nations? | `Ai__c` | `Personality__c`, `Static__c` | None | `AiStrategySelector` |
| `CAP-072` | Which nations are targeted by AI for conquest, antagonism, or befriending? | `ConquerProv__c`, `Antagonize__c`, `Befriend__c`, `Threat__c` | `Tag__c`, `Value__c` | None | `AiDiplomaticFocusDTO` |
| `CAP-073` | Which countries does the AI consider rivals or protective targets? | `Rival__c`, `Protect__c` | `Tag__c`, `Value__c` | None | `AiRelationshipDTO` |
| `CAP-074` | Which provinces is the AI planning to construct military/industrial buildings in? | `BuildingProv__c` | `Province_id__c`, `Building_type__c` | None | `AiConstructionPlannerDTO` |
| `CAP-075` | What is the AI threat perception matrix between Great Powers? | `Threat__c` | `Source_tag__c`, `Target_tag__c`, `Threat_level__c` | None | `ThreatMatrixVisualizer` |
| `CAP-076` | What is the AI hard strategy settings (aggressive, peaceful)? | `AiHardStrategy__c` | `Setting__c`, `Value__c` | None | `AiHardStrategyDTO` |
| `CAP-077` | Is the AI logic initialized and consolidated for a given country? | `Ai__c` | `Initialized__c`, `Consolidate__c` | None | None |
| `CAP-078` | What is the active war target prioritized by AI commanders? | `WarWith__c`, `Ai__c` | `Tag__c` | None | `AiWarFocusDTO` |
| `CAP-079` | What building provincial queue is prioritized by AI state governors? | `BuildingProv__c` | `Building_type__c`, `Priority__c` | None | None |

### 2.8 Trade & Influence Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-080` | What is the influence level and sphere status of Great Powers in secondary nations? | `Influence__c` | `Great_power_tag__c`, `Influence_value__c`, `Status__c` | None | `SphereOfInfluenceSelector` |
| `CAP-081` | What is the total foreign investment made by Great Powers in foreign factories/railroads? | `ForeignInvestment__c` | `Investor_tag__c`, `Amount__c` | `countryDashboard` | `ForeignInvestmentDTO` |
| `CAP-082` | What is the domestic supply, sold supply, and domestic demand pool per country? | `DomesticSupplyPool__c`, `DomesticDemandPool__c`, `SoldSupplyPool__c` | `Good__c`, `Value__c` | `CountryProductSummaryDTO` | `NationalTradeBalanceDTO` |
| `CAP-083` | What national focus is currently set in each state by country leadership? | `NationalFocu__c` | `State_id__c`, `Focus_type__c` | None | `NationalFocusDTO` |
| `CAP-084` | What are the primary, secondary, and accepted cultures of each nation? | `Culture__c` | `Culture_name__c`, `Is_accepted__c` | None | `CultureBreakdownDTO` |
| `CAP-085` | What is the national budget breakdown across military, education, administration, and social expenses? | `Expense__c`, `Income__c` | `Category__c`, `Value__c` | `CountrySummaryDTO` | `NationalLedgerDTO` |
| `CAP-086` | What is the research progress and daily research point output of each country? | `Research__c` | `Points__c`, `Tech_id__c` | None | `ResearchTrackerDTO` |
| `CAP-087` | Which nations are flagged as 'Interesting Countries' by the player? | `InterestingCountrie__c` | `Tag__c` | None | `WatchlistSelector` |
| `CAP-088` | What is the maximum bought volume on domestic trade goods? | `MaxBought__c` | `Good__c`, `Value__c` | None | `MaxBoughtDTO` |
| `CAP-089` | What is the saved country supply stockpile for strategic raw materials? | `SavedCountrySupply__c` | `Good__c`, `Value__c` | `CountryProductSummaryDTO` | None |
| `CAP-090` | What is the actual sold domestic supply of luxury consumption goods? | `ActualSoldDomestic__c` | `Good__c`, `Value__c` | None | `DomesticSalesDTO` |
| `CAP-091` | What is the buy domestic priority setting for state factories? | `BuyDomestic__c` | `Good__c`, `Value__c` | `factoryDashboard` | None |

### 2.9 Diplomacy Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-092` | Which nations are in military alliances or non-aggression pacts? | `Alliance__c`, `Diplomacy__c` | `First_tag__c`, `Second_tag__c` | None | `DiplomaticNetworkSelector` |
| `CAP-093` | Which nations are puppet states, vassals, or substates of a master empire? | `Vassal__c`, `Substate__c` | `Master_tag__c`, `Vassal_tag__c` | None | `VassalHierarchyDTO` |
| `CAP-094` | Which nations hold active casus belli against each other and when do they expire? | `CasusBelli__c` | `Attacker_tag__c`, `Target_tag__c`, `Type__c`, `Expiry_date__c` | None | `CasusBelliSelector` |
| `CAP-095` | What is the diplomatic relation score (-200 to +200) between any pair of countries? | `Country_Country_Ref__c` | `Relation_score__c` | None | `RelationMatrixDTO` |
| `CAP-096` | What is the truce expiration date between countries that recently fought a war? | `Diplomacy__c`, `Country_Country_Ref__c` | `Truce_date__c` | None | `TruceTrackerDTO` |
| `CAP-097` | What is the diplomatic influence status (cordial, friendly, sphered) of Great Powers? | `Influence__c` | `Status__c`, `Level__c` | None | `InfluenceStatusDTO` |
| `CAP-098` | What active substate relations exist within non-sovereign regional entities? | `Substate__c` | `Master_tag__c`, `Substate_tag__c` | None | None |

### 2.10 War Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-099` | What active wars are ongoing, who are the leaders, and what is the current warscore? | `ActiveWar__c` | `Name__c`, `Original_attacker__c`, `Warscore__c` | None | `ActiveWarSelector` |
| `CAP-100` | What are the original and added war goals for each belligerent in an active conflict? | `WarGoal__c`, `OriginalWargoal__c` | `Type__c`, `Target_state__c`, `Actor_tag__c` | None | `WarGoalDTO` |
| `CAP-101` | Which nations are primary vs secondary attackers/defenders in ongoing wars? | `Attacker__c`, `Defender__c` | `Country_Save_State__c`, `Is_primary__c` | None | `WarParticipantDTO` |
| `CAP-102` | What is the cumulative military loss (infantry, artillery, cavalry) per side in a war? | `AccumulatedLosse__c` | `Attacker_losses__c`, `Defender_losses__c` | None | `WarCasualtyCalculator` |
| `CAP-103` | Where are active land/naval combats taking place, and what are the front/back lines? | `Combat__c`, `Front__c`, `Back__c` | `Location__c`, `Attacker_dice__c` | None | `ActiveCombatDTO` |
| `CAP-104` | Which fortresses or provinces are currently under military siege? | `SiegeCombat__c` | `Province_id__c`, `Progress__c` | None | `SiegeTrackerDTO` |
| `CAP-105` | What is the historical log of completed battles, casualties, and commanders? | `Battle__c`, `History__c` | `Battle_name__c`, `Attacker_losses__c` | None | `BattleHistoryTimelineLWC` |
| `CAP-106` | What was the outcome and peace treaty terms of concluded past wars? | `PreviousWar__c`, `War_History_Entry__c` | `Name__c`, `End_date__c`, `Winner__c` | None | `HistoricalWarLogDTO` |
| `CAP-107` | What is the war exhaustion score of belligerent nations? | `Country_Save_State__c` | `War_exhaustion__c` | `countryDashboard` | `WarExhaustionDTO` |
| `CAP-108` | What is the active combat dice rolls and leader modifier in combat? | `Combat__c` | `Attacker_dice__c`, `Defender_dice__c` | None | None |

### 2.11 Rebels / News / Region Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-109` | What rebel factions exist, what are their demands, and how many brigades are ready to rise? | `RebelFaction__c` | `Type__c`, `Name__c`, `Independence__c`, `Culture__c` | None | `RebelFactionSelector` |
| `CAP-110` | Which provinces are occupied by rebel forces or enemy military units? | `RebelFaction__c` | `Province_Save_State__c` | None | `ProvinceOccupationDTO` |
| `CAP-111` | What newspaper articles have been generated by the in-game News Collector? | `Article__c`, `NewsCollector__c` | `Headline__c`, `Date__c`, `Content__c` | None | `NewspaperReaderLWC` |
| `CAP-112` | Is there an active Great Power Crisis, who are the backers, and what is the tension level? | `CrisisManager__c` | `Crisis_location__c`, `Tension__c`, `Attacker_backer__c` | None | `CrisisManagerDTO` |
| `CAP-113` | What is the ranking of Great Powers and Secondary Powers (Prestige, Industry, Military)? | `GreatNation__c` | `Tag__c`, `Prestige_rank__c`, `Industry_rank__c`, `Military_rank__c` | `countryDashboard` | `GreatPowerRankingsDTO` |
| `CAP-114` | Which uncivilized/colonial regions are eligible for colonization and what is the colonial tension? | `Colony__c`, `Region__c` | `Region_name__c`, `Colonial_points__c` | None | `ColonialExpansionDTO` |
| `CAP-115` | What possible or illegal inventions are queued for discovery by country tech level? | `PossibleInvention__c`, `IllegalInvention__c` | `Invention_id__c`, `Chance__c` | None | `InventionDiscoveryDTO` |
| `CAP-116` | What news scope values are recorded for event triggers? | `NewsScope__c`, `News_Scope_Value__c` | `Value__c` | None | `NewsScopeDTO` |
| `CAP-117` | What outliner settings are configured for player tracking? | `Outliner__c` | `Setting__c` | None | None |
| `CAP-118` | What tag strings are associated with localized news scope headlines? | `Tag__c`, `String__c` | `Name__c`, `Value__c` | None | `NewsLocalizationDTO` |

### 2.12 Junctions & State Detail Domain
| Cap ID | User Question Answered | Source Objects | Source Fields | Existing Asset Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-119` | What save snapshots exist for each country in multi-save analysis? | `Save_Game_Country_Ref__c` | `Save_Game__c`, `Country_Save_State__c` | `multiSaveTrend` | `SaveCountryRefSelector` |
| `CAP-120` | What state buildings (factories, fortresses, naval bases, infrastructure) exist in a state? | `StateBuilding__c`, `State_Save_State__c` | `Building_type__c`, `Level__c` | `stateDashboard` | `StateBuildingDTO` |
| `CAP-121` | What is the profit history log for industrial factories in a state? | `ProfitHistoryEntry__c` | `Factory_id__c`, `Profit__c`, `Date__c` | `factoryDashboard` | `FactoryProfitHistoryDTO` |
| `CAP-122` | Which POP migration or promotion projects are active in a state? | `Popproject__c` | `Project_type__c`, `Target_pop__c` | None | `PopProjectSelector` |
| `CAP-123` | What input goods stockpiles are held by state factories? | `Stockpile__c`, `InputGood__c` | `Good__c`, `Amount__c` | `factoryDashboard` | `FactoryStockpileDTO` |
| `CAP-124` | What employment records link POP workers to specific state buildings? | `Employment__c` | `Pop_id__c`, `Building_id__c` | `factoryDashboard` | `FactoryEmploymentDTO` |
| `CAP-125` | What state-level building construction projects are queued? | `StateBuilding__c`, `Construction__c` | `Building_type__c`, `Progress__c` | `stateDashboard` | None |

---

## 3. Feature Mapping & Categorization (16 Features)

Capabilities are aggregated into **16 coherent features**:

| Feature ID | Feature Name | Covered Capabilities | Effort Tier | Value Tier | Risk Tier | Asset Reuse |
|---|---|---|---|---|---|---|
| `FEAT-01` | **Unified Save Game Header & Settings Bar** | `CAP-001`–`CAP-008` | **S** | **HIGH** | **LOW** | Extends `economyAnalysisHeader` & `AnalysisSummaryDTO`. |
| `FEAT-02` | **Global Commodity Market Visualizer** | `CAP-009`–`CAP-018` | **M** | **HIGH** | **LOW** | Extends `c-product-list-view` & `ProductSelector`. |
| `FEAT-03` | **Macro Economy & Parameter Ledger** | `CAP-019`–`CAP-028` | **S** | **MEDIUM** | **LOW** | Reuses `EconomyCalculationEngine` & `c-economic-charts-container`. |
| `FEAT-04` | **POP Demographics & Need Fulfillment Explorer** | `CAP-029`–`CAP-042` | **XL** | **HIGH** | **HIGH** | New `PopDemographicEngine`; reuses `EconomyImportBatch` chunking pattern due to LDV (100k+ rows). |
| `FEAT-05` | **Country Politics & Reform Dashboard** | `CAP-043`–`CAP-058` | **M** | **HIGH** | **LOW** | Extends `c-country-dashboard` & `CountrySelector`. |
| `FEAT-06` | **Military OOB & Unit Composition Explorer** | `CAP-059`–`CAP-070` | **M** | **HIGH** | **MEDIUM** | Uses `c-economic-charts-container` for composition pie/bar graphs. |
| `FEAT-07` | **AI Strategic Threat & Relationship Matrix** | `CAP-071`–`CAP-079` | **M** | **MEDIUM** | **LOW** | New matrix LWC layout. |
| `FEAT-08` | **Sphere of Influence & National Focus Tracker** | `CAP-080`–`CAP-091` | **M** | **HIGH** | **LOW** | Extends `c-country-dashboard`. |
| `FEAT-09` | **Diplomatic Network & Treaty Explorer** | `CAP-092`–`CAP-098` | **S** | **MEDIUM** | **LOW** | Reuses `CountrySelector`. |
| `FEAT-010` | **Active War & Military Conflict Monitor** | `CAP-099`–`CAP-108` | **L** | **HIGH** | **MEDIUM** | New `ActiveWarSelector` & conflict LWC view. |
| `FEAT-011` | **Battle History & War Loss Timeline** | `CAP-105`–`CAP-106` | **M** | **MEDIUM** | **LOW** | Extends `c-multi-save-trend`. |
| `FEAT-012` | **Rebel Insurgency & Occupation Monitor** | `CAP-109`–`CAP-110` | **S** | **HIGH** | **LOW** | Extends `c-country-dashboard`. |
| `FEAT-013` | **In-Game Newspaper Reader** | `CAP-111`, `CAP-116`–`CAP-118` | **S** | **LOW** | **LOW** | Simple news card LWC. |
| `FEAT-014` | **Great Power Crisis & Colonial Expansion Manager** | `CAP-112`–`CAP-115` | **M** | **HIGH** | **LOW** | Extends `c-global-economy-dashboard`. |
| `FEAT-015` | **Multi-Save Time Series Comparison Suite** | `CAP-119` | **M** | **HIGH** | **MEDIUM** | Extends `c-analysis-compare` & `c-multi-save-trend`. |
| `FEAT-016` | **State Industrial & Construction Inspector** | `CAP-120`–`CAP-125` | **M** | **MEDIUM** | **LOW** | Extends `c-state-dashboard` & `c-factory-dashboard`. |
