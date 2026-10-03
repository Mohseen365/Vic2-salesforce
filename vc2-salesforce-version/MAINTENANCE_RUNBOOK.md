# Victoria 2 Economy Analyzer — Operational Maintenance Runbook

**Target Audience:** Salesforce Developers, System Administrators, DevOps Engineers, and Future Maintainers
**Target Repository:** `vc2-salesforce-version/`
**Document Version:** 1.1 (Post-Migration & Enhancement Track A Operational Guide)

---

## 1. Local Testing Execution

### 1.1 Running LWC Jest Unit Test Suite
```bash
cd vc2-salesforce-version
npm run test:lwc
```
*Executes all 12 LWC Jest test suites (78 unit tests) covering shell, headers, dashboards, charts, export utils, compare, and multi-save trend LWCs.*

### 1.2 Running Parity Verification Harness
```bash
python3 vc2-salesforce-version/e2e/parity/compare.py
```
*Compares Salesforce export bundle DTO output against Phase 0 Golden Dataset (`egypt_golden_bundle.json`). Reports field-level tolerances and discrepancy count.*

### 1.3 Running Metadata Structure Validator
```bash
python3 vc2-salesforce-version/scripts/validate_metadata.py
```
*Validates XML structure, custom object definitions, formula fields, roll-ups, and field counts across all 9 custom metadata objects.*

---

## 2. Reproducing Phase 0 Golden Dataset

The Phase 0 Golden Dataset Oracle was generated from source save game `egypt.v2` (27,059,272 bytes, SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`).

To re-verify golden dataset integrity and deterministic generation:
```bash
python3 vc2-salesforce-version/golden-dataset/scripts/verify_integrity_and_determinism.py
```

### Parity Tolerance Rules Reference
- **Currency Values (GDP, Imports, Exports, Income):** `±£0.01`
- **Prices, Quantities, Supply, Demand Pools:** `±0.0001`
- **Percentages (Inflation, Overproduction, Unemployment, GDP Share):** `±0.01%`
- **Population & Integer Ranks:** `Exact match`
- **Tie-Breaking Rule:** Tie-break country GDP ranks by `Country_Tag__c` ascending alphabetical order.

---

## 3. Importing Save Files via REST Ingestion

### REST Endpoint Details
- **URI:** `POST /services/apexrest/economy/import`
- **Apex Handler:** `EconomyImportRestResource.cls`
- **Content-Type:** `application/json`

### Payload Structure Example
```json
{
  "saveFileName": "prussia_1848.v2",
  "sourceSaveFileName": "prussia_1848.v2",
  "ingameDate": "1848-03-12",
  "playerCountryTag": "PRU",
  "countries": [
    {
      "countryTag": "PRU",
      "countryName": "Prussia",
      "population": 14820000,
      "workforce": 3705000,
      "employment": 3549390,
      "goldIncome": 120.50
    }
  ],
  "products": [
    {
      "productCode": "small_arms",
      "productName": "Small Arms",
      "price": 12.50,
      "basePrice": 10.00,
      "totalWorldSupply": 450.00,
      "realDemand": 410.00,
      "maxDemand": 500.00
    }
  ],
  "countryProducts": [
    {
      "countryTag": "PRU",
      "productCode": "small_arms",
      "soldDomestic": 120.40,
      "boughtQuantity": 0.00,
      "thrownToMarket": 350.00,
      "actualSoldWorld": 330.00
    }
  ]
}
```

---

## 4. Import Lifecycle & Watcher Status Interpeting

### Lifecycle Status Flow
1. **`RECEIVED`:** Payload accepted by `EconomyImportRestResource.cls`. `Economy_Analysis__c` header created.
2. **`PROCESSING`:** `EconomyImportBatch.cls` executing chunked DML insertion of `Country_Economy__c`, `Product_Economy__c`, and `Country_Product_Economy__c` records.
3. **`CALCULATING`:** `EconomyCalculationEngine.cls` computing trade values, GDP contributions, total country GDPs, per-capita GDPs, and GDP ranks.
4. **`COMPLETED`:** Import and calculations successfully committed.
5. **`FAILED`:** Error caught during import/calculation. Error message logged in `Import_Diagnostic_Message__c`.

### Real-Time Notification Stream
Real-time status changes publish `Economy_Import_Event__e` Platform Events. `c-save-game-watcher-status` LWC listens via `lightning/empApi` and automatically prompts the user or refreshes child components when status transitions to `COMPLETED`.

---

## 5. Operational Tasks & Procedures

### 5.1 Adding a New Save Snapshot Idempotently
When importing a save file with the same `saveFileName`, `EconomyImportService.cls` upserts records using composite external ID keys (`Unique_Snapshot_Key__c` = `${saveFileName}_${countryTag/productCode}`). Existing snapshot data is overwritten safely without creating duplicate records.

### 5.2 Dynamic Master Reference Auto-Creation (Mod Support)
When importing a save game from a Victoria 2 game mod (e.g. HPM, GFM) with new country tags or commodity codes:
`EconomyImportService.cls` automatically detects missing `Country__c` or `Product__c` records and creates them on-the-fly during import ingestion.

### 5.3 Adding a New CSV Export Scope
To add a new export scope (e.g., `'Provinces'` or `'Factories'`):
1. Client-Side: Update `c/economicExportUtils` for client-side generation under 5,000 rows.
2. Server-Side: Update `EconomyAnalysisController.exportCsv(Id analysisId, String scope)` to add a branch for the new scope string. The Apex method signature (`exportCsv(Id, String)`) must remain unchanged to preserve LWC compatibility.

### 5.4 Extending Chart Visualizations (SVG-Native Pattern)
All charts in `c-economic-charts-container` use pure SVG template rendering without external JavaScript libraries:
1. Define dynamic SVG geometry getters in LWC JavaScript (e.g., calculating `cx`, `cy`, `r`, `stroke-dasharray` for donuts or `<rect x y width height>` for bar charts).
2. Render geometry elements directly in LWC HTML template using standard Lightning SLDS markup.

### 5.5 Formula Modification & Parity Maintenance Rule
**CRITICAL RULE:** If modifying any calculation rule in `EconomyCalculationEngine.cls` or custom formula field:
1. You **MUST** run `python3 vc2-salesforce-version/e2e/parity/compare.py` immediately.
2. Verify that total discrepancies remain `0`.
3. If discrepancies are introduced, update `golden-dataset/formula-notes.md` or correct the formula to preserve domain parity.

### 5.6 Adding a New Trend Chart (Enhancement Track A Extension Template)
To extend `c-multi-save-trend` with a new time-series trend chart tab:
1. **Apex DTO:** Update `WorldTrendDTO`, `CountryTrendDTO`, or `ProductTrendDTO` (or create a new trend DTO) to expose the required time-series metrics.
2. **Apex Selector & Service:** Add or update selector SOQL queries in `EconomyAnalysisSelector.cls` (ensuring `Economy_Analysis__c IN :cappedIds` filter and `capAnalysisIds` 12-item limit) and map fields in `EconomyAnalysisService.cls`.
3. **LWC JavaScript (`multiSaveTrend.js`):**
   - Add a getter method (e.g., `get myCustomTrendPoints()`) mapping time-series points to `(cx, cy)` SVG coordinate space.
   - Use `buildSvgPath(points)` helper to construct the SVG `<path d={...}>` attribute.
   - Add an accessibility data table getter for screen readers.
4. **LWC HTML (`multiSaveTrend.html`):** Add a new `<lightning-tab>` containing the `<svg>` visualization and assistive fallback table.
5. **Jest Testing (`multiSaveTrend.test.js`):** Add test assertions verifying wire adapter mocked data renders the new SVG elements and assistive table.

---

## 6. Repository Layout & File Pointers

```
vc2-salesforce-version/
├── force-app/main/default/
│   ├── classes/                          <-- All 17 Apex Classes and Test Classes
│   ├── lwc/                              <-- All 12 LWC Bundles
│   ├── objects/                          <-- 9 Custom SObject Definitions & Fields
│   └── permissionsets/                   <-- Economy_Analyzer_User & Admin
├── golden-dataset/                       <-- Oracle Reference Dataset (egypt.v2)
├── e2e/
│   ├── parity/compare.py                 <-- End-to-End Parity Verification Harness
│   └── manual/                           <-- Manual Test Verification Scripts
├── scripts/validate_metadata.py          <-- Metadata Validator Script
├── AUDIT_COMPLIANCE_MATRIX.md            <-- Audit Section A–R Compliance Matrix
├── MIGRATION_COMPLETION_REPORT.md        <-- Final Stakeholder Migration Report
├── MAINTENANCE_RUNBOOK.md                <-- This Operational Runbook
├── PERFORMANCE_REPORT.md                 <-- LDV Performance & Governor Limits Report
├── SECURITY_HARDENING_REPORT.md          <-- Security & FLS Compliance Report
└── enhancement-a-completion-report.md    <-- Enhancement Track A Completion Report
```
