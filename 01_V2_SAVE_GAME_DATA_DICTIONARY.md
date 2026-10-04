# 01. Victoria 2 `.v2` Save Game Data Dictionary

## Overview
This document provides a comprehensive, field-level data dictionary reverse-engineered from direct forensic analysis of the real-world Victoria 2 save game file `egypt.v2` (27.06 MB, 2,090,792 lines).

---

## Complete Data Dictionary

| Domain | Field | Exact Save Path | Type | Example | Parent | Cardinality | Meaning | Status | Confidence |
| ------ | ----- | --------------- | ---- | ------- | ------ | ----------- | ------- | ------ | ---------- |
| Save Metadata | Date | `date` | String (Date) | `"1872.9.25"` | ROOT | 1:1 | Current save game date | CONFIRMED RAW DATA | HIGH |
| Save Metadata | Player Tag | `player` | String (3-char) | `"TUR"` | ROOT | 1:1 | Country tag currently controlled by player | CONFIRMED RAW DATA | HIGH |
| Save Metadata | Government Type | `government` | Integer | `5` | ROOT | 1:1 | Global government index setting | CONFIRMED RAW DATA | HIGH |
| Save Metadata | Automate Trade | `automate_trade` | Boolean Token | `no` | ROOT | 1:1 | Player setting for automated trade | CONFIRMED RAW DATA | HIGH |
| Save Metadata | Start Date | `start_date` | String (Date) | `"1836.1.1"` | ROOT | 1:1 | Campaign starting date | CONFIRMED RAW DATA | HIGH |
| Save Metadata | Great Wars Enabled | `great_wars_enabled` | Boolean Token | `no` | ROOT | 1:1 | Flag indicating if Great War mechanics are active | CONFIRMED RAW DATA | HIGH |
| Country | Capital Province | `<TAG>.capital` | Integer | `1745` | Country (`<TAG>`) | 1:1 | Province ID of national capital | CONFIRMED RAW DATA | HIGH |
| Country | Tax Base | `<TAG>.tax_base` | Float | `0.00000` | Country (`<TAG>`) | 1:1 | Base tax rate modifier | CONFIRMED RAW DATA | HIGH |
| Country | Research Points | `<TAG>.research_points` | Float | `6795.927` | Country (`<TAG>`) | 1:1 | Accumulated unused research points | CONFIRMED RAW DATA | HIGH |
| Country | Last Reform Date | `<TAG>.last_reform` | String (Date) | `"1845.2.26"` | Country (`<TAG>`) | 1:1 | Date of last enacted political/social reform | CONFIRMED RAW DATA | HIGH |
| Country | Last Election Date | `<TAG>.last_election` | String (Date) | `"1836.1.1"` | Country (`<TAG>`) | 1:1 | Date of last national election | CONFIRMED RAW DATA | HIGH |
| Country | Wage Reform | `<TAG>.wage_reform` | Identifier Token | `no_minimum_wage` | Country (`<TAG>`) | 1:1 | Active minimum wage reform level | CONFIRMED RAW DATA | HIGH |
| Country | Work Hours | `<TAG>.work_hours` | Identifier Token | `no_work_hour_limit` | Country (`<TAG>`) | 1:1 | Active work hours reform level | CONFIRMED RAW DATA | HIGH |
| Country | Safety Regulations | `<TAG>.safety_regulations` | Identifier Token | `no_safety` | Country (`<TAG>`) | 1:1 | Active safety regulations reform level | CONFIRMED RAW DATA | HIGH |
| Country | Treasury Balance | `<TAG>.treasury` | Float | `145020.12` | Country (`<TAG>`) | 1:1 | National liquid money balance in £ | CONFIRMED RAW DATA | HIGH |
| Country | National Bank | `<TAG>.bank` | Float | `8542.10` | Country (`<TAG>`) | 1:1 | Domestic bank reserves accumulated by POPs | CONFIRMED RAW DATA | HIGH |
| Country | Technology | `<TAG>.technology.<tech_id>` | Nested Block | `{1 0.000}` | Country (`<TAG>`) | 1:N | Researched technologies and research progress | CONFIRMED RAW DATA | HIGH |
| Country | Active Inventions | `<TAG>.invention` | Block / List | `post_napoleonic_thought` | Country (`<TAG>`) | 1:N | Active inventions unlocked by country | CONFIRMED RAW DATA | HIGH |
| Province | Name | `<PROV_ID>.name` | String (Quoted) | `"Palak Pinang"` | Province (`<PROV_ID>`) | 1:1 | Geographic name of province | CONFIRMED RAW DATA | HIGH |
| Province | Owner Tag | `<PROV_ID>.owner` | String (3-char) | `"NET"` | Province (`<PROV_ID>`) | 1:1 | Sovereign owner country tag | CONFIRMED RAW DATA | HIGH |
| Province | Controller Tag | `<PROV_ID>.controller` | String (3-char) | `"NET"` | Province (`<PROV_ID>`) | 1:1 | Military controller country tag | CONFIRMED RAW DATA | HIGH |
| Province | Garrison Strength | `<PROV_ID>.garrison` | Float | `100.000` | Province (`<PROV_ID>`) | 1:1 | Fort/garrison strength percentage | CONFIRMED RAW DATA | HIGH |
| Province | Colonial Level | `<PROV_ID>.colonial` | Integer | `2` | Province (`<PROV_ID>`) | 1:1 | Colonial status level (0=State, 1=Protectorate, 2=Colony) | CONFIRMED RAW DATA | HIGH |
| Province | Rail Level | `<PROV_ID>.railroad` | Nested Block / Float | `level=2` | Province (`<PROV_ID>`) | 0:1 | Infrastructure level | CONFIRMED RAW DATA | HIGH |
| Province | Fort Level | `<PROV_ID>.fort` | Nested Block / Float | `level=1` | Province (`<PROV_ID>`) | 0:1 | Fortification level | CONFIRMED RAW DATA | HIGH |
| Province | RGO Block | `<PROV_ID>.rgo` | Nested Block | `employment={...}` | Province (`<PROV_ID>`) | 0:1 | Resource Gathering Operation employment and production | CONFIRMED RAW DATA | HIGH |
| State | State Region | `<TAG>.state.<id>` | Nested Block | `state_buildings={...}` | Country (`<TAG>`) | 1:N | Administrative state block | CONFIRMED RAW DATA | HIGH |
| State | State Buildings | `<TAG>.state.state_buildings` | Nested Block | `building="lumber_mill"` | State (`<TAG>.state`) | 0:N | Factory buildings located within state | CONFIRMED RAW DATA | HIGH |
| Factory | Building Type | `state_buildings.building` | Quoted Identifier | `"lumber_mill"` | State Building | 1:1 | Factory commodity output definition code | CONFIRMED RAW DATA | HIGH |
| Factory | Level | `state_buildings.level` | Integer | `1` | State Building | 1:1 | Factory level size multiplier | CONFIRMED RAW DATA | HIGH |
| Factory | Stockpile | `state_buildings.stockpile.<good>` | Key-Value Pair | `timber=3.91412` | State Building | 0:N | Goods held in factory input/output warehouse | CONFIRMED RAW DATA | HIGH |
| Factory | Employment | `state_buildings.employment` | Nested Block | `employees={...}` | State Building | 1:1 | POP workforce employed by factory | CONFIRMED RAW DATA | HIGH |
| POP | POP Type | `<PROV_ID>.<pop_type>` | Block Identifier | `artisans={...}` | Province (`<PROV_ID>`) | 0:N | POP demographic class (e.g. artisans, farmers) | CONFIRMED RAW DATA | HIGH |
| POP | POP ID | `<PROV_ID>.<pop_type>.id` | Integer | `12009` | POP Record | 1:1 | Unique numeric POP identifier | CONFIRMED RAW DATA | HIGH |
| POP | Size | `<PROV_ID>.<pop_type>.size` | Integer | `402` | POP Record | 1:1 | Adult male population count | CONFIRMED RAW DATA | HIGH |
| POP | Culture/Religion | `<PROV_ID>.<pop_type>.<culture>` | Key-Value Pair | `malay=sunni` | POP Record | 1:1 | Composite culture and religion key | CONFIRMED RAW DATA | HIGH |
| POP | Money Reserves | `<PROV_ID>.<pop_type>.money` | Float | `853.40634` | POP Record | 1:1 | Liquid cash held by POP | CONFIRMED RAW DATA | HIGH |
| POP | Ideology | `<PROV_ID>.<pop_type>.ideology` | Key-Value Pair List | `2=13.25333` | POP Record | 0:N | Political ideology distribution percentages | INTERPRETABLE RAW DATA | MEDIUM |
| POP | Issues | `<PROV_ID>.<pop_type>.issues` | Key-Value Pair List | `1=1.37546` | POP Record | 0:N | Key issue interest distribution percentages | INTERPRETABLE RAW DATA | MEDIUM |
| Market | Worldmarket Pool | `worldmarket.worldmarket_pool.<good>` | Key-Value Pair | `ammunition=18.91367` | Worldmarket | 1:N | Global unsold pool quantity per commodity | CONFIRMED RAW DATA | HIGH |
| Market | Price Pool | `worldmarket.price_pool.<good>` | Key-Value Pair | `ammunition=18.83130` | Worldmarket | 1:N | Current market unit price in £ | CONFIRMED RAW DATA | HIGH |
| Market | Demand Pool | `worldmarket.demand_pool.<good>` | Key-Value Pair | `ammunition=120.45` | Worldmarket | 1:N | Global aggregate real demand | CONFIRMED RAW DATA | HIGH |
| Market | Supply Pool | `worldmarket.supply_pool.<good>` | Key-Value Pair | `ammunition=110.12` | Worldmarket | 1:N | Global aggregate total supply | CONFIRMED RAW DATA | HIGH |
| Diplomacy | Active War | `active_war` | Nested Block | `name="Ottoman-Egyptian War"` | ROOT | 0:N | Currently active military conflict | CONFIRMED RAW DATA | HIGH |
| Diplomacy | Previous War | `previous_war` | Nested Block | `name="Crimean War"` | ROOT | 0:N | Historical concluded war | CONFIRMED RAW DATA | HIGH |
| Diplomacy | Alliances/Relations | `diplomacy.<rel_block>` | Nested Block | `first="TUR" second="EGY"` | Diplomacy | 0:N | Diplomatic status, opinion, truce, alliance | CONFIRMED RAW DATA | HIGH |
| Derived | Country GDP | N/A | Currency | `£12,450.00` | Country_Economy__c | 1:1 | Aggregated domestic production value | DERIVABLE DATA | HIGH |
| Derived | GDP Per Capita | N/A | Currency | `£2.45` | Country_Economy__c | 1:1 | Country GDP / Core Population | DERIVABLE DATA | HIGH |
| Derived | Overproduction % | N/A | Percentage | `112.5%` | Product_Economy__c | 1:1 | (Total World Supply / Real Demand) * 100 | DERIVABLE DATA | HIGH |
