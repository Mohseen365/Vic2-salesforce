# Architecture Review Gates Resolution — Save_Game_Analyzer Migration (Phase 0 Extension)

This document records the formal resolutions for the four open architecture-review gates established for extending the Salesforce Victoria 2 Economy Analyzer with microeconomic capabilities from `Save_Game_Analyzer`.

---

## Gate 1: Artisan Granularity Strategy (Province × Product Aggregation)

### Decision
Aggregate artisan spending, income, AGDP, and physical production quantity by `(Province, Product)` per snapshot (`Artisan_Economy__c`) rather than storing 10,000+ individual pop records.

### Context & Rationale
- In Clausewitz `.v2` save files, individual artisan pops are stored per province, producing ~10,000+ pop records per save game.
- Storing individual pop rows consumes excessive Salesforce custom object storage (10,000+ records per import snapshot) and risks hitting Apex governor heap limits during DTO deserialization.
- `Artisans.py` and `Country.py` aggregate artisan output by province and product type (`artisan_type`). Aggregating at the `(Province, Product)` junction level preserves **100% of economic output, spending, income, and AGDP calculations** while reducing record volume by ~60% (4,406 records in `egypt.v2`).

### Schema Impact
- Snapshot object: `Artisan_Economy__c`
- Composite Key: `<AnalysisId>_<ProvinceId>_<ProductCode>`

---

## Gate 2: Deterministic Factory Occurrence Key Strategy

### Decision
Construct unique external snapshot key as `<AnalysisId>_<StateCode>_<BuildingType>_<OccurrenceIndex>`.

### Context & Rationale
- Victoria 2 state building blocks (`state_buildings=`) are grouped under states.
- Certain save files (especially modded games or queued expansions) can contain multiple instances of the same factory building type within the same state.
- Adding `<OccurrenceIndex>` (0-indexed sequence count per state and building type) guarantees unique external IDs, preventing silent record overwrites during DTO ingestion and `Database.upsert`.

### Schema Impact
- Snapshot object: `Factory_Economy__c`
- External Key: `Unique_Snapshot_Key__c` = `<AnalysisId>_<StateCode>_<BuildingType>_<OccurrenceIndex>`

---

## Gate 3: Master Data Auto-Provisioning Guard

### Decision
Execute bulk `Database.upsert` on master data entities (`Country__c`, `Product__c`, `Province__c`, `State__c`) prior to snapshot record insertion during REST import processing.

### Context & Rationale
- Save games created with custom mods or scenario edits may contain state names, province IDs, or commodity types not present in static seed files.
- Hardcoding master data assumptions leads to `System.QueryException` or `INACTIVE_OWNER` import failures.
- Ingestion services (`EconomyImportService`) will dynamically inspect incoming payload master identifiers, construct missing master records, and upsert them before creating snapshot detail records.

### Schema Impact
- Auto-provisions master `State__c` (`State_Code__c`) and `Province__c` (`External_Province_Id__c`).

---

## Gate 4: Unpivoting Logic for `Country.csv` Export

### Decision
Implement client-side (`c/economicExportUtils`) and server-side (`EconomyAnalysisController`) unpivoting logic to format `Country_Product_Economy__c` junctions into flat 49-good CSV rows matching Python `Country.csv`.

### Context & Rationale
- In Salesforce, commodity outputs are stored as normalized junction records (`Country_Product_Economy__c`).
- Python `Country.csv` outputs a wide flat table containing 49 commodity production columns (`ammunition`, `small_arms`, ..., `radio`).
- Rather than denormalizing the database schema, export utilities will dynamically unpivot normalized junctions during CSV generation, preserving 3NF relational storage in Apex while guaranteeing 100% legacy CSV format compatibility.

### Schema Impact
- No schema denormalization required. Unpivoting handled dynamically in export utility facade.
