# Track D — Advanced Capability Expansion: Layers 2 & 3

## 1. Executive Summary

This document details **Layer 2 (Cross-Domain Analytics)** and **Layer 3 (Derived Intelligence)** capability extensions beyond Track C's present-tense display capabilities (`CAP-001` through `CAP-125`).

- **Layer 2**: 65 cross-domain capabilities (`CAP-D-001` to `CAP-D-065`) created by joining two or more save-game entity domains.
- **Layer 3**: 45 derived metrics, composite scores, forecasts, and anomaly indicators (`MET-D-001` to `MET-D-045`) computed from underlying raw data structures.

---

## 2. Layer 2 — Cross-Domain Analytics (65 Capabilities)

Layer 2 capabilities emerge strictly when data across two or more distinct save-game domains is intersected.

### 2.1 Economy × Politics (CAP-D-001 to CAP-D-005)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-001` | How does effective rich/middle tax rate impact national GDP growth rate between saves? | `RichTax__c`, `MiddleTax__c`, `Country_Save_State__c` | `Tax_rate__c`, `Money__c` | `CAP-045`, `CAP-119` | `TaxGdpImpactEngine` |
| `CAP-D-002` | Does enacting social/political reforms accelerate factory construction completion or industrial investment? | `Country_Save_State__c`, `StateBuilding__c` | `Wage_reform__c`, `Work_hours__c`, `Level__c`, `Money__c` | `CAP-043`, `CAP-120` | `ReformIndustrialEfficiencySelector` |
| `CAP-D-003` | How does ruling party economic policy (Laissez-Faire vs State Capitalism) correlate with factory profit margins? | `ActiveParty__c`, `StateBuilding__c` | `Economic_policy__c`, `Last_income__c`, `Pops_paychecks__c` | `CAP-050`, `CAP-121` | `PartyEconomicPolicyImpactDTO` |
| `CAP-D-004` | What is the tariff revenue sensitivity on domestic pop luxury need fulfillment? | `Country_Save_State__c`, `Pop_Need__c` | `Max_tariff__c`, `Tariffs__c`, `Value__c` | `CAP-031`, `CAP-045` | `TariffNeedElasticityCalculator` |
| `CAP-D-005` | Does high national debt to foreign creditors force political movement radicalization? | `Creditor__c`, `Movement__c` | `Debt__c`, `Radicalism__c`, `Support__c` | `CAP-047`, `CAP-048` | `DebtRadicalismAnalyzer` |

### 2.2 Economy × Military (CAP-D-006 to CAP-D-010)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-006` | What percentage of national treasury income is consumed by active army and navy maintenance costs? | `Income__c`, `Expense__c`, `Army__c`, `Navy__c` | `Value__c`, `Supplies__c` | `CAP-059`, `CAP-085` | `MilitaryBudgetRatioCalculator` |
| `CAP-D-007` | Can national treasury and credit lines sustain full mobilization for more than 12 months? | `Country_Save_State__c`, `Regiment__c`, `Expense__c` | `Money__c`, `Count__c`, `Value__c` | `CAP-063`, `CAP-085` | `MobilizationAffordabilityEngine` |
| `CAP-D-008` | How does naval ship construction compete with civilian state infrastructure for steel and clipper/steamer supply? | `StateBuilding__c`, `Ship__c`, `Market_Line__c` | `Building__c`, `Type__c`, `Supply_pool__c` | `CAP-010`, `CAP-059` | `MilitaryCivilianGoodCompetitionDTO` |
| `CAP-D-009` | What is the total factory capital lost due to provincial military occupations during war? | `Province_Save_State__c`, `StateBuilding__c`, `Army__c` | `Controller__c`, `Owner__c`, `Level__c` | `CAP-059`, `CAP-120` | `OccupationIndustrialDamageSelector` |
| `CAP-D-010` | What is the unit cost efficiency (military power points per pound spent) across global powers? | `Country_Save_State__c`, `Expense__c`, `Unit_Cost__c` | `Value__c`, `Prestige__c` | `CAP-021`, `CAP-085` | `MilitaryCostEfficiencyAnalyzer` |

### 2.3 Economy × POP (CAP-D-011 to CAP-D-015)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-011` | How does POP literacy rate drive craftsmen promotion rate and industrial factory output productivity? | `Pop__c`, `StateBuilding__c` | `Literacy__c`, `Promoted__c`, `Produces__c` | `CAP-030`, `CAP-120` | `LiteracyProductivityEngine` |
| `CAP-D-012` | What is the wealth inequality index (bank savings distribution) between Craftsmen/Clerks and Aristocrats/Capitalists? | `Pop__c` | `Pop_Type__c`, `Bank__c`, `Money__c` | `CAP-034`, `CAP-038` | `PopWealthInequalityCalculator` |
| `CAP-D-013` | Which RGO resource extractions generate sufficient pop cash reserves to transition labourers into artisans? | `RGO__c`, `Pop__c` | `Output_Good__c`, `Money__c`, `Promoted__c` | `CAP-033`, `CAP-034` | `RgoSocialMobilityDTO` |
| `CAP-D-014` | How does unemployment among industrial POPs affect total pop everyday need fulfillment? | `Employee__c`, `Pop_Need__c` | `Count__c`, `Value__c`, `Need_Type__c` | `CAP-031`, `CAP-036` | `UnemploymentDeprivationSelector` |
| `CAP-D-015` | Does artisan production of consumer goods decrease when state factory production of identical goods expands? | `Pop__c`, `StateBuilding__c` | `Current_producing__c`, `Produces__c` | `CAP-029`, `CAP-120` | `ArtisanFactoryCompetitionDTO` |

### 2.4 Economy × War (CAP-D-016 to CAP-D-020)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-016` | What is the total GDP decline percentage suffered by a nation during active war involvement? | `Country_Save_State__c`, `ActiveWar__c` | `Money__c`, `War_exhaustion__c`, `Name__c` | `CAP-099`, `CAP-107` | `WarGdpImpactCalculator` |
| `CAP-D-017` | How severely does naval blockade reduce domestic raw material export revenues? | `Country_Save_State__c`, `Market_Line__c`, `Navy__c` | `Overseas_penalty__c`, `Actual_sold__c`, `Location__c` | `CAP-010`, `CAP-020` | `BlockadeTradeImpactSelector` |
| `CAP-D-018` | How does war exhaustion growth rate scale with national debt accumulation and tax rate increases? | `Country_Save_State__c`, `RichTax__c`, `PoorTax__c` | `War_exhaustion__c`, `Current__c` | `CAP-045`, `CAP-107` | `WarExhaustionFiscalEngine` |
| `CAP-D-019` | What is the global price spike percentage for military goods (small arms, ammunition, artillery) during Great Wars? | `ActiveWar__c`, `Price_Snapshot__c` | `Name__c`, `Small_arms__c`, `Ammunition__c` | `CAP-009`, `CAP-099` | `WarGoodPriceSpikeDTO` |
| `CAP-D-020` | What is the total factory repair cost incurred after enemy military occupation of industrial states? | `StateBuilding__c`, `Province_Save_State__c` | `Level__c`, `Controller__c`, `Owner__c` | `CAP-104`, `CAP-120` | `PostWarReconstructionCostDTO` |

### 2.5 Economy × Diplomacy (CAP-D-021 to CAP-D-025)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-021` | What proportion of a sphered country's raw material supply is captured exclusively by its Great Power master? | `Influence__c`, `Market_Line__c`, `DomesticSupplyPool__c` | `Status__c`, `Supply_pool__c`, `Value__c` | `CAP-080`, `CAP-082` | `SphereMarketCaptureDTO` |
| `CAP-D-022` | How does foreign investment in state railroads increase Great Power influence accumulation rate? | `ForeignInvestment__c`, `Influence__c` | `Amount__c`, `Influence_value__c` | `CAP-080`, `CAP-081` | `InvestmentInfluenceMultiplierEngine` |
| `CAP-D-023` | What trade dependency score exists between two allied nations based on mutual import/export flows? | `Alliance__c`, `DomesticSupplyPool__c`, `DomesticDemandPool__c` | `First_tag__c`, `Second_tag__c`, `Value__c` | `CAP-082`, `CAP-092` | `AllianceTradeDependencySelector` |
| `CAP-D-024` | Does diplomatic isolation (zero alliances or trade treaties) correlate with negative national budget trends? | `Alliance__c`, `Income__c`, `Expense__c` | `First_tag__c`, `Value__c` | `CAP-085`, `CAP-092` | `DiplomaticIsolationBudgetAnalyzer` |
| `CAP-D-025` | How much tariff revenue is lost by entering into a Customs Union / Sphere of Influence? | `Influence__c`, `Country_Save_State__c` | `Status__c`, `Tariffs__c`, `Max_tariff__c` | `CAP-045`, `CAP-080` | `CustomsUnionTariffLossDTO` |

### 2.6 Economy × Colonial (CAP-D-026 to CAP-D-030)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-026` | What is the financial Return on Investment (RGO revenue vs naval maintenance) of colonial territory maintenance? | `Colony__c`, `RGO__c`, `Expense__c` | `Points__c`, `Last_income__c`, `Value__c` | `CAP-033`, `CAP-114` | `ColonialRoiCalculator` |
| `CAP-D-027` | How does colonial raw resource extraction (rubber, oil, tropical wood) feed home country manufacturing factory inputs? | `Province_Save_State__c`, `StateBuilding__c` | `Colonial__c`, `Input_goods__c` | `CAP-033`, `CAP-123` | `ColonialResourceSupplyChainDTO` |
| `CAP-D-028` | Does home country tax rate push craftsman/labourer POP migration into overseas colonial provinces? | `Country_Save_State__c`, `Province_Save_State__c`, `Pop__c` | `Tax_base__c`, `Colonial__c`, `Last_imigration__c` | `CAP-029`, `CAP-045` | `ColonialMigrationPushFactorEngine` |
| `CAP-D-029` | How many naval supply points and overseas maintenance cost pounds are consumed per colonial province owned? | `Country_Save_State__c`, `Colony__c`, `Expense__c` | `Overseas_penalty__c`, `Points__c`, `Value__c` | `CAP-020`, `CAP-114` | `ColonialNavalCostEfficiencyDTO` |
| `CAP-D-030` | Does colonial empire expansion increase domestic POP access to luxury tropical goods (coffee, tea, opium, rubber)? | `Colony__c`, `Pop_Need__c` | `Points__c`, `Need_Type__c`, `Value__c` | `CAP-031`, `CAP-114` | `ColonialLuxuryAccessDTO` |

### 2.7 POP × War (CAP-D-031 to CAP-D-035)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-031` | What is the military casualty rate impact on soldier POP size reduction across recruited home provinces? | `AccumulatedLosse__c`, `Pop__c` | `Attacker_losses__c`, `Size__c`, `Pop_Type__c` | `CAP-029`, `CAP-102` | `CasualtyPopDepletionSelector` |
| `CAP-D-032` | How rapidly does POP militancy rise in provinces under active enemy military occupation or siege? | `SiegeCombat__c`, `Pop__c` | `Progress__c`, `Mil__c`, `Location__c` | `CAP-030`, `CAP-104` | `OccupationMilitancyEngine` |
| `CAP-D-033` | Do prolonged high casualties cause a shift in POP ideology toward Pacifism or Socialism? | `Battle__c`, `Pop__c` | `Attacker_losses__c`, `Con__c`, `Mil__c` | `CAP-030`, `CAP-105` | `WarIdeologyShiftDTO` |
| `CAP-D-034` | What is the rebellion risk score of soldier POPs returning from a defeated or high-loss war? | `PreviousWar__c`, `Pop__c` | `Winner__c`, `Mil__c`, `Size__c` | `CAP-030`, `CAP-106` | `VeteranRebellionRiskCalculator` |
| `CAP-D-035` | How does war exhaustion impact POP luxury need fulfillment in blockaded urban provinces? | `Country_Save_State__c`, `Pop_Need__c` | `War_exhaustion__c`, `Need_Type__c`, `Value__c` | `CAP-031`, `CAP-107` | `BlockadePopDeprivationEngine` |

### 2.8 POP × Ideology (CAP-D-036 to CAP-D-040)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-036` | How does POP literacy level correlate with adoption rate of Socialist and Communist ideologies? | `Pop__c`, `Socialist__c`, `Communist__c` | `Literacy__c`, `Con__c`, `Value__c` | `CAP-024`, `CAP-030` | `LiteracyIdeologyCorrelationDTO` |
| `CAP-D-037` | Does high POP consciousness accelerate political reform demand when militancy is low? | `Pop__c`, `Movement__c` | `Con__c`, `Mil__c`, `Radicalism__c` | `CAP-030`, `CAP-047` | `ConsciousnessReformDemandSelector` |
| `CAP-D-038` | Which pop strata (rich, middle, poor) show the fastest rate of Fascist ideology growth during economic depression? | `Pop__c`, `Fascist__c` | `Pop_Type__c`, `Money__c`, `Value__c` | `CAP-023`, `CAP-030` | `StrataFascismGrowthAnalyzer` |
| `CAP-D-039` | How does religious diversity in non-core provinces affect POP militancy and nationalist movement support? | `Pop__c`, `Movement__c` | `Religion__c`, `Mil__c`, `Support__c` | `CAP-029`, `CAP-047` | `ReligiousMilitancySelector` |
| `CAP-D-040` | What is the ideology drift speed of officer and soldier POPs based on military pay expenditures? | `Pop__c`, `Expense__c` | `Pop_Type__c`, `Con__c`, `Value__c` | `CAP-030`, `CAP-085` | `MilitaryPayIdeologyDriftDTO` |

### 2.9 POP × Politics (CAP-D-041 to CAP-D-045)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-041` | How closely does Upper House political composition match aggregate pop ideology across voting strata? | `UpperHouse__c`, `Pop__c` | `Ideology__c`, `Value__c`, `Con__c` | `CAP-030`, `CAP-044` | `UpperHousePopAlignmentDTO` |
| `CAP-D-042` | Which specific POP movements (e.g. Enfranchisement, Workplace Safety) have sufficient radicalism to force a legislative vote? | `Movement__c`, `Country_Save_State__c` | `Radicalism__c`, `Support__c`, `Last_reform__c` | `CAP-047`, `CAP-052` | `MovementLegislativeForceEngine` |
| `CAP-D-043` | How does extending voting franchise rights alter ruling party reelection probability? | `Country_Save_State__c`, `Pop__c` | `Vote_franschise__c`, `Ruling_party__c` | `CAP-043`, `CAP-051` | `EnfranchisementElectoralShiftDTO` |
| `CAP-D-044` | Do press freedom reforms suppress POP militancy growth in multi-ethnic provinces? | `Country_Save_State__c`, `Pop__c` | `Press_rights__c`, `Culture__c`, `Mil__c` | `CAP-030`, `CAP-043` | `PressFreedomMilitancyImpactSelector` |
| `CAP-D-045` | What is the voting power index of Capitalist POPs under Wealth Voting vs Universal Suffrage? | `Pop__c`, `Country_Save_State__c` | `Pop_Type__c`, `Vote_franschise__c` | `CAP-029`, `CAP-043` | `VotingPowerIndexCalculator` |

### 2.10 Military × Diplomacy (CAP-D-046 to CAP-D-050)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-046` | Does granting military transit access precede military alliance formation between neighboring states? | `MilitaryAcces__c`, `Alliance__c` | `Source_tag__c`, `Target_tag__c`, `First_tag__c` | `CAP-065`, `CAP-092` | `MilitaryAccessAlliancePrecursorDTO` |
| `CAP-D-047` | What is the total brigade power gap between opposing diplomatic alliance coalitions? | `Alliance__c`, `Regiment__c` | `First_tag__c`, `Second_tag__c`, `Count__c` | `CAP-059`, `CAP-092` | `CoalitionBrigadePowerBalanceEngine` |
| `CAP-D-048` | Does high military power rank deter foreign nations from executing Casus Belli war declarations? | `Country_Save_State__c`, `CasusBelli__c` | `Prestige__c`, `Attacker_tag__c`, `Target_tag__c` | `CAP-094`, `CAP-113` | `MilitaryDeterrenceScoreCalculator` |
| `CAP-D-049` | What is the naval power projection score (ironclads/dreadnoughts) in foreign influence spheres? | `Navy__c`, `Ship__c`, `Influence__c` | `Type__c`, `Count__c`, `Influence_value__c` | `CAP-059`, `CAP-080` | `NavalPowerProjectionInfluenceEngine` |
| `CAP-D-050` | Does stationing land armies on a border province increase diplomatic tension or threat perception? | `Army__c`, `Threat__c` | `Location__c`, `Threat_level__c` | `CAP-059`, `CAP-075` | `BorderDeploymentThreatAnalyzer` |

### 2.11 Military × AI (CAP-D-051 to CAP-D-055)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-051` | Does an AI nation's personality type (Aggressive vs Defensive) dictate its army brigade composition (Infantry vs Artillery)? | `Ai__c`, `Regiment__c` | `Personality__c`, `Type__c`, `Count__c` | `CAP-060`, `CAP-071` | `AiPersonalityMilitaryCompositionDTO` |
| `CAP-D-052` | How closely does AI army path movement match its prioritized diplomatic antagonize target? | `Army__c`, `Path__c`, `Antagonize__c` | `Target__c`, `Tag__c`, `Value__c` | `CAP-062`, `CAP-072` | `AiArmyMovementTargetCorrelationEngine` |
| `CAP-D-053` | Does AI mobilize military reserve forces early when threat perception crosses 75%? | `Threat__c`, `Regiment__c`, `Country_Save_State__c` | `Threat_level__c`, `Mobilize__c` | `CAP-063`, `CAP-075` | `AiThreatMobilizationTriggerSelector` |
| `CAP-D-054` | Does AI naval construction prioritize transport ship capacity when colony expansion is set as strategic focus? | `Ship__c`, `Ai__c` | `Type__c`, `Static__c`, `Personality__c` | `CAP-069`, `CAP-071` | `AiNavalFocusAnalyzer` |
| `CAP-D-055` | What is the AI military recruitment response speed following significant battle loss casualties? | `Ai__c`, `AccumulatedLosse__c`, `Regiment__c` | `Personality__c`, `Attacker_losses__c` | `CAP-071`, `CAP-102` | `AiCasualtyRecruitmentResponseDTO` |

### 2.12 Diplomacy × War (CAP-D-056 to CAP-D-060)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-056` | How many alliance honors vs refusals occur when primary belligerents invoke defensive call-to-arms? | `Alliance__c`, `ActiveWar__c` | `First_tag__c`, `Original_defender__c` | `CAP-092`, `CAP-099` | `CallToArmsHonorRateEngine` |
| `CAP-D-057` | What is the total warscore penalty generated by unfulfilled original vs added war goals? | `WarGoal__c`, `ActiveWar__c` | `Score__c`, `Is_fulfilled__c`, `Warscore__c` | `CAP-099`, `CAP-100` | `WarGoalPenaltyCalculator` |
| `CAP-D-058` | How frequently do active Casus Belli expire without turning into formal war declarations? | `CasusBelli__c`, `PreviousWar__c` | `Expiry_date__c`, `Name__c`, `End_date__c` | `CAP-094`, `CAP-106` | `CasusBelliUtilizationRateDTO` |
| `CAP-D-059` | Does diplomatic truce expiration immediately trigger repeat war declarations between rival Great Powers? | `Diplomacy__c`, `ActiveWar__c` | `Truce_date__c`, `Original_attacker__c` | `CAP-096`, `CAP-099` | `TruceExpirationWarTriggerSelector` |
| `CAP-D-060` | What percentage of total war combatants enter as secondary coalition partners vs original attackers/defenders? | `Attacker__c`, `Defender__c`, `ActiveWar__c` | `Is_primary__c`, `Name__c` | `CAP-099`, `CAP-101` | `WarCoalitionExpansionRateDTO` |

### 2.13 Technology × Economy × Military (CAP-D-061 to CAP-D-062)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-061` | How does unlocks in Army/Naval technology trees increase unit supply cost and total military expenditure? | `Technology__c`, `Unit_Cost__c`, `Expense__c` | `Folder__c`, `Unit_type__c`, `Value__c` | `CAP-021`, `CAP-046` | `TechMilitaryCostMultiplierEngine` |
| `CAP-D-062` | What is the industrial factory output multiplier gained from unlocking Power, Metallurgy, and Chemistry tech lines? | `Technology__c`, `StateBuilding__c` | `Folder__c`, `Produces__c`, `Level__c` | `CAP-046`, `CAP-120` | `TechIndustrialOutputBonusDTO` |

### 2.14 Culture × Politics × War (CAP-D-063 to CAP-D-064)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-063` | How does non-accepted primary culture status drive provincial rebel uprising probability during foreign war? | `Culture__c`, `RebelFaction__c`, `ActiveWar__c` | `Is_accepted__c`, `Culture__c`, `Organization__c` | `CAP-084`, `CAP-109` | `CulturalWarRebellionRiskEngine` |
| `CAP-D-064` | What is the cultural homogenization rate (assimilation) in core vs conquered provinces after political reform? | `Pop__c`, `Country_Save_State__c` | `Culture__c`, `Size__c`, `Political_parties__c` | `CAP-029`, `CAP-043` | `CulturalAssimilationRateDTO` |

### 2.15 Influence × Colony × POP (CAP-D-065)
| Cap ID | Cross-Domain Question | Source Objects (≥2 domains) | Source Fields | Track C Overlap | New Asset Required |
|---|---|---|---|---|---|
| `CAP-D-065` | Does Great Power sphere dominance over a weak state suppress local pop colonial migration into adjacent frontier regions? | `Influence__c`, `Colony__c`, `Pop__c` | `Status__c`, `Points__c`, `Last_imigration__c` | `CAP-028`, `CAP-080` | `SphereColonialMigrationSuppressorDTO` |

---

## 3. Layer 3 — Derived Intelligence (45 Capabilities)

Layer 3 defines composite scores, synthetic indices, forward forecasts, and anomaly detectors computed via mathematical formulas over model entities.

### 3.1 Composite Indices (MET-D-001 to MET-D-008)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-001` | **Human Development Index (HDI)** | POP, Tech, Economy | $0.33 \times \frac{\text{Literacy}}{100} + 0.33 \times \ln(\text{GDP/cap}) + 0.34 \times \frac{\text{NeedFulfillment}}{100}$ | `Pop__c.Literacy__c`, `Money__c`, `Pop_Need__c.Value__c` | Overall nation advancement ranking | HIGH |
| `MET-D-002` | **Industrial Power Score (IPS)** | Economy, Tech | $\sum (\text{Factory Level} \times \text{Tech Multiplier} \times \text{Utilization \%})$ | `StateBuilding__c.Level__c`, `Technology__c`, `Produces__c` | True manufacturing capacity index | HIGH |
| `MET-D-003` | **Military Strength Composite (MSC)** | Military, Tech | $\sum (\text{Brigades} \times \text{Exp}) + \sum (\text{Ships} \times \text{Firepower}) \times \text{TechMod}$ | `Regiment__c.Count__c`, `Ship__c.Strength__c`, `Leader__c` | True combat power index | HIGH |
| `MET-D-004` | **Colonial Momentum Index (CMI)** | Colonial, Navy | $\frac{\text{Naval Base Level} \times \text{Colonial Points}}{\text{Colonial Tension} + 1.0}$ | `Colony__c.Points__c`, `StateBuilding__c.Level__c`, `Region__c` | Forecast colonial expansion winner | MEDIUM |
| `MET-D-005` | **Cultural Unity Score (CUS)** | Culture, POP | $\frac{\sum \text{Primary Culture POP Size}}{\text{Total Country POP Size}} \times 100.0$ | `Culture__c.Is_accepted__c`, `Pop__c.Size__c` | National cohesion & stability index | HIGH |
| `MET-D-006` | **National Stability Index (NSI)** | Politics, POP | $100.0 - (0.4 \times \text{Avg Mil} + 0.3 \times \text{Rebel Brigades} + 0.3 \times \text{Revanchism})$ | `Pop__c.Mil__c`, `RebelFaction__c`, `Country_Save_State__c` | Internal revolution risk indicator | HIGH |
| `MET-D-007` | **Great Power Score (GPS)** | Eco, Mil, Dip | $0.4 \times \text{Ind Rank} + 0.4 \times \text{Mil Rank} + 0.2 \times \text{Prestige}$ | `Country_Save_State__c.Prestige__c`, `GreatNation__c` | Overall global power standing | HIGH |
| `MET-D-008` | **Financial Health Rating (FHR)** | Economy | $\frac{\text{Treasury} + \text{Tax Revenue}}{\text{National Debt} + \text{Daily Expenses} + 1.0}$ | `Money__c`, `Creditor__c.Debt__c`, `Expense__c.Value__c` | Sovereign bankruptcy risk score | HIGH |

### 3.2 Comparative Scores (MET-D-009 to MET-D-014)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-009` | **GDP-per-Capita Benchmark** | Economy, POP | $\frac{\text{Total National GDP}}{\text{Core Population Count}}$ | `Country_Save_State__c.Money__c`, `Pop__c.Size__c` | Cross-country economic prosperity comparison | HIGH |
| `MET-D-010` | **Colonial Efficiency Ratio** | Colonial, Eco | $\frac{\text{Colonial RGO Revenue}}{\text{Naval Maintenance Expense}}$ | `RGO__c.Last_income__c`, `Expense__c.Value__c` | Overseas expansion profitability score | HIGH |
| `MET-D-011` | **Tax Efficiency vs Max Capacity** | Eco, Politics | $\frac{\text{Actual Tax Revenue Received}}{\text{Tax Rate} \times \text{Theoretical Tax Base}}$ | `RichTax__c.Tax_income__c`, `TaxEff__c.Value__c` | Administrative tax collection efficiency | MEDIUM |
| `MET-D-012` | **Military Intensity Ratio** | Mil, Economy | $\frac{\text{Total Military Expenses}}{\text{National GDP}}$ | `Expense__c.Value__c`, `Country_Save_State__c.Money__c` | Economic militarization percentage | HIGH |
| `MET-D-013` | **Influence-per-Diplomat Index** | Diplomacy | $\frac{\text{Total Sphere Influence Value}}{\text{Diplomatic Points Output}}$ | `Influence__c.BEL__c`, `Diplomatic_points__c` | Great Power diplomatic efficiency rating | MEDIUM |
| `MET-D-014` | **RGO Productivity Index** | Economy, POP | $\frac{\text{Actual RGO Output}}{\text{Maximum Employee Capacity}}$ | `RGO__c.Last_income__c`, `Employee__c.Count__c` | Provincial raw resource yield rating | HIGH |

### 3.3 Forecasts & Predictions (MET-D-015 to MET-D-021)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-015` | **Linear GDP Trend Forecast (1-Year)** | Eco, Multi-Save | $\text{GDP}_{t} + \frac{\text{GDP}_{t} - \text{GDP}_{t-1}}{\Delta \text{Days}} \times 365.0$ | `Save_Game_Country_Ref__c`, `Money__c` | Next-year national economic output prediction | HIGH |
| `MET-D-016` | **Rebellion Escalation Probability** | POP, Politics | $\frac{1.0}{1.0 + e^{-(\text{Mil} - 7.0) \times \text{Con}}}$ | `Pop__c.Mil__c`, `Pop__c.Con__c`, `Radicalism__c` | Predict imminent rebel uprising (30-day window) | MEDIUM |
| `MET-D-017` | **Great Power Crisis Escalation Score** | Diplomacy, War | $\frac{\text{Tension} \times (\text{Attacker Backer Power} + \text{Defender Backer Power})}{\text{Global Peace Index}}$ | `CrisisManager__c.Tension__c`, `GreatNation__c` | World War outbreak risk prediction | MEDIUM |
| `MET-D-018` | **War Outcome / Winner Predictor** | Mil, Economy | $\frac{\text{Coalition A Combat Strength} \times \text{Gold Reserve A}}{\text{Coalition B Combat Strength} \times \text{Gold Reserve B}}$ | `Regiment__c.Count__c`, `Money__c`, `ActiveWar__c` | Forecast active war winner percentage | MEDIUM |
| `MET-D-019` | **Sovereign Bankruptcy Risk Score** | Economy | $1.0 - \frac{\text{Daily Income}}{\text{Daily Debt Interest Payment}}$ | `Income__c.Value__c`, `Creditor__c.Interest__c` | Default prediction within 6 months | HIGH |
| `MET-D-020` | **Population Growth Projection (5-Year)** | POP, Economy | $\text{Pop}_{t} \times (1.0 + \text{GrowthRate} - \text{EmigrationRate})^{5}$ | `PlayerMonthlyPopGrowth__c`, `Pop__c.Size__c` | Demographic labor supply forecasting | HIGH |
| `MET-D-021` | **Technology Research Completion Date** | Tech, Economy | $\text{Current Date} + \frac{\text{Remaining Tech Points}}{\text{Daily Point Production}}$ | `Research__c.Points__c`, `Cost__c`, `Date__c` | Research timeline forecast | HIGH |

### 3.4 Network Metrics (MET-D-022 to MET-D-026)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-022` | **Diplomatic Centrality Index** | Diplomacy | $\frac{\text{Active Alliances} + \text{Royal Marriages}}{\text{Total Global Nations} - 1}$ | `Alliance__c.First_tag__c`, `Second_tag__c` | Hub country identification in alliance graph | HIGH |
| `MET-D-023` | **Sphere Density Metric** | Diplomacy | $\frac{\text{Sphered Nations Count}}{\text{Total Eligible Non-GP Nations}}$ | `Influence__c.Status__c`, `GreatNation__c` | Measuring hegemony concentration | HIGH |
| `MET-D-024` | **Trade Network Betweenness** | Economy, Trade | $\sum \frac{\sigma_{sd}(v)}{\sigma_{sd}}$ over all trade pathways | `DomesticSupplyPool__c`, `Market_Line__c` | Identify choke-point nations in global trade | LOW |
| `MET-D-025` | **Alliance Cluster Coefficient** | Diplomacy, War | $\frac{3 \times \text{Number of Triangles}}{\text{Number of Connected Triples}}$ | `Alliance__c.First_tag__c`, `Second_tag__c` | Measuring bloc stability in international system | MEDIUM |
| `MET-D-026` | **Casus Belli Target Centrality** | Diplomacy, War | $\sum \text{Active CBs targeting Country } X$ | `CasusBelli__c.Second_tag__c` | Identify internationally targeted nations | HIGH |

### 3.5 Anomaly Indicators (MET-D-027 to MET-D-031)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-027` | **Factory Productivity Outlier Flag** | Economy | $\frac{\text{Factory Profit} - \mu_{\text{Profit}}}{\sigma_{\text{Profit}}} > 2.0$ | `StateBuilding__c.Last_income__c` | Detect abnormally profitable or broken factory | HIGH |
| `MET-D-028` | **Tech Lag / Economic Mismatch** | Tech, Economy | $\text{GDP Rank} - \text{Tech Rank} > 15$ | `Country_Save_State__c.Money__c`, `Technology__c` | Identify wealthy nations with primitive military/industry | HIGH |
| `MET-D-029` | **Abnormal POP Demoted Spike** | POP, Economy | $\frac{\text{Demoted POPs}}{\text{Total POP Size}} > 0.05$ | `Pop__c.Demoted__c`, `Pop__c.Size__c` | Flag severe economic collapse / de-skilling | HIGH |
| `MET-D-030` | **Unusual Price Volatility Detector** | Market | $\frac{\text{Price}_{t} - \text{Price}_{t-1}}{\text{Price}_{t-1}} > 0.50$ | `Price_Snapshot__c.Ammunition__c` | Flag wartime market shocks or commodity shortages | HIGH |
| `MET-D-031` | **Rebel Militancy Surge Alert** | POP, Politics | $\Delta \text{Mil} > 2.0 \text{ over single snapshot}$ | `Pop__c.Mil__c` | Trigger instant alert for rapid radicalization | HIGH |

### 3.6 Efficiency Metrics (MET-D-032 to MET-D-036)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-032` | **Factory Capacity Utilization Rate** | Economy | $\frac{\text{Employees Working}}{\text{Factory Level} \times 10,000} \times 100.0$ | `Employee__c.Count__c`, `StateBuilding__c.Level__c` | Factory labor efficiency measurement | HIGH |
| `MET-D-033` | **RGO Output Yield Efficiency** | Economy | $\frac{\text{Actual Production}}{\text{Theoretical Max Output}}$ | `RGO__c.Last_income__c`, `Province_Save_State__c` | Agriculture/Mining efficiency score | HIGH |
| `MET-D-034` | **Tax Collection Efficiency Score** | Eco, Politics | $\frac{\text{Collected Tax Revenue}}{\text{Theoretical Tax Base}}$ | `RichTax__c.Tax_income__c`, `Country_Save_State__c` | Fiscal administration performance | HIGH |
| `MET-D-035` | **War-Cost Per Enemy Brigade Loss** | Mil, War | $\frac{\text{Total War Expenditures}}{\text{Enemy Brigades Destroyed}}$ | `Expense__c.Value__c`, `AccumulatedLosse__c` | Combat cost efficiency measurement | MEDIUM |
| `MET-D-036` | **Colonial ROI Ratio** | Colonial, Eco | $\frac{\text{Colonial RGO Revenue}}{\text{Naval Base Maintenance}}$ | `RGO__c.Last_income__c`, `Expense__c.Value__c` | Overseas territory profitability | HIGH |

### 3.7 Narrative Generators (MET-D-037 to MET-D-040)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-037` | **Decade History Chapter Summary** | All | Rule-based generation from major events, wars, and GDP shifts | `ActiveWar__c`, `PreviousWar__c`, `Save_Game__c` | Auto-generate campaign history narrative | HIGH |
| `MET-D-038` | **Industrial Revolution Milestone Detector** | Eco, Tech | First date when Factory Output > RGO Output | `StateBuilding__c.Produces__c`, `RGO__c.Last_income__c` | Mark nation transition to Industrial Power | HIGH |
| `MET-D-039` | **Empire Peak Turning-Point Detector** | Multi-Domain | Date of max territory / prestige before permanent decline | `Country_Save_State__c.Prestige__c`, `Date__c` | Identify golden age peak date | HIGH |
| `MET-D-040` | **Great War Narrative Summary** | War, Mil | Aggregated losses, participant timeline, peace treaty terms | `PreviousWar__c.History__c`, `Battle__c` | Summarize concluded global conflicts | HIGH |

### 3.8 Risk Scores (MET-D-041 to MET-D-045)
| Metric ID | Metric Name | Domain(s) | Formula Sketch | Source Fields | Use Case | Confidence |
|---|---|---|---|---|---|---|
| `MET-D-041` | **National Rebellion Risk Index** | POP, Politics | $0.5 \times \text{Avg Mil} + 0.3 \times \text{Movement Radicalism} + 0.2 \times \text{Unemployment}$ | `Pop__c.Mil__c`, `Movement__c.Radicalism__c` | Civil war risk evaluation | HIGH |
| `MET-D-042` | **Sovereign Insolvency / Bankruptcy Risk** | Economy | $\frac{\text{Total Sovereign Debt}}{\text{Annual Budget Surplus} + 1.0}$ | `Creditor__c.Debt__c`, `BudgetBalance__c` | Debt default risk score | HIGH |
| `MET-D-043` | **Diplomatic Isolation Vulnerability** | Diplomacy, War | $1.0 - \frac{\text{Allied Power Strength}}{\text{Rival Power Strength}}$ | `Alliance__c`, `Regiment__c`, `Rival__c` | External invasion risk evaluation | HIGH |
| `MET-D-044` | **Strategic Military Resource Vulnerability** | Eco, Mil | $\frac{\text{Imported Military Goods Demand}}{\text{Total Military Goods Consumption}}$ | `Trade_Good__c`, `Market_Line__c` | Strategic blockade vulnerability score | HIGH |
| `MET-D-045` | **Refugee & Emigration Pressure Index** | POP, Eco | $\frac{\text{Unemployed POPs} \times \text{Militancy}}{\text{Average Need Fulfillment}}$ | `Pop__c.Mil__c`, `Employee__c.Count__c`, `Pop_Need__c` | Mass emigration / exile risk indicator | HIGH |
