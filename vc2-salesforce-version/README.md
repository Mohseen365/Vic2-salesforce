# Victoria 2 Economy Analyzer — Salesforce Native Conversion

This directory contains the complete Salesforce-native conversion of the Victoria 2 Economy Analyzer application, built using Apex, Lightning Web Components (LWC), Custom Objects, Custom Fields, and Platform Events.

---

## 1. System Architecture Overview

### Data Model & Custom Objects
- **`Economy_Analysis__c`**: Analysis header capturing Save File Name, Ingame Date, Player Tag, World Totals (GDP, Population, Imports, Exports), and `Import_Status__c` (`RECEIVED` → `PROCESSING` → `CALCULATING` → `COMPLETED` | `FAILED`).
- **`Country_Economy__c`**: Snapshot country economic data (GDP, GDP Rank, GDP Per Capita, Population, RGO/Factory Workforce, Employment, Unemployment Rates, Gold Income).
- **`Product_Economy__c`**: Snapshot commodity market metrics (Price, Base Price, Total World Supply, Real Demand, Max Demand, Inflation %, Overproduction %).
- **`Country_Product_Economy__c`**: Country x Product junction (Sold Domestic, Bought Qty, Thrown to Market, Import/Export Values, GDP Contribution).
- **`Province_Economy__c`**: Regional province metrics (Population, RGO Production).
- **`Economy_Import_Event__e`**: Platform Event driving real-time status notifications to LWC components.

### Apex Controller & Service Architecture
- **Facade Controller:** `EconomyAnalysisController.cls` (exposes `@AuraEnabled(cacheable=true)` methods for LWCs and `exportCsv` fallback).
- **Calculation Engine:** `EconomyCalculationEngine.cls` (pure domain calculation engine, zero SOQL/DML).
- **Service Layer:** `EconomyAnalysisService.cls` (manages analysis lifecycle, recalculations, and save snapshot comparisons).
- **Selector Layer:** `EconomyAnalysisSelector.cls`, `CountrySelector.cls`, `ProductSelector.cls` (bulkified SOQL projections with security enforcement).
- **Import Pipeline:** `EconomyImportRestResource.cls`, `EconomyImportService.cls`, `EconomyImportBatch.cls`.

### LWC Bundle Hierarchy & Workspace Tabs
All five tabs in `c-economy-analyzer-shell` are fully operational:
1. 🌐 **Global Overview (`c-global-economy-dashboard`)**: World KPI cards, Top 10 World Powers table, Top 10 Commodities table, embedded SVG charts container, and row navigation hooks.
2. 🏛️ **Country Explorer (`c-country-dashboard`)**: Country metrics, search filtering, trade breakdown datatable, and regional SVG charts.
3. 📦 **Product Market (`c-product-list-view` & `c-product-dashboard`)**: Commodity grid, search filtering, supply/demand breakdown, and country trade sub-table.
4. 📈 **Analytics & Visualizations (`c-economic-charts-container`)**: Pure SVG LWC multi-chart suite.
5. 📊 **Compare Saves (`c-analysis-compare`)**: Dual save snapshot selection, world GDP growth trend badge, country delta datatable, and commodity delta datatable.
6. **Support Components**: `c-economy-analysis-header`, `c-save-game-watcher-status`, `c-economic-export-modal`, `c/economicExportUtils`.

---

## 2. Import Pipeline Contract

1. **Ingestion Endpoint:** `POST /services/apexrest/economy/import`
2. **Off-Heap EUG Parser:** Transmits normalized JSON DTO payload parsed from `.v2` save files.
3. **Lifecycle States:** `RECEIVED` → `PROCESSING` → `CALCULATING` → `COMPLETED` | `FAILED`.
4. **Real-Time Streaming:** Subscribed via `lightning/empApi` listening to `Economy_Import_Event__e`.

---

## 3. How to Run Tests

### LWC Jest Unit Test Suite
```bash
cd vc2-salesforce-version
npm run test:lwc
```
*Runs all 11 LWC Jest suites (72 unit tests) at 100% pass rate.*

### End-to-End Parity Verification Harness
```bash
python3 vc2-salesforce-version/e2e/parity/compare.py
```
*Compares exported/DTO data against Phase 0 Golden Dataset with zero discrepancies.*

### Metadata Structure Validation
```bash
python3 vc2-salesforce-version/scripts/validate_metadata.py
```
*Validates 9 Custom Objects and 78 Custom Fields.*

---

## 4. How to Reproduce Phase 0 Golden Dataset

The Phase 0 Golden Dataset Oracle was generated from source save game `egypt.v2` (SHA-256: `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`).

To re-verify golden output determinism:
```bash
python3 vc2-salesforce-version/golden-dataset/scripts/verify_integrity_and_determinism.py
```

For detailed architectural audit references, see [VICTORIA2_ECONOMY_ANALYZER_SALESFORCE_CONVERSION_AUDIT.md](./VICTORIA2_ECONOMY_ANALYZER_SALESFORCE_CONVERSION_AUDIT.md) and [SECURITY_HARDENING_REPORT.md](./SECURITY_HARDENING_REPORT.md).
