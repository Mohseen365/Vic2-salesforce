# Track B Data Model Reconciliation Decisions & Architecture

## Executive Summary
Track B expands the Salesforce data model from the 12-object frozen economy model to represent the **full 126-object Clausewitz save-game structure** described in `salesforce_model_compact.txt`. This expansion is executed while strictly maintaining the **bit-for-bit integrity of the 13 protected economy artifacts** (12 Custom Objects + 1 Platform Event).

## Key Reconciliation Decisions

### 1. Protection of the Frozen Economy Model
The 13 economy artifacts are frozen and protected:
- `Economy_Analysis__c`, `Country_Economy__c`, `Product_Economy__c`, `Country_Product_Economy__c`, `State_Economy__c`, `Province_Economy__c`, `Factory_Economy__c`, `Artisan_Economy__c`, `Economy_Import_Event__e`
- Master Objects: `Country__c`, `Product__c`, `State__c`, `Province__c`

**Baseline SHA-256 Hash of 13 Protected Metadata Folders:** `dd00e83a599db3e4d2028b6166b769a9faccc0e4f41a23fca16283d8f13d7c1b`

### 2. Resolution of Structural Problems

#### A. The 271-Lookup Problem on `Save_Game__c` and 116-Lookup Problem on `Country__c`
- **Problem:** `Save_Game__c` in the compact file declares 271 lookup fields to `Country__c` (one per tag like `ENG__c`, `FRA__c`, etc.). `Country__c` declares 116 lookups to other countries. Salesforce enforces a hard limit of **40 lookup relationships per object**.
- **Resolution:**
  1. Implemented `Save_Game_Country_Ref__c` junction object with Master-Detail to `Save_Game__c`, Lookup to `Country__c`, `Reference_Key__c` (Text), and `Reference_Kind__c` (Picklist).
  2. Implemented `Country_Country_Ref__c` junction object with Master-Detail to `Country_Save_State__c`, Lookup to `Country__c`, `Target_Country_Tag__c` (Text), and `Relationship_Type__c` (Picklist).

#### B. The `Country__c`, `Province__c`, and `State__c` Naming Collisions
- **Problem:** `Country__c`, `Province__c`, and `State__c` exist as global master objects in the protected economy model, whereas in the compact model they represent per-save-game state.
- **Resolution:**
  1. Kept the protected global master objects `Country__c`, `Province__c`, and `State__c` untouched.
  2. Renamed save-scoped state entities in Track B to `Country_Save_State__c`, `Province_Save_State__c`, and `State_Save_State__c`.
  3. Linked `Country_Save_State__c` and `Province_Save_State__c` to master `Country__c` and `Province__c` via Lookups.

#### C. Duplicate Object Names & Generic Naming Collisions
- **Problem:** `Value__c` under `NewsScope__c` collides with generic field/object names. `Ideology__c` and `Issue__c` appear as sub-objects under `Pop__c`.
- **Resolution:**
  1. Renamed `Value__c` to `News_Scope_Value__c`.
  2. Flattened `Ideology__c` and `Issue__c` as fields on `Pop__c` (`Ideology_Key__c`, `Ideology_Value__c`, `Issue_Key__c`, `Issue_Value__c`).
  3. Single `Employee__c` object created serving both RGO and Factory employment contexts via `Context__c` picklist.

#### D. Field Count & Governor Limits Verification
- `Save_Game__c`: ~31 custom fields (within 800 limit; ≤40 lookups via junction ref).
- `Country_Save_State__c`: ~124 custom fields (within 800 limit; ≤40 lookups via junction ref).
- `NationalFocu__c`: ~142 custom fields (within 800 limit).
- `Technology_Toggle__c`: Junction pattern for technology toggles.

## Summary Matrix of Reconciled Objects
- **Protected Economy Objects (13):** `Country__c`, `Product__c`, `State__c`, `Province__c`, `Economy_Analysis__c`, `Country_Economy__c`, `Product_Economy__c`, `Country_Product_Economy__c`, `State_Economy__c`, `Province_Economy__c`, `Factory_Economy__c`, `Artisan_Economy__c`, `Economy_Import_Event__e`
- **Renamed Objects (4):** `Country_Save_State__c`, `Province_Save_State__c`, `State_Save_State__c`, `News_Scope_Value__c`
- **Flattened/Dropped (2):** `Ideology__c`, `Issue__c` (flattened into `Pop__c`)
- **New Junction Objects Added (2):** `Save_Game_Country_Ref__c`, `Country_Country_Ref__c`
- **New Custom Objects Created:** 121 non-protected custom objects.
