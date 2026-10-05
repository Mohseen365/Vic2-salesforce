# Track C — Existing Asset Inventory Report

## 1. Overview

This document provides a comprehensive inventory of all existing Apex classes and Lightning Web Component (LWC) bundles built during Phase 1–6 (the economy conversion track).

The goal of this inventory is to prevent duplicate asset creation during future feature expansion. Each asset is assigned a **Reusability Score**:
- **HIGH**: Generic pattern or universal utility that can immediately service non-economy domains (e.g. Political, Military, POP, War, Diplomacy).
- **MEDIUM**: Domain-specific framework or selector pattern that is directly extensible to new domains via subclassing, parameterization, or interface implementation.
- **LOW**: Specialized, highly tailored economy calculation or summary DTO.

---

## 2. Apex Asset Inventory (41 Classes)

| Asset Name | Asset Type | Purpose | Reusability | Target Domain Extension |
|---|---|---|---|---|
| `EconomyCalculationEngine.cls` | Pure Engine | Stateless domain calculation engine performing balance, tax, and price calculations. | **MEDIUM** | Pattern serves as the blueprint for `MilitaryCalculationEngine` & `PopDemographicEngine`. |
| `EconomyAnalysisService.cls` | Domain Service | Business logic orchestrator for economy snapshot calculations and SOQL aggregation. | **LOW** | Economy-specific orchestrator; separate domain services recommended for Politics/Military. |
| `EconomyImportService.cls` | Ingestion Service | Deserializes JSON parser payloads and coordinates DML upserts for economy objects. | **MEDIUM** | Ingestion pipeline framework adaptable for full save payload processing (`SaveImportService`). |
| `EconomyImportBatch.cls` | Batch Apex | Batchable Apex chunking large factory/artisan records with scope size 200 to avoid LDV limit errors. | **HIGH** | Essential pattern for ingesting high-cardinality `Pop__c` and `Province_Save_State__c` datasets. |
| `EconomyAnalysisSelector.cls` | SOQL Selector | Encapsulates SOQL queries for `Economy_Analysis__c` and aggregate economy metrics. | **LOW** | Economy-specific selector. |
| `CountrySelector.cls` | SOQL Selector | Queries country economy records and country rankings. | **MEDIUM** | Direct pattern for querying `Country_Save_State__c` across political, military, and diplomatic views. |
| `ProductSelector.cls` | SOQL Selector | Queries global product economy records and market lines. | **LOW** | Product/market specific. |
| `EconomyAnalysisController.cls` | Facade Controller | Facade providing `@AuraEnabled(cacheable=true)` methods for LWC components and CSV exports. | **MEDIUM** | Controller facade architecture pattern reusable for `SaveAnalysisController`. |
| `EconomyImportRestResource.cls` | REST Endpoint | Exposes `/services/apexrest/economy/import` endpoint for external parser POST requests. | **HIGH** | REST resource framework adaptable to `/services/apexrest/savegame/import` for full save payloads. |
| `EconomyCalculationResult.cls` | Engine DTO | Enclosure for calculated country, product, factory, and artisan metrics. | **MEDIUM** | Structure reusable for wrapping domain calculation engine outputs. |
| `AnalysisSummaryDTO.cls` | Summary DTO | Lightweight DTO for global snapshot header and macro metrics. | **MEDIUM** | Reusable for high-level save game macro summary headers. |
| `CountrySummaryDTO.cls` | Summary DTO | Structured payload for country economic summary views. | **MEDIUM** | Extensible to include political ideology and army count fields. |
| `ProductSummaryDTO.cls` | Summary DTO | Structured payload for commodity market analysis. | **LOW** | Product-specific. |
| `CountryProductSummaryDTO.cls` | Summary DTO | Structured payload for country supply/demand commodity breakdowns. | **LOW** | Commodity-specific. |
| `ProvinceSummaryDTO.cls` | Summary DTO | Structured payload for province-level economic output. | **MEDIUM** | Extensible for province population and RGO employment data. |
| `StateSummaryDTO.cls` | Summary DTO | Structured payload for state-level industrial output. | **MEDIUM** | Reusable for state building and construction views. |
| `FactorySummaryDTO.cls` | Summary DTO | Structured payload for factory employment and profitability. | **LOW** | Factory-specific. |
| `ArtisanSummaryDTO.cls` | Summary DTO | Structured payload for artisan production. | **LOW** | Artisan-specific. |
| `AnalysisComparisonDTO.cls` | Comparison DTO | Encapsulates metric deltas between two save game snapshots. | **HIGH** | Universal delta comparison DTO adaptable to any numeric entity metric comparison. |
| `EconomyImportRequestDTO.cls` | Ingestion DTO | Deserialization contract for inbound parser save payload. | **MEDIUM** | Contract format serves as template for `SaveGameImportRequestDTO`. |
| `EconomyImportResponseDTO.cls` | Ingestion DTO | Outbound response envelope for REST import status and record counts. | **HIGH** | Universal REST API response contract for save ingestion endpoints. |
| `CountryTrendDTO.cls` | Time Series DTO | Multi-snapshot time series data container for country metrics (3–12 saves). | **HIGH** | Reusable container for tracking country military/prestige/POP trends over time. |
| `ProductTrendDTO.cls` | Time Series DTO | Multi-snapshot time series container for commodity price and supply trends. | **LOW** | Market-specific. |
| `WorldTrendDTO.cls` | Time Series DTO | Multi-snapshot global economic trend container. | **MEDIUM** | Reusable for world population and global crisis metrics. |
| `EconomyAnalysisControllerTest.cls` | Test Class | Unit tests for LWC controller facade (100% coverage). | **LOW** | Domain test. |
| `EconomyAnalysisSelectorTest.cls` | Test Class | Unit tests for selector methods. | **LOW** | Domain test. |
| `EconomyAnalysisServiceTest.cls` | Test Class | Unit tests for domain orchestration service. | **LOW** | Domain test. |
| `EconomyCalculationEngineTest.cls` | Test Class | Unit tests for pure calculation engine. | **LOW** | Domain test. |
| `EconomyGovernorLimitTest.cls` | Test Class | Governor limit validation tests for SOQL and heap size safety. | **HIGH** | Benchmark test framework for validating LDV limits across new domains. |
| `EconomyImportBatchTest.cls` | Test Class | Unit tests for batch import chunking. | **MEDIUM** | Batch testing pattern reusable for `SaveImportBatchTest`. |
| `EconomyImportIdempotencyTest.cls` | Test Class | Unit tests validating duplicate import prevention. | **HIGH** | Idempotency verification pattern reusable for full save ingestion tests. |
| `EconomyImportIntegrationTest.cls` | Test Class | End-to-end integration tests for REST API ingestion. | **MEDIUM** | Integration testing pattern. |
| `EconomyImportRequestDTOTest.cls` | Test Class | Serialization/deserialization tests for DTO contracts. | **MEDIUM** | DTO contract test pattern. |
| `EconomyImportRestResourceTest.cls` | Test Class | HTTP request mock tests for Apex REST resource. | **HIGH** | Reusable REST testing boilerplate. |
| `EconomyImportServiceTest.cls` | Test Class | Ingestion service unit tests. | **LOW** | Domain test. |
| `EconomyLdvValidationTest.cls` | Test Class | Large Data Volume (LDV) validation tests. | **HIGH** | Essential testing template for validating 100,000+ POP record handling. |
| `EconomyPlatformEventTest.cls` | Test Class | Unit tests for `Economy_Import_Event__e` publishing. | **HIGH** | Reusable event publication test template. |
| `EconomyTrendServiceTest.cls` | Test Class | Unit tests for time series trend calculation. | **MEDIUM** | Trend service testing pattern. |
| `CountrySelectorTest.cls` | Test Class | Unit tests for country selector queries. | **LOW** | Domain test. |
| `ProductSelectorTest.cls` | Test Class | Unit tests for product selector queries. | **LOW** | Domain test. |
| `DTOsTest.cls` | Test Class | Comprehensive coverage tests for all DTO classes. | **LOW** | DTO coverage test. |

---

## 3. LWC Asset Inventory (15 Bundles)

| Component Name | Component Type | Purpose Description | Reusability | Target Domain Extension |
|---|---|---|---|---|
| `c-economy-analyzer-shell` | Workspace Shell | Master tab container managing active snapshot state and inter-component custom events. | **HIGH** | Easily extensible to host additional domain tabs (Politics, Military, POPs, Wars, Diplomacy). |
| `c-economy-analysis-header` | Summary Bar | Displays snapshot metadata, date, player country, and core macro KPIs. | **MEDIUM** | Reusable top header component for save-game workspace displays. |
| `c-global-economy-dashboard` | Overview Card | Global overview card showing macro supply/demand and top country rankings. | **LOW** | Economy-specific overview card. |
| `c-country-dashboard` | Explorer View | Country-specific detail view with KPI cards, rankings, and detailed lists. | **MEDIUM** | Modular container adaptable to become the unified Country Explorer host. |
| `c-product-list-view` | Data Table | Filterable datatable for commodity prices, supply, demand, and volume. | **LOW** | Commodity-specific. |
| `c-product-dashboard` | Detail View | Single commodity detail card with supply/demand breakdown. | **LOW** | Commodity-specific. |
| `c-state-dashboard` | Detail View | State industrial output and building inventory card. | **MEDIUM** | Extensible to show state construction and employment. |
| `c-factory-dashboard` | Detail View | Factory profitability and employment view. | **LOW** | Factory-specific. |
| `c-artisan-dashboard` | Detail View | Artisan pop production and good output view. | **LOW** | Artisan-specific. |
| `c-economic-charts-container` | Visualizer | Pure SVG-native chart rendering engine (bar, horizontal bar, line, trend). | **HIGH** | Universal LWC chart visualizer capable of rendering any dataset without external JS libraries. |
| `c-analysis-compare` | Comparative View | Side-by-side snapshot delta comparison with metric variance highlights. | **HIGH** | Universal delta comparison component adaptable for military, population, or political comparisons. |
| `c-multi-save-trend` | Time Series Chart | SVG line chart visualizer for 3–12 snapshot trend tracking. | **HIGH** | Universal multi-save trend charting component. |
| `c-economic-export-modal` | Modal Dialog | Modal popup allowing user CSV export scope selection and download. | **HIGH** | Universal modal container for dataset export options. |
| `c-economic-export-utils` | JS Utility Module | Client-side RFC 4180 CSV builder supporting browser blob downloads up to 5,000 rows. | **HIGH** | Universal client-side CSV generation utility module. |
| `c-save-game-watcher-status` | Status Monitor | Real-time import monitor listening to `Economy_Import_Event__e` via `lightning/empApi`. | **HIGH** | Universal real-time import progress visualizer. |

---

## 4. Architecture Extension Strategy

To maintain clean codebase architecture and maximize code reuse:

1. **Workspace Extension**: `c-economy-analyzer-shell` should be renamed or wrapped as `c-save-game-analyzer-shell` to house new primary tabs: *Global Overview*, *Country Explorer*, *POPs & Demographics*, *Military & War*, *Diplomacy & Sphere*, and *Compare Saves*.
2. **Generic Charting**: All new feature dashboards MUST reuse `c-economic-charts-container` and `c-multi-save-trend` by supplying standard JSON data structures rather than building custom SVG renderers.
3. **Selector Layer**: Extend `CountrySelector.cls` and `EconomyAnalysisSelector.cls` rather than creating redundant selector classes for country-level lookups.
4. **Data Ingestion**: Adapt `EconomyImportBatch.cls` chunking logic for ingesting high-volume `Pop__c` records (>100,000 records per save file) to prevent Heap Size and DML limit exceptions.
