# Save_Game_Analyzer Semantic Contract Freeze (Phase 1)

**Document Status:** FROZEN & AUTHORITATIVE
**Phase:** Phase 1 — Semantic Contract Freeze
**Target Directory:** `vc2-salesforce-version/`
**Reference Source:** `Save_Game_Analyzer/` Python source files
**Gap Audit Reference:** `vc2-salesforce-version/SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`

---

## 1. Executive Summary & Handoff Context

### 1.1 Handoff Alignment
Phase 0 (Baseline Freeze & Validation) was verified and complete with 0 parity discrepancies (`compare.py`), metadata integrity passing (`validate_metadata.py`), and baseline metrics recorded in `SAVE_GAME_ANALYZER_MIGRATION_BASELINE.md`.

Phase 1 establishes a **documentation-only semantic contract freeze**. It resolves the semantic ambiguities flagged in the Gap Audit (§5.2–§5.6, §6, §7, §8, §12) before any metadata, Apex, or LWC development occurs in subsequent phases.

### 1.2 Authoritative Source Hierarchy
Where the Gap Audit text and the actual legacy Python code (`Save_Game_Analyzer/*.py`) disagree, **the Python source code is authoritative**. Any discrepancies discovered during source inspection are cataloged in Section 4.

---

## 2. Phase Objectives & Scope

### 2.1 Objectives
1. Freeze canonical **unit definitions** (Daily £ vs Annual £) for every monetary and physical metric.
2. Freeze **aggregation granularity** for Artisans at `Province × Product per snapshot`.
3. Freeze the **Factory Occurrence Key** formula so multiple factories of the same building type per state are deterministically addressable without collision.
4. Freeze the **Master vs. Snapshot relationship model** for State and Province identity separation.
5. Record residual ambiguities as **open architecture-review gates** with named owners and target resolution phases.

### 2.2 Out-of-Scope Declarations
- No changes or creations of Salesforce custom objects, fields, metadata (`force-app/`), Apex classes, LWCs, DTOs, or tests.
- No changes to the parity test harness (`vc2-salesforce-version/e2e/parity/compare.py`).
- No modifications to the golden dataset fixtures.

---

## 3. Frozen Semantic Contracts

### 3.1 Canonical Unit Table

| Metric | Unit | Formula / Source | Source File & Line(s) | Zero-Guard / Clamp Guard |
|---|---|---|---|---|
| Factory Revenue | Daily £ | `last_income / 1000` | `Factory.py:47` | None |
| Factory Input Cost | Daily £ | `last_spending / 1000` | `Factory.py:46` | None |
| Factory Wages | Daily £ | `pops_paychecks / 1000` | `Factory.py:48` | None |
| Factory Profit | Daily £ | `Revenue - InputCost - Wages` | `Factory.py:49` | None |
| Factory GDP | Annual £ | `(Revenue - InputCost) * 365` | `Factory.py:53` | None |
| Factory Productivity | Annual £ / person | `Factory_GDP / Employees` | `Factory.py:65-68` | `Employees == 0 → 0.0` |
| Factory Avg Wage | Daily £ / person | `Wages / Employees` | `Factory.py:65-68` | `Employees == 0 → 0.0` |
| Factory Cash Reserves | £ | `money / 1000` | `Factory.py:50` | None |
| Factory Daily Output | Physical units | `produces` raw float | `Factory.py:51` | None |
| Factory Daily Leftover | Physical units | `leftover` raw float | `Factory.py:52` | None |
| Factory Injected Money | £ | `injected_money / 1000` | `Factory.py:53` | None |
| RGO Income | Daily £ | `last_income / 1000` | `Provinces.py:108` | Missing node → `0.0` |
| RGO GDP | Annual £ | `RGO_Income * 365` | `Provinces.py:109` | Missing node → `0.0` |
| RGO Production Qty | Physical units | `RGO_Income / Price` | `Provinces.py:130-131` | Missing price → `0.0` |
| Artisan Income | Daily £ | `production_income / 1000` | `Artisans.py:80`, `Provinces.py:121` | Missing node → `0.0` |
| Artisan Spending | Daily £ | `last_spending / 1000` | `Artisans.py:77`, `Provinces.py:116` | Missing node → `0.0` |
| Artisan AGDP | Daily £ (net) | `Income - Spending`, clamped | `Artisans.py:82-85`, `Provinces.py:123-126` | `AGDP < -1000 → 0.0` |
| Artisan Production Qty | Physical units | `Income / Price` | `Artisans.py:103-108` | Missing/Zero Price → `0.0` (Price default=1) |
| Province / State / Country Population | Headcount persons | sum of POP `size` | `Provinces.py:91-100`, `States.py:63`, `Country.py:144` | None |
| State GDP | Annual £ | `FGDP + PGDP + AGDP` | `States.py:95` | None |
| State GDP per Capita | Annual £ / person | `GDP / Population` | `States.py:98-102` | `Population == 0 → 0.0` |
| Country Core Population | Headcount persons | sum core pops (`Colony == False`) | `Country.py:141-146` | None |
| Country Colonial Population | Headcount persons | sum colonial pops (`Colony == True`) | `Country.py:149-154` | None |
| Country Total Population | Headcount persons | `Core_Population + Colony_Population` | `Country.py:158` | None |
| Country GDP | Annual £ | `FGDP + PGDP + AGDP` | `Country.py:159` | None |
| Country GDP per Capita | Annual £ / person | `GDP / Core_Population` | `Country.py:160-163` | `Core_Population == 0 → 0.0` |
| Country Commodity Output (49) | Physical units | sum of RGO + Factory + Artisan quantities | `Country.py:165-207` | None |

---

### 3.2 Artisan Aggregation Granularity Contract

- **Frozen Granularity Rule:** Artisan records are aggregated at **Province × Product per snapshot**.
- **Unique External Snapshot Key:** `<AnalysisId>_<ExternalProvId>_<ProductCode>`
  - Example: `a1B..._1720_fabric`
- **Rationale:** Storing individual artisan POP records produces ~10,000+ rows per save game analysis, creating severe Salesforce heap and governor limit constraints. Aggregating by Province × Product reduces snapshot volume to ~4,406 records while retaining 100% of physical production, spending, income, and AGDP metrics.
- **Non-Goal:** Storing individual POP-level artisan records is explicitly out of scope.

---

### 3.3 Factory Occurrence Key Contract

- **Frozen Formula:** `Unique_Snapshot_Key__c = <AnalysisId>_<StateCode>_<BuildingType>_<OccurrenceIndex>`
  - Example: `a1B..._EGY_Cairo_glass_factory_1`
- **`OccurrenceIndex` Specification:**
  - 1-based sequential integer counter.
  - Derived deterministically by order of appearance during save game parsing, matching the traversal order in legacy `Factory.py` (lines 35–42).
- **Rationale:** Victoria 2 state building blocks can contain multiple factory instances of the same `building_type` in modded save files or queued construction states. Including `OccurrenceIndex` guarantees uniqueness and prevents silent record overwrites during REST ingestion.
- **Non-Goal:** Merging or deduplicating multiple factory buildings of the same type within a state is explicitly out of scope.

---

### 3.4 Master vs. Snapshot Relationship Model Contract

Static geographic master records and point-in-time economy snapshot records are strictly separated into dedicated custom objects:

| Entity Role | Salesforce Object | Canonical Identity Key | Key Format & Example |
|---|---|---|---|
| Static Master State | `State__c` | `State_Code__c` | External ID: `<CountryTag>_<StateName>` (e.g. `EGY_Cairo`) |
| Point-in-Time State Snapshot | `State_Economy__c` | `Unique_Snapshot_Key__c` | External ID: `<AnalysisId>_<StateCode>` (e.g. `a1B..._EGY_Cairo`) |
| Static Master Province | `Province__c` | `External_Province_Id__c` | External ID: `<ProvId>` (e.g. `1720`) |
| Point-in-Time Province Snapshot | `Province_Economy__c` | `Unique_Snapshot_Key__c` | External ID: `<AnalysisId>_<ProvId>` (e.g. `a1B..._1720`) |

#### Strict Operational Rules:
1. A master record (`State__c`, `Province__c`, `Country__c`, `Product__c`) must exist at most once per canonical identity key across the entire Salesforce org.
2. A snapshot record (`State_Economy__c`, `Province_Economy__c`, `Country_Economy__c`, `Product_Economy__c`, `Factory_Economy__c`, `Artisan_Economy__c`) must exist at most once per `(AnalysisId, MasterRecord)` pair.
3. Master records are static master data and are **never mutated** by snapshot imports except through non-destructive auto-provisioning upserts (Gap Audit §13 ADR 3).

---

## 4. Audit vs. Source Discrepancies

During source inspection of `Save_Game_Analyzer/*.py` vs. `SAVE_GAME_ANALYZER_SALESFORCE_GAP_AUDIT.md`, the following discrepancies were identified and resolved (Python source is authoritative):

### Discrepancy 1: Country GDP per Capita Denominator
- **Gap Audit Statement (§5.6, §6):** States `GDPperCapita = GDP / Population` where `Population` is `Total_Population`.
- **Python Source Code (`Country.py:160-163`):**
  ```python
  if country[index]['Population'] == 0:
      country[index]['GDPperCapita'] = 0
  else:
      country[index]['GDPperCapita'] = float(format(country[index]['GDP']/x['Population'], ".3f"))
  ```
  `x['Population']` in `Country.py` is explicitly the **Core Population** (non-colonial), NOT `Total_Population`.
- **Resolution:** Python source is authoritative. `Country_Economy__c.GDP_Per_Capita__c` in Phase 3/5 calculation engine will be computed using `Core_Population__c` (falling back to `Total_Population__c` if `Core_Population__c` is zero/null or in macro-only modes).

### Discrepancy 2: Artisan Output Fallback Price
- **Gap Audit Statement (§5.4, §6):** States `Production = Income / Price` with guard `0 if Price == 0`.
- **Python Source Code (`Artisans.py:103-108`):**
  ```python
  if a == g:
      artisans[index]['Price'] = float(x['Price'])
      artisans[index]['Production'] = artisans[index]['production_income']/artisans[index]['Price']
      break
  else:
      artisans[index]['Price'] = 1
      artisans[index]['Production'] = 0
  ```
  If good price is missing or unmatched in Goods.csv, `Price` is set to `1` and `Production` is set to `0.0`.
- **Resolution:** Python source is authoritative. The calculation engine will guard against missing goods/prices by defaulting output to `0.0`.

### Discrepancy 3: State Factory Metric String Clean-Up
- **Gap Audit Statement (§5.5):** Implies direct numeric summation of Factory CSV columns for State aggregation.
- **Python Source Code (`States.py:83-85`):**
  `f_income` and `f_profit` in `States.py` require stripping `$` and `,` characters because `Factory.py` formats these fields with `locale.currency()`.
- **Resolution:** Python source behavior confirms that in Salesforce (Phase 5 pure Apex engine), all inputs are raw numeric decimals, eliminating locale string formatting/parsing bugs.

---

## 5. Open Architecture-Review Gates Carried Forward

| Gate ID | Area / Ambiguity | Proposal | Target Resolution Phase | Risk if Unresolved Before Phase 3 |
|---|---|---|---|---|
| **GATE-1** | Modded Commodity & Artisan Type Mappings | Map unknown artisan types dynamically or log diagnostic warning during ingestion. | Phase 4 (Parser DTO Contract) | High: REST ingestion could fail on unmapped artisan strings. |
| **GATE-2** | State Name Variance across Mods (HPM/GFM/Vanilla) | Use composite key `<CountryTag>_<StateName>` as immutable `State_Code__c`. | Phase 3 (Metadata Schema) | Medium: Duplicate state records if state names vary across save game mods. |
| **GATE-3** | Asynchronous Import Queue Scope for Large Saves | Queue `Factory_Economy__c` and `Artisan_Economy__c` persistence in 200-record Queueable/Batch scopes. | Phase 6 (Import Layer) | High: Governor limit exceptions (heap/DML) on large 10,000+ record save games. |

---

## 6. Contract Attestation

This semantic contract freeze is **complete and immutable**. Phase 2 (Golden Dataset Extension) and Phase 3 (Salesforce Metadata Schema) must strictly adhere to the contracts frozen in this document.
