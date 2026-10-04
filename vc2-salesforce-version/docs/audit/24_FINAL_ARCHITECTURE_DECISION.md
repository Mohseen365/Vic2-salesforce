# 24. Final Architecture Decision Record (ADR)

## Executive Summary

```text
SAVE FORMAT: Plain ASCII text (latin1 encoding), 27.06 MB, 2.09M lines, nested brace syntax.
CURRENT PROJECT: Fully operational 13 Custom Objects, 138 Fields, 41 Apex classes, 15 LWCs.
DATA GAP: Full 46K POP records omitted from persistent DML to protect Salesforce limits; kept transient.
RECOMMENDED MODEL: Canonical Domain Model mapped to 13 Custom Objects with composite External IDs.
SALESFORCE: Store macro country, product, state, province, factory, artisan economic snapshots.
EXTERNAL: Retain raw .v2 file in ContentVersion for audit reproducibility.
IMPORT: External off-heap parser -> REST API endpoint (/services/apexrest/economy/import) -> Async Batch.
SCALE: High cardinality objects (Factories, Artisans) automatically enqueued via EconomyImportBatch when count > 200.
NEXT STEP: Execute Phase 1 implementation validation and maintain 100% parity verification.
```

---

## Architectural Decision Summary Answers

- **A. Canonical Domain Model:** Technology-independent representation separating master definitions from temporal save snapshots.
- **B. What Salesforce Stores:** High-value macro economic metrics (GDP, prices, trade values, factory/artisan outputs).
- **C. What Salesforce Derives:** Per capita metrics, overproduction percentages, productivity, profit formulas, and country trade totals via Rollup Summaries and Formulas.
- **D. What Remains External/Raw:** Raw `.v2` source text file stored in `ContentVersion` attachments.
- **E. Salesforce Object Model:** 13 Custom Objects anchored by `Economy_Analysis__c` parent header.
- **F. Record Grain:** 1 Analysis per Save; 1 Country/Product per Analysis; 1 State/Province/Factory/Artisan per Analysis.
- **G. Import Mechanism:** HTTP POST JSON DTO payload to `/services/apexrest/economy/import`.
- **H. Parsing Location:** Off-heap external client/parser transmitting normalized JSON DTO.
- **I. Handling Large Files:** Async batch persistence (`EconomyImportBatch.cls`) with chunk size 200 for records > 200.
- **J. Multiple Saves Representation:** Prefixed composite external keys (`Unique_Snapshot_Key__c = <SaveFileName>_<EntityKey>`).
- **K. Save Comparison:** Managed via `EconomyAnalysisController.compareAnalyses` returning `AnalysisComparisonDTO`.
- **L. Modded Data Strategy:** Unrecognized goods auto-provisioned with `Base_Price__c = 0.0`; skipped artisans log diagnostic warnings.
- **M. Required Apex:** 41 Apex classes across REST, Service, Controller, Selector, Engine, and DTO layers.
- **N. Required LWCs:** 15 LWC bundles organized into 5 workspace tabs in `c-economy-analyzer-shell`.
- **O. Implementation Priority:** Maintain current verified Phase 6 REST pipeline and 100% test pass rate.
