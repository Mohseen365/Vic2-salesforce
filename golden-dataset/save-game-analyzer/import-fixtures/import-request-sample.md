# Import Request Sample Fixture Specification

## Overview
The file `import-request-sample.json` is a sanitized, representative JSON payload derived from the Phase 2 golden dataset (`country.json`, `goods.json`, `provinces.json`, `states.json`, `factory.json`, `artisans.json`).

## Fixture Scope
- **Analysis:** 1 root snapshot header (`contractVersion = "1.0.0"`).
- **Countries:** 2 nations (`TUR`, `EGY`).
- **Products:** 3 commodities (`ammunition`, `small_arms`, `artillery`).
- **Country x Product Junctions:** 5 country-commodity market entries.
- **Provinces:** 5 province economy records.
- **States:** 2 state economy records (`TUR_blank`, `EGY_Cairo`).
- **Factories:** 2 factory economy records.
- **Artisans:** 3 artisan economy records.

## Usage
This fixture is consumed by:
1. `EconomyImportRequestDTOTest.cls` — unit tests asserting payload deserialization and round-trip serialization.
2. Ingestion pipeline E2E tests in Phase 6.
