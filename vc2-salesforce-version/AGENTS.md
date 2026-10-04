# AGENTS.md — Victoria 2 Economy Analyzer (Salesforce Version)

## Project Overview & Current Status

- **Current Status:** **Phase 8 Complete — Selectors & Controller Facade Live.**
- **Phase 8 Report Pointer:** [`phase-8-completion-report.md`](./phase-8-completion-report.md)
- **Phase 7 Report Pointer:** [`IDEMPOTENCY_REPORT.md`](./IDEMPOTENCY_REPORT.md)
- **Evidence Directory:** [`golden-dataset/save-game-analyzer/verification/phase-7-idempotency-evidence/`](./golden-dataset/save-game-analyzer/verification/phase-7-idempotency-evidence/)
- **Import Contract Specification:** [`IMPORT_CONTRACT.md`](./IMPORT_CONTRACT.md)
- **Field Inventory Reference:** [`field-inventory.md`](./field-inventory.md)
- **Semantic Contract Reference:** [`SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md`](./SAVE_GAME_ANALYZER_SEMANTIC_CONTRACT.md)
- **Audit Reference:** [`SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`](./SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md)
- **Golden Dataset Location:** `golden-dataset/` & `golden-dataset/save-game-analyzer/`
- **Golden Manifest Pointer:** [`golden-dataset/manifest.json`](./golden-dataset/manifest.json)
- **Source Save Game:** `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`)
- **Parity Verification Status:** `PASS` (0 discrepancies across all entity scopes)

---

## Phase 8 Selector & Controller API Surface

### Selectors (`EconomyAnalysisSelector.cls`)
- `selectById(Id analysisId)` → `Economy_Analysis__c`
- `selectAllRecent(Integer limitCount)` → `List<Economy_Analysis__c>`
- `selectCountryEconomies(Id analysisId)` → `List<Country_Economy__c>`
- `selectProductEconomies(Id analysisId)` → `List<Product_Economy__c>`
- `selectCountryProductEconomies(Id countryEconomyId)` → `List<Country_Product_Economy__c>`
- `selectCountryProductEconomiesByAnalysis(Id analysisId)` → `List<Country_Product_Economy__c>`
- `selectCountryProductEconomiesByProduct(Id productEconomyId)` → `List<Country_Product_Economy__c>` **(re-introduced)**
- `selectProvinceEconomies(Id countryEconomyId)` → `List<Province_Economy__c>`
- `selectStateEconomies(Id analysisId)` → `List<State_Economy__c>` **(Phase 8)**
- `selectFactoryEconomies(Id stateEconomyId)` → `List<Factory_Economy__c>` **(Phase 8)**
- `selectArtisanEconomies(Id provinceEconomyId)` → `List<Artisan_Economy__c>` **(Phase 8)**

### Controller Facade (`EconomyAnalysisController.cls`)
- `@AuraEnabled(cacheable=true) getRecentAnalyses(limitCount)`
- `@AuraEnabled(cacheable=true) getAnalysisSummary(analysisId)`
- `@AuraEnabled(cacheable=true) getCountrySummaries(analysisId)`
- `@AuraEnabled(cacheable=true) getCountrySummary(analysisId, countryEconomyId)`
- `@AuraEnabled(cacheable=true) getCountryProductSummaries(countryEconomyId)`
- `@AuraEnabled(cacheable=true) getProductSummaries(analysisId)` **(re-introduced)**
- `@AuraEnabled(cacheable=true) getProductSummary(analysisId, productEconomyId)` **(re-introduced)**
- `@AuraEnabled(cacheable=true) getCountryProductSummariesByProduct(productEconomyId)` **(re-introduced)**
- `@AuraEnabled(cacheable=true) getStateSummaries(analysisId)` **(Phase 8)**
- `@AuraEnabled(cacheable=true) getFactorySummaries(stateEconomyId)` **(Phase 8)**
- `@AuraEnabled(cacheable=true) getArtisanSummaries(provinceEconomyId)` **(Phase 8)**
- `@AuraEnabled(cacheable=true) compareAnalyses(baseAnalysisId, compareAnalysisId)`
- `@AuraEnabled exportCsv(analysisId, scope)`

### DTO Inventory
1. `AnalysisSummaryDTO.cls` (12 fields)
2. `CountrySummaryDTO.cls` (22 fields)
3. `ProductSummaryDTO.cls` (10 fields)
4. `CountryProductSummaryDTO.cls` (19 fields — includes `countryTag`, `countryName`)
5. `StateSummaryDTO.cls` (15 fields)
6. `FactorySummaryDTO.cls` (17 fields)
7. `ArtisanSummaryDTO.cls` (11 fields)
8. `AnalysisComparisonDTO.cls`

### Security Pattern
- `with sharing` enforced on all selector, service, and controller classes.
- `Schema.sObjectType.<Object>.isAccessible()` checked before every SOQL query.
- `Security.stripInaccessible(AccessType.READABLE, ...)` applied to all selector return values.
- Zero SOQL in `EconomyAnalysisController.cls` (100% delegation to service/selector).

### Re-Introduction Log (PATTERN I)
- `EconomyAnalysisController.getProductSummaries`, `getProductSummary`, `getCountryProductSummariesByProduct` re-introduced.
- `EconomyAnalysisSelector.selectCountryProductEconomiesByProduct` re-introduced.
- `CountryProductSummaryDTO.countryTag` and `countryName` re-introduced.
- `phase-6-completion-report.md` updated with PATTERN I annotations preserving original, superseded, and reinstated audit trail.

---

## Rules for Phase 9 (Parity Harness Extension)

1. **Extend, Do Not Replace:** Phase 9 must extend `e2e/parity/compare.py` to check `states`, `factories`, `artisans`, extended `province` fields, and extended `country` fields without deleting existing country/product/province scope checks.
2. **Selector Usage:** Phase 9 export bundles should consume the Phase 8 `EconomyAnalysisSelector` queries.
3. **Zero Scope Creep:** No LWC components created in Phase 8; Phase 9 owns python parity script extension.

---

## Phase 2 Extended Golden Dataset Inventory & Record Counts

1. **`country.json` / `csv/Country.csv`:** 118 records (Extended with `fgdp`, `pgdp`, `agdp`, `corePopulation`, `colonyPopulation`).
2. **`provinces.json` / `csv/Provinces.csv`:** 2,703 records (Extended with `rgoIncome`, `rgoGdp`, `colony`, `artisanSpending`, `artisanIncome`, `artisanGdp`).
3. **`factory.json` / `csv/Factory.csv`:** 714 records (New Phase 2 addition covering individual building metrics).
4. **`artisans.json` / `csv/Artisans.csv`:** 4,406 records (New Phase 2 addition covering aggregated artisan metrics).
5. **`states.json` / `csv/States.csv`:** 124 records (New Phase 2 addition covering regional state aggregations).
6. **`goods.json` / `csv/Goods.csv`:** 48 records.

---

## Schema Summary (Phase 3 Complete)

- **Total Custom Objects:** 13 (8 baseline + 4 new custom objects + 1 import platform event).
- **Total Custom Fields:** 138 custom fields verified across all objects.
- **Canonical Units & Precision:** 100% compliant with Phase 1 frozen unit definitions.

---

## Maintenance & Test Execution Guidelines

- **Run Apex Test Suite:** Execute all Apex unit tests (`EconomyAnalysisSelectorTest`, `EconomyAnalysisControllerTest`, `EconomyAnalysisServiceTest`, `DTOsTest`, `EconomyImportIdempotencyTest`, etc.).
- **Run Parity Verification Harness:** `python3 e2e/parity/compare.py`
- **Run Metadata Validator:** `python3 scripts/validate_metadata.py`
- **Run Field Inventory Generator:** `python3 scripts/generate_field_inventory.py`
