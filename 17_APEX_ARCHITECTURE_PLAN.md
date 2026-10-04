# 17. Apex Architecture Plan and Class Hierarchy

## Overview
This document outlines the Apex class architecture, responsibility separation, and governance controls.

---

## Apex Class Hierarchy & Layering

### 1. Ingestion & REST Layer
- **`EconomyImportRestResource.cls`**: REST API resource exposed at `/services/apexrest/economy/import`.
- **`EconomyImportService.cls`**: Ingestion orchestrator managing upserts and status transitions.
- **`EconomyImportBatch.cls`**: Async Queueable/Batch worker for high-cardinality factory/artisan persistence.

### 2. Service & Controller Facade Layer
- **`EconomyAnalysisController.cls`**: `@AuraEnabled(cacheable=true)` facade controller for LWC components.
- **`EconomyAnalysisService.cls`**: Business service managing analysis queries and snapshot comparisons.

### 3. Pure Domain Calculation Engine Layer
- **`EconomyCalculationEngine.cls`**: Pure domain calculation engine containing domain math logic with ZERO SOQL or DML side effects.

### 4. Selector & Data Access Layer
- **`EconomyAnalysisSelector.cls`**: Enforces FLS/CRUD security and executes bulk SOQL projections.
- **`CountrySelector.cls` & `ProductSelector.cls`**: Target selectors for master reference records.

### 5. DTO Transfer Layer
- `EconomyImportRequestDTO`, `EconomyImportResponseDTO`, `AnalysisSummaryDTO`, `CountrySummaryDTO`, `ProductSummaryDTO`, `StateSummaryDTO`, `ProvinceSummaryDTO`, `FactorySummaryDTO`, `ArtisanSummaryDTO`, `AnalysisComparisonDTO`.
