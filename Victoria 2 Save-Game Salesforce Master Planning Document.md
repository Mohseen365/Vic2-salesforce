# Review: Victoria 2 Save-Game Salesforce Master Planning Document

## 1. Executive Feedback & Architectural Verdict

**Verdict: Sound foundation, ready to proceed with conditions.** The core architectural decisions are right: off-heap parsing (Gate 3), Java-as-authoritative for formulas (Gate 1/2), junction objects over direct lookups, and the "Do Not Build" list. The document is unusually disciplined about what it excludes. The main weaknesses are (a) the batch and rollup strategy is described at the *ingest* level but under-specified for *Layers 2 and 3 compute*, (b) the Layer 4 AI plan treats hallucination as a prompt problem when it is mostly a data-layer problem, and (c) several internal inconsistencies should be cleaned up before the document is treated as a contract.

**Inconsistencies to fix first**
- **Object counts:** 139 objects in §1.2, but RSK-01 says "136 objects verified deployable." Reconcile (3 objects unverified, or a stale number?).
- **Capability arithmetic:** Layer 1 is 125 + 65 + 45 + 30 = 265, which checks out, but `MET-D-*` metrics and `PLAT-D-*` items are not "capabilities" in the same sense as `CAP-*`. Consider a consistent ID scheme and acceptance-criteria template per layer, otherwise "265" is a headline number rather than a testable scope.
- **Workforce formula:** `Population = sum(popSize * 4)` appears in the matrix with no explanation. Document why (it is presumably a save-format size-to-people scaling), because it will look like a bug to any new developer.
- **Gate 1 vs. Gate 2 execution location:** Overproduction is listed as "Apex Service / Formula" (ambiguous). Pick one. Given RSK-17, pick Apex or a stored numeric field.
- **Unemployment/GDP-per-capita as formula fields on `Country_Economy__c`:** fine for a single record, but they can't be aggregated, filtered efficiently in reports, or used as Einstein Discovery features without being materialized. See recommendation 1.4.
- **Gold income:** `last_income / 1000` is a magic constant; document its source in the Java code.

---

## 2. Key Recommendations & Optimizations

### 2.1 Architecture & Governor Limits (Layers 2 and 3)

**Is scope=200 right?** For *ingest* of simple Pop rows, 200 is the safe default, but it is not universally optimal.
- 100,000 POPs at scope 200 = 500 batch executions. That is fine for async limits (flex queue holds 100 queued, 5 concurrent), but if the Python parser can POST data directly, you may not need a Salesforce-side batch at all for ingest. Better: **Python → Bulk API 2.0 (PLAT-D-024) for raw loads**, reserving Apex batch for *post-load compute*. Bulk API bypasses Apex CPU entirely and handles 100K+ rows with far less overhead than a REST endpoint doing DML in chunks.
- The REST endpoint `POST /services/apexrest/economy/import` has a **6 MB synchronous request body limit** (and 12 MB heap async). A 120 MB save as a single JSON POST is impossible. Specify explicitly: chunked, idempotent, resumable uploads keyed by `(save_id, entity_type, chunk_seq)`, with a manifest/finalize call. This is likely already implied by `EconomyImportBatch`, but the document should state it.
- Make scope **entity-specific**: POP/aggregates 200, but wide objects with many fields or triggers/flows firing may need 50–100 to avoid CPU timeouts. Make it a Custom Metadata setting rather than a constant.

**Hidden bottlenecks to anticipate**

1. **Trigger/Flow/automation on bulk load.** The biggest hidden DML cost is usually not the insert but what fires on it: triggers, flows, validation rules, duplicate rules, roll-up summary fields, and sharing recalculation. Add a **bypass mechanism** (custom permission or hierarchy custom setting) for the import user.
2. **Roll-up summary fields and master-detail locking.** If POP → Province → Country uses master-detail with roll-ups, 500 concurrent batch chunks will cause `UNABLE_TO_LOCK_ROW` on parent rows. Recommendations: use lookups plus **compute rollups in Python at parse time** (the parser already has the full dataset in memory, so aggregation there is nearly free) and write aggregates as plain numbers. Run POP batches serially (`Database.executeBatch` chain, or a parent-sorted order) where parent contention exists.
3. **Aggregate queries over POP in Layer 2/3.** Many cross-domain metrics (`CAP-D-011` to `CAP-D-015`, `CAP-D-036` to `CAP-D-045`) need POP breakdowns by culture × religion × type × ideology × province. `GROUP BY` on 100K rows is OK in a single transaction only up to the 50,000-row SOQL row limit (and aggregate queries count each underlying row toward it in many cases). **Do not compute these from raw `Pop__c` in Apex at read time.** Have the parser emit pre-aggregated cubes (see 2.2).
4. **Heap in cross-domain joins.** Layer 2 combines Economy × Politics × Military × POP. Loading five entity sets into maps in one transaction will approach the 6 MB sync heap limit when multiplied across many countries (≈ 250+ tags). Compute per-country in a **batch with scope = 1 country** (or small N), or push compute into the Python parser/pre-processing tier for deterministic cross-domain metrics and store results.
5. **Layer 3 forecasts and network metrics.** Betweenness centrality (`MET-D-024`), cluster coefficients, and similar graph metrics are O(n·m) or worse and are CPU-expensive in Apex. Compute these **in Python (NetworkX) at ingest** and store results. Apex is the wrong place for graph algorithms. The same applies to linear-regression trends across 12 snapshots: trivial in Python, awkward in Apex.
6. **Multi-save compare (`FEAT-15`, 12-snapshot cap).** The cap is good, but make sure the cap applies to *rows returned*, not just snapshot count: 12 snapshots × 250 countries × N metrics can be large. Store a **narrow, long-format `Metric_Snapshot__c`** table (save, entity, metric_key, value) for time series rather than reading wide objects 12 times.
7. **Formula fields (RSK-17).** Beyond compile size, cross-object formula fields hurt report performance and selective-query behavior, and can't be indexed. Prefer **materialized numeric fields written at ingest** for anything you will filter, sort, chart, or feed to ML.
8. **Data volume and storage.** 100K POPs × 12 snapshots × multiple campaigns = millions of rows quickly, and Salesforce data storage (2 KB/record minimum) is expensive. 1M records ≈ 2 GB. Plan a **retention/archival tier** (Big Objects, Data Cloud, or just drop raw POPs after rollup). Do you actually need raw POPs persisted at all beyond the latest snapshot? Possibly keep raw POPs only for the "active" save and rollups for history.
9. **Platform Event limits.** Beyond RSK-18's daily quota, high-volume platform events publishing during batch loops can hit per-transaction publish limits. Publish *one* event per import (not per chunk) plus threshold-based anomaly events.
10. **Idempotency and re-import.** The document doesn't describe what happens when the same save is imported twice or an import fails mid-way (partial data in 139 objects). Add an **import-run header record with status**, and make all child data keyed to it so that failed imports are cleanly rolled back by deleting by `Import_Run__c`. Deleting 100K rows also needs a batch (and `Database.emptyRecycleBin` or hard-delete consideration).

**Pre-aggregated rollup requirement: validated, with refinements**
- Define the **canonical aggregation grains** up front: (country), (country × POP type), (country × culture), (country × religion), (country × ideology), (province), (state), (country × province × type). Anything outside these grains must be requested as a new rollup, not computed ad hoc.
- Version rollups with a `Rollup_Schema_Version__c` so parser changes don't silently mismatch Apex readers.
- Store a **checksum/row-count reconciliation**: sum of rollup population must equal parser-reported total. Add this as an automatic post-import validation.

### 2.2 AI Layer: Anti-Hallucination Patterns (FEAT-20, PLAT-D-004 to 007)

**Core principle: the LLM should never be the source of a number.** It should be the *narrator and router* of numbers computed deterministically by Apex.

1. **Tool/action-based grounding (primary pattern).** Expose Agentforce **Actions** (invocable Apex) like `getCountryTreasury(saveId, tag)`, `getBrigadeCount(saveId, tag, type)`, `getTopGoodsByGDP(saveId, tag, n)`, each returning a strict typed DTO. The agent is instructed to answer *only* from action outputs. Avoid RAG-over-text for numeric facts; use it only for narrative/mechanics explanations.
2. **Numeric-fidelity output contract.** Have the prompt template require that every number in the response be accompanied by a source field key, e.g. `[treasury: £1,234,567.89 | src: Country_Economy__c.Treasury__c | save: 1864-03-01]`. Then add a **post-generation validator** (Apex or Prompt Builder output handler) that extracts numbers from the response and verifies each exists in the action payload (within formatting tolerance). Reject or regenerate on mismatch.
3. **Pass pre-formatted display strings**, not raw floats. Round and format in Apex (`"£1,234,567"`), so the LLM copies rather than reformats. LLMs frequently corrupt long numbers, units, and decimals.
4. **Always include save identity and date in the grounding payload** (save ID, in-game date, import timestamp). Most "wrong number" complaints in multi-save systems are actually wrong-save/wrong-date answers.
5. **Explicit unknown/empty handling.** Return `{"status":"NOT_AVAILABLE","reason":"..."}` rather than null, and instruct "if status is NOT_AVAILABLE, say so; do not estimate."
6. **Separate fact vs. interpretation sections.** Require the response format: *Facts (from data)* / *Interpretation (model inference, labeled as such)*. This also helps users trust derived metrics like HDI that are heuristic.
7. **Restrict the topic scope** to the active save/country context; refuse game-mechanics claims beyond a curated, versioned knowledge base (e.g., a Victoria 2 mechanics glossary stored as Knowledge articles). Vanilla vs. mod differences make "mechanics from model memory" risky: mods change formulas.
8. **Evaluation harness.** Build a **golden Q&A test set against `egypt.v2`** (e.g., 100 questions with exact expected values) and run it on every prompt/model change. This is the AI equivalent of your protected-economy hash check, and the document currently lacks it.
9. **Temperature and determinism:** low temperature for stat queries; consider a two-step flow (router → action → narrator).
10. **Audit trail.** Log prompt, action calls, payloads, and response in an `Agent_Interaction_Log__c` for debugging disputed answers (Einstein Trust Layer audit helps, but you want domain-level trace).

**Einstein Discovery (PLAT-D-004/005) precautions**
- RSK-09's "synthetic data" fallback is dangerous: models trained on synthetic data learn the generator, not Victoria 2. Prefer **deterministic scoring (MET-D-015/041) as the official output**, and treat ML as an *optional, clearly labeled* experiment until you have real multi-save history.
- **Target leakage:** rebellion-risk models trained with features like current militancy or rebel count will "predict" what's already visible. Define the prediction horizon (e.g., rebels active N months later) and exclude contemporaneous outcome-correlated features.
- **Sample size / independence:** a few campaigns × ~250 countries gives correlated rows (same country across snapshots). Split train/test **by campaign**, not randomly by row.
- **Mod/version dependence:** record game version/mod set as a feature or segment; otherwise coefficients are meaningless across versions.
- Einstein Discovery needs a flat, materialized dataset: another reason to materialize Layer 3 metrics rather than leave them as formulas.

### 2.3 Blind Spots & Missing Capabilities

The capability map is broad, but some core Victoria 2 mechanics are thin or absent. Prioritized by analytical value:

**Economy / World Market**
- **World Market crisis triggers and crisis state tracking.** `FEAT-14` is "Crisis & Colonial Manager," but the capability list doesn't clearly enumerate crisis *mechanics*: crisis tag/state, involved parties, backers (crisis attackers/defenders), temperature/progress, crisis-war-goal resolution. Add explicit capabilities: **crisis timeline, participant alignment, escalation-to-war linkage** (ties to `CAP-D-056`+).
- **Price-formation and supply/demand drivers**: actual price vs. base price decomposition, stockpile/"sold vs. produced" and **artisan production vs. factory production share per good**. Overproduction % exists, but nothing on *why* a price moved (supply/demand ratio over time, trade-good shortage waves).
- **Factory profitability and construction/closure decision signals**: per-factory profit, input shortage, subsidies (`CAP-D-*` partially touch this), **capitalist investment flows** and **priority/bankruptcy risk per factory.** Factory-level outliers exist in MET-D-027 but not profitability/closure.
- **Tariffs, taxation, and budget breakdown:** `FEAT-03/05` touch on this, but a full **budget ledger** (income by source, expenditure by category: education/admin/military/social/stockpile, settings like "tax slider" vs. effective collection) is the single most useful macro screen in Vic2 and should be an explicit capability.
- **Stockpile and national-focus/"stockpile" mechanics, and Gold/credit:** loans (`bank loans / interest`), national bank, **bankruptcy event history**. MET-D-042 (insolvency risk) needs these inputs; confirm they're in the data model.
- **Trade-good production by RGO type and "employment" cap** (`RGO max/actual workers`): RGO productivity is in MET-D-014 but employment slack by good isn't enumerated.

**War & Diplomacy**
- **Great War peace-treaty resolution tracking:** war goal outcomes, **peace offers (offered/accepted/rejected), score and war score per side, status quo/white peace, goal fulfillment, annexations/ceded provinces/war indemnity, post-war truce start**. The document tracks wars and battles but not the *negotiated outcome pipeline.* Add capability set: peace-offer history, war-score decomposition (battles, occupation, blockade), war exhaustion by participant, and post-war border/ownership delta.
- **Alliance/call-to-arms dynamics:** `CAP-D-056` covers honor rate. Add **alliance reliability index**, **who's participating by side with power-balance (industrial + military) across the war,** and **sphere-leader obligations**.
- **Great power ranking and prestige:** Great Power rank (industrial/military/prestige score components), **prestige** sources, and **civilization status/"civilized" threshold with tech/unciv reforms**: this drives most diplomatic/colonial options and is conspicuously absent. Add **Great Power rank/score tracker, prestige timeline, civilised/uncivilised reform progress (Westernization)**.

**Colonial / Migration**
- **Colonial migration attraction and POP migration/immigration/emigration formulas:** requested in your question. The doc has `CAP-D-028` (colonial migration push) and `MET-D-045` (refugee pressure) but not the underlying mechanics: **migration targets, "attractiveness" by province (jobs, wages, liberty/foreign-immigration allowance), emigrants by origin→destination country and by culture/POP type**. Caveat: only implement formulas you can verify against game files/mod data; otherwise label as *observed* (from deltas between snapshots), not predictive.
- **Colonization race tracking:** colonial-state progress, colonial points, **colonial life-rating / protectorate / colonial-power competition by region**. Partially in `FEAT-14` but not as a capability set.
- **Assimilation and conversion:** `CAP-D-064` handles assimilation rate; add **conversion (religion)** and **accepted/non-accepted culture** effects on militancy and tax/consumption.

**Tech / Politics / POP**
- **Technology & invention tracking:** inventions, research points, leadership/literacy-driven research rate, tech school choice, **tech-share vs. "sphere of influence"/prestige**. Only `CAP-D-061/062` touch tech. Consider a dedicated tech/invention capability set (research progress, techs unlocked, technology-school, invention timeline, **industrial-overpowered Great Power gaps**).
- **Political reform/decision/event history and party-ruling dynamics:** reforms exist; **decisions, event firing history, and ruling-party change timeline** do not.
- **Leaders and generals/admirals:** commander traits, prestige, **leader assignment to armies**: a commonly queried item in OOB explorers (`FEAT-06`) and usually inexpensive.
- **Culture/union/nationalism and cores:** **cores by country, national-focus, Pan-nationalist (union) tags, release-nation possibilities** (liberation/puppeting/sphere-diplomacy), and **crisis- and casus-belli-generation from cores**. This drives most diplomatic play.
- **Mod/version-awareness capability:** a mod-agnostic **Game Definition layer** (goods list, POP types, techs, tags vary by mod). Hardcoded POP type names (e.g., `farmers, labourers, slaves, serfs`) in your formula matrix will break with mods or different DLC content; load definitions from config/Custom Metadata.

**Platform-level blind spots**
- **Data lineage & import-run provenance** (what save, which parser version, which ruleset).
- **Parity regression suite**: a standing automated comparison of Salesforce outputs vs. Java for `egypt.v2` and at least 2 more saves (different era, much larger, heavy-war, different mod).
- **Save-version/format drift**: parser versioning, and handling of Victoria 2 *HPM / HFM / vanilla / Divergences*-style format differences.
- **Observability:** import metrics dashboard (rows, time, failures per entity), Apex exception log, parser error report, and anomaly rates.
- **Accessibility, localization, and user docs** (e.g., metric definitions: every derived metric should have an in-app "how computed" tooltip, which is also an anti-confusion measure for HDI/IPS/etc.).

---

## 3. Proposed Adjustments to Roadmap / Build Order

**Current:** FEAT-01 → FEAT-05 → FEAT-06 → FEAT-17 → FEAT-08.

**Assessment:** FEAT-01 first is right. But the sequence has two issues:
1. **FEAT-17 (cross-domain engine) is sequenced before it has proven inputs**, and it depends on Economy × Politics × Military × POP being *validated in isolation*. Its value is high, but its failure modes (heap, joins, rollup mismatches) are exactly what you want to discover early on a small slice.
2. **FEAT-06 (Military OOB)** is Medium effort but **Medium risk** with large row counts (brigades/armies/ships), and it's less connected to your protected economy "core strength" than FEAT-02/03.

**Recommended sequence**

| Phase | Features | Rationale |
|---|---|---|
| **Phase 0 (Foundation, before UI)** | Import-run header + idempotent chunked ingest + rollup grains + reconciliation checks + parity regression harness + `Game_Definition` metadata layer | De-risks RSK-02/04 and creates the test spine. Without it, every later feature carries untested data-integrity risk. |
| **Phase 1 (Thin vertical slice)** | `FEAT-01` Save Header → `FEAT-03` Macro Ledger → `FEAT-02` Market Visualizer | Directly extends the proven, protected economy core, gives users immediate value, and tests Java-parity end-to-end on the golden dataset. Both are S/M effort and LOW risk. |
| **Phase 2 (Prove cross-domain on a narrow slice)** | `FEAT-17-lite`: **5 high-value cross-domain capabilities** (e.g., `CAP-D-001` tax impact, `CAP-D-006` maintenance ratio, `CAP-D-011` literacy productivity, `CAP-D-016` GDP war decline, `CAP-D-021` sphere market capture) | Validates the compute pattern (batch-per-country, materialized results, rollups) before scaling to 65. Use as a go/no-go on the architecture. |
| **Phase 3 (Breadth of single-domain)** | `FEAT-05` Politics → `FEAT-08` Sphere & Focus → `FEAT-06` Military OOB (with virtual scrolling + pagination) | Politics and Sphere both feed Layer 2; Military is saved until compute patterns and virtual-scroll components are proven. |
| **Phase 4 (Full Layer 2 + Layer 3)** | Remaining `FEAT-17`; `FEAT-18` metrics. Compute graph/forecast metrics in Python at ingest | Layer 3 relies on a stable Layer 1 and 2 data foundation. |
| **Phase 5 (Layer 4, staged by risk)** | `FEAT-19` Alert Hub (cheap, high value) → `FEAT-20` Agentforce with action-grounding + eval harness → `FEAT-22` Experience Cloud → `FEAT-21` Data Cloud last | Data Cloud is XL/HIGH risk, high cost, and depends on all data being stable. |

**Other roadmap notes**
- **`FEAT-04` (POP Demographics, XL/HIGH)** has no slot in the Top 5, but nearly all cross-domain POP capabilities (`CAP-D-011` to `-015`, `-031` to `-045`) depend on it. Define a **minimal "POP rollup layer" in Phase 0** (not the full explorer UI) so Layer 2 isn't blocked.
- **`FEAT-15` Multi-Save Comparison** is a major differentiator and reuses existing assets (`c-multi-save-trend`, `c-analysis-compare`). Consider pulling it earlier (Phase 2/3), since it is largely reuse.
- **Define "done" per feature**: acceptance criteria with parity tolerance (e.g., economy values match Java to 1e-6), performance budget (page load < X s, import time < Y min for 120 MB), and test coverage thresholds.
- **Cut line:** with 265 capabilities, declare a **v1 scope** (suggest: all of Layer 1 core, ~15–20 of Layer 2, ~12 of Layer 3, `PLAT-D-001/002/006`) and mark everything else as "post-v1" so progress is measurable.

---

## 4. Suggested Additions to Risk Mitigation

| New Risk | Severity | Mitigation |
|---|---|---|
| **RSK-19: Partial/failed import leaves inconsistent data** | High | Import-run header, status machine (`Staged → Loaded → Validated → Published`), only publish after reconciliation checks pass; cleanup batch by `Import_Run__c`. |
| **RSK-20: Parent-row lock contention during parallel batch loads** | High | Serial or parent-ordered batches; pre-aggregate in parser; avoid master-detail roll-ups on hot parents; retry on `UNABLE_TO_LOCK_ROW`. |
| **RSK-21: REST payload/size limits (6 MB sync)** | High | Chunked uploads with manifest; or Bulk API 2.0 for raw loads; document max chunk size. |
| **RSK-22: Data storage cost / org limits** | Medium–High | Retention policy, raw-POP pruning after rollup, Big Objects/Data Cloud tier, storage monitoring alerts. |
| **RSK-23: Parser/save-format drift and mod incompatibility** | High | Parser version stamped on each import; Game Definition metadata layer; compatibility test saves (vanilla, HPM, a heavily modded save); fail loudly on unknown structures. |
| **RSK-24: Derived-metric misinterpretation (HDI, IPS, etc.)** | Medium | In-app metric definitions, formula versioning, "heuristic" labeling, and unit tests per metric with golden values. |
| **RSK-25: AI numeric hallucination / wrong-save answers** | High (supersedes/extends RSK-10) | Action-grounded agent, number-verification post-processor, save/date in every payload, golden Q&A eval suite, interaction audit log. |
| **RSK-26: ML target leakage / synthetic training bias** | Medium | Deterministic scoring as the system of record; ML labeled experimental; campaign-level train/test splits; no synthetic training. |
| **RSK-27: Cross-domain compute scalability** | Medium–High | Prove with the Phase 2 slice; scope=1–N-country batches; materialize results; compute graph/forecast metrics in Python. |
| **RSK-28: Parity drift over time** | High | Automated Java-vs-Salesforce regression suite on multiple saves in CI; protected-hash check extended to formula-config files. |
| **RSK-29: Scope creep (265 capabilities)** | Medium | Declare v1 cut line; per-capability acceptance criteria; stage-gate reviews after each phase. |
| **RSK-30: Single-user admin assumption** | Low–Medium | Permission sets exist; also test *as* a limited-permission user (FLS, sharing) so future multi-user doesn't surface surprises, particularly before Experience Cloud (RSK-14). |

**Adjustments to existing risks**
- **RSK-02:** Add "lock contention" and "trigger/flow overhead" to the description; mitigation should include automation bypass and parser-side aggregation.
- **RSK-03:** The 12-snapshot cap should also bound *rows returned*; use a narrow long-format metric table.
- **RSK-09:** Remove "synthetic dataset" as a recommended fallback; make deterministic scoring the primary path.
- **RSK-10:** Upgrade from prompt templates alone to action-grounded retrieval plus numeric verification (see §2.2).
- **RSK-17:** Extend beyond compile size to report/selectivity issues; adopt "materialize anything filterable or chartable."
- **RSK-11/RSK-12:** Quantify. Provide estimated record volume and cost per retained campaign so the "5-campaign" policy is evidence-based.

---

### Summary of the highest-impact changes
1. **Add a Phase 0** (idempotent chunked ingest, rollup grains, reconciliation, parity regression harness).
2. **Move heavy analytics (graphs, forecasts, cross-domain joins) to the Python tier** and store materialized results; keep Apex for orchestration and light compute.
3. **Re-sequence** to prove Layer 2 on a narrow slice before building the full engine, and pull the POP rollup layer forward.
4. **Ground the AI via actions plus a numeric verifier plus a golden eval set**, not prompts alone.
5. **Fill capability gaps** in crisis mechanics, peace-treaty resolution, Great Power/prestige/civilization status, budget ledger, technology/inventions, migration, and mod-agnostic game definitions.

If useful, I can draft the Phase 0 ingest design (manifest/chunk protocol, import-run state machine, rollup schema), or write a prompt-template and action spec for the Agentforce grounding pattern.
