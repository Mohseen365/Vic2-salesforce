# 04. Victoria 2 Data Coverage Matrix

## Overview
This document compares what `egypt.v2` contains, what is extractable, what the current Salesforce application consumes, and what target Salesforce objects should cover.

---

## Data Coverage Matrix

| Domain | `.v2` Contains | Extractable | Semantics Known | External Dependency | Current Project Uses | Should Persist | Should Derive | Salesforce Target Object | Priority |
| ------ | -------------: | ----------: | --------------: | ------------------: | -------------------: | -------------: | ------------: | ----------------------- | -------- |
| Save Header | YES | YES | YES | NO | YES | YES | NO | `Economy_Analysis__c` | P0 (Critical) |
| Country Economic Snapshot | YES | YES | YES | NO | YES | YES | YES | `Country_Economy__c` | P0 (Critical) |
| Commodity Market Snapshot | YES | YES | YES | NO | YES | YES | YES | `Product_Economy__c` | P0 (Critical) |
| Country-Product Trade | YES | YES | YES | NO | YES | YES | YES | `Country_Product_Economy__c` | P0 (Critical) |
| Province Economic Snapshot | YES | YES | YES | NO | YES | YES | YES | `Province_Economy__c` | P1 (High) |
| State Economic Snapshot | YES | YES | YES | NO | YES | YES | YES | `State_Economy__c` | P1 (High) |
| Factory Economy Snapshot | YES | YES | YES | YES | YES | YES | YES | `Factory_Economy__c` | P1 (High) |
| Artisan Economy Snapshot | YES | YES | YES | NO | YES | YES | YES | `Artisan_Economy__c` | P1 (High) |
| Full POP Demographics (46K records) | YES | YES | YES | YES | NO | NO | YES | Transient JSON / Off-heap | P2 (Medium) |
| Diplomatic Relationships | YES | YES | YES | NO | NO | NO (Future) | NO | `Diplomacy_Snapshot__c` (Phase 10+) | P3 (Low) |
| Active & Historical Wars | YES | YES | YES | NO | NO | NO (Future) | NO | `War_Snapshot__c` (Phase 10+) | P3 (Low) |
| Technology & Research Progress | YES | YES | YES | YES | NO | NO (Future) | NO | `Country_Tech_Snapshot__c` (Phase 10+) | P3 (Low) |
| Political Reforms & Parties | YES | YES | PARTIAL | YES | NO | NO | NO | Raw JSON File | P3 (Low) |
