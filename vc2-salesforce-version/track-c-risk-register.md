# Track C — Risk Register

## 1. Overview

This document provides the formal Risk Register for future feature development and data model expansion based on the 136-object Victoria 2 Save-Game Salesforce Data Model.

Each risk is evaluated for **Likelihood** (`LOW`, `MEDIUM`, `HIGH`) and **Impact** (`LOW`, `MEDIUM`, `HIGH`), accompanied by concrete, actionable mitigation strategies.

---

## 2. Risk Matrix Table

| Risk ID | Affected Feature(s) | Description | Likelihood | Impact | Actionable Mitigation Strategy |
|---|---|---|---|---|---|
| `RSK-01` | All Features (`FEAT-01`–`FEAT-16`) | **Data Model Deployment Failure**: 15 BLOCKING defects in `salesforce_model_expanded.txt` (lookups >40, double suffixes, non-existent target objects) cause deployment failures in Salesforce orgs. | **HIGH** | **HIGH** | Execute Phase 0 Metadata Remediation (`track-c-data-model-audit.md`) before attempting any org deployment or feature coding. |
| `RSK-02` | `FEAT-04`, `FEAT-16` | **POP Data Volume Governor Limit Violation**: Ingesting 100,000+ `Pop__c` records per save file causes Apex SOQL Query Row limit (50,000) and Heap Size limit (12MB) exceptions. | **HIGH** | **HIGH** | Enforce Batch Apex ingestion (`SaveImportBatch.cls`) with scope size 200. Implement mandatory aggregate summary fields on `Province_Save_State__c` and `Country_Save_State__c` to eliminate micro-POP SOQL queries during LWC page rendering. |
| `RSK-03` | All Features (`FEAT-01`–`FEAT-16`) | **Ingestion Pipeline Gap**: Track B created 123 save-game metadata objects, but no Python parser (`Save_Game_Analyzer`) or Apex REST DTO deserializer currently exists to populate non-economy objects. | **HIGH** | **HIGH** | Develop `SaveGameImportRequestDTO.cls` and update `Save_Game_Analyzer` Python parser before commencing feature LWC development. |
| `RSK-04` | All Features (`FEAT-01`–`FEAT-16`) | **Permission Set & Security Gap**: 123 newly expanded objects lack Permission Set metadata, resulting in `System.NoAccessException` or silent empty SOQL results for non-admin users. | **HIGH** | **MEDIUM** | Generate automated `Save_Game_Analyzer_Admin` Permission Set XML granting Read/Create/Edit/Delete access to all 136 objects and 986 fields. |
| `RSK-05` | `FEAT-15` | **Multi-Save Snapshot Heap Overflow**: Comparing complex political/military metrics across 12 save game snapshots exceeds Apex Heap Limits during DTO serialization. | **MEDIUM** | **MEDIUM** | Enforce a hard cap of 12 snapshots per trend request. Implement lightweight DTO projections containing only primitive summary metrics. |
| `RSK-06` | `FEAT-02`, `FEAT-05` | **Mod Variance & Custom Tag/Commodity Errors**: Modded save files containing custom country tags (e.g., `BYZ`, `CSA`) or custom goods trigger unmapped entity exceptions. | **MEDIUM** | **LOW** | Implement dynamic fallback handling in ingestion DTOs that provisions unknown tags as generic `Country_Save_State__c` records with default fallback flags. |
| `RSK-07` | `FEAT-10`, `FEAT-11` | **High-Cardinality War & Battle Log Storage Exhaustion**: Historical battle logs (`Battle__c`, `War_History_Entry__c`) accumulate millions of records across multi-snapshot campaigns, exhausting org storage limits. | **MEDIUM** | **MEDIUM** | Implement a configurable retention policy in `SaveAnalysisController` allowing admins to purge battle history entries older than N snapshot imports. |
| `RSK-08` | `FEAT-08`, `FEAT-09` | **Junction Object SOQL Query Complexity**: Deep relational queries across `Country_Country_Ref__c` junction objects hit SOQL subquery depth limits ($>2$ levels). | **LOW** | **MEDIUM** | Denormalize key relation scores (e.g. `Master_Country_Tag__c`, `Sphere_Status__c`) directly onto `Country_Save_State__c` for fast single-level querying. |
