# 03. Victoria 2 Save Game Extraction Feasibility Matrix

## Overview
This matrix evaluates the feasibility of extracting data directly from `.v2` save files without external files, categorized by domain and parsing complexity.

---

## Feasibility Matrix

| Domain | Exists in Save | Directly Extractable | Requires Parsing | Requires External Files | Derivable | Confidence | Architectural Notes |
| ------ | -------------: | -------------------: | ---------------: | ----------------------: | --------: | ---------- | ------------------- |
| Save Header Metadata | YES | YES | NO | NO | NO | HIGH | Single regex or top-level string match. |
| Country Treasury & Bank | YES | YES | YES | NO | NO | HIGH | Direct scalar key-value extraction under `<TAG>`. |
| Country Techs & Inventions | YES | YES | YES | YES | NO | HIGH | Tech codes in save; human-readable labels require `localisation/`. |
| Province Owner & Controller | YES | YES | YES | NO | NO | HIGH | Simple string match in numeric province blocks. |
| Province POP Demographic Counts | YES | YES | YES | NO | YES | HIGH | Total province population equals sum of POP `size` values * 4. |
| POP Ideology & Issue Numbers | YES | YES | YES | YES | NO | MEDIUM | Numeric IDs in save (e.g. `1=13.2`); require `common/ideologies.txt` for names. |
| Factory Types & Employment | YES | YES | YES | NO | NO | HIGH | Extractable from `state_buildings`. |
| Factory Inputs & Output Values | YES | PARTIAL | YES | YES | YES | HIGH | Factory type defined in save, base prices in `worldmarket`, input recipes require `production_types.txt`. |
| Artisan POP Income & Spending | YES | YES | YES | NO | YES | HIGH | Extracted from artisan POP cash pools and market prices. |
| RGO Production & Workforce | YES | YES | YES | NO | YES | HIGH | RGO workforce in province; output calculated via province production. |
| Commodity Market Prices | YES | YES | YES | NO | NO | HIGH | Extracted directly from `worldmarket.price_pool`. |
| Commodity World Supply & Demand | YES | YES | YES | NO | NO | HIGH | Direct extraction from `supply_pool` and `demand_pool`. |
| Country Trade Volumes (Imports/Exports) | YES | NO | YES | NO | YES | HIGH | Country trade values derived using market prices and country-commodity market consumption. |
| Country GDP | NO | NO | YES | NO | YES | HIGH | Pure derived calculation: sum of Factory GDP + RGO GDP + Artisan GDP. |
| Diplomatic Alliances & Truces | YES | YES | YES | NO | NO | HIGH | Extracted from `diplomacy` block. |
| Active Wars & War Goals | YES | YES | YES | NO | NO | HIGH | Extracted from `active_war` blocks. |
