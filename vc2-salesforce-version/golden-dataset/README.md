# Victoria 2 Economy Analyzer — Phase 0 Golden Dataset Reference

## 1. Overview
This directory contains the authoritative Phase 0 Golden Dataset generated from the real Victoria 2 save game `egypt.v2` using the legacy Java analyzer (`vic2_economy_analyzer`).

## 2. Save File Reference
- **File:** `egypt.v2`
- **Path:** `/tmp/file_attachments/savegames/egypt.v2`
- **Size:** 27059272 bytes
- **SHA-256:** `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`

## 3. Directory Structure
```text
golden-dataset/
├── README.md                          # Main developer guide
├── manifest.json                      # Dataset manifest and metadata
├── formula-notes.md                   # Complete audit of all legacy formulas
├── validation-report.md               # Validation and verification summary
├── raw/                               # RAW parsed save data
│   ├── save-metadata.json
│   ├── countries.json
│   ├── provinces.json
│   ├── products.json
│   ├── product-storage.json
│   └── economy-subjects.json
├── derived/                           # DERIVED domain calculations
│   ├── country-calculations.json
│   ├── product-calculations.json
│   ├── product-storage-calculations.json
│   └── report-calculations.json
├── expected/                          # Regression targets for Phase 2 Apex
│   └── apex-golden-results.json
├── csv/                               # Human-readable CSV views
│   ├── countries.csv
│   ├── provinces.csv
│   ├── products.csv
│   ├── product-storage.csv
│   └── calculations.csv
└── source/                            # Pipeline and parser execution docs
    ├── parser-invocation.md
    └── extraction-summary.md
```

## 4. RAW vs DERIVED Distinction
- **RAW Data:** Values extracted directly from the save file nodes (`worldmarket`, `country`, `province`) before running economic calculations.
- **DERIVED Data:** Metrics calculated by legacy Java domain logic (`Country.innerCalculations()`, `ProductStorage.innerCalculations()`, `Product.getOverproduced()`).

## 5. How Phase 2 Apex Tests Consume This Dataset
Phase 2 unit and integration tests will load `expected/apex-golden-results.json` and assert that Apex calculations produce values within `tolerance` (0.0001) of `expected_value`.
