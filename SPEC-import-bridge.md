Approved. Writing `SPEC-import-bridge.md` now, then stopping at its gate.

```markdown
# Spec: import-bridge

## Objective

Provide the read-only query surface between the already-built `.v2 → Salesforce`
import pipeline and `engine-core`. `import-bridge` owns exactly one thing:

1. **Snapshot query surface** — given a save identifier, return the in-memory
   objects `engine-core` factor models need (states, factories, POP aggregates,
   treasury, tech levels, diplomacy, military stockpiles).

`import-bridge` does **not** parse `.v2` files (the import pipeline already did),
does **not** compute metrics (that is `engine-core`), and does **not** render
(that is `shell`). Its job is to turn imported Salesforce records into clean,
immutable value objects and hand them to callers.

**User:** the builder (you), indirectly, via `engine-core` and `shell`.

**Success:** given a save id, `import-bridge` returns a `SaveSnapshot` value
object containing everything a v1 domain factor model needs, with no DML at
call time, within governor limits.

## Tech Stack

- Apex
- SOQL (read-only) against the existing imported custom objects
- No DML in `import-bridge` at call time (see Boundaries for the import case)
- No LWC, no Agentforce, no platform events

## Commands

```
Deploy:  sf project deploy start --source-dir force-app/main/default/classes
Test:    sf apex run test --test-level RunLocalTests --code-coverage
Dev:     sf project deploy start --source-dir force-app/main/default
```

## Project Structure

```
force-app/main/default/
  classes/
    SaveSnapshot.cls            → top-level immutable value object
    SaveSnapshotLoader.cls      → SOQL + assembly; the public entry point
    SaveSnapshotLoaderTest.cls
    StateSnapshot.cls           → per-state value object
    FactorySnapshot.cls         → per-factory value object
    PopSnapshot.cls             → per-state, per-POP-type aggregate
    TreasurySnapshot.cls        → treasury, debt, income/expenditure rollup
    TechSnapshot.cls            → tech levels + in-progress research
    DiplomacySnapshot.cls       → relations, spheres, alliances, infamy
    MilitarySnapshot.cls        → stockpiles, regiments, manpower
  objects/
    (existing imported custom objects — read-only here)
```

## Code Style

Value objects are immutable; construct via constructor, no setters. Same
convention as `engine-core`.

```apex
public class SaveSnapshot {
    public final String saveId;
    public final TreasurySnapshot treasury;
    public final List<StateSnapshot> states;
    public final TechSnapshot tech;
    public final DiplomacySnapshot diplomacy;
    public final MilitarySnapshot military;

    public SaveSnapshot(String saveId, TreasurySnapshot treasury,
                        List<StateSnapshot> states, TechSnapshot tech,
                        DiplomacySnapshot diplomacy,
                        MilitarySnapshot military) {
        this.saveId = saveId;
        this.treasury = treasury;
        this.states = states;
        this.tech = tech;
        this.diplomacy = diplomacy;
        this.military = military;
    }
}
```

Conventions:
- SOQL uses bind variables and explicit field lists — never `SELECT *`.
- Collections returned are unmodifiable copies.
- All numeric fields are `Decimal`, matching `engine-core`.
- No DML. SOQL only.

## Testing Strategy

- Framework: Apex `@isTest`, `RunLocalTests`.
- Coverage target: 90%, same as `engine-core`.
- Test levels:
  - **Unit** — `SaveSnapshotLoader` assembles a snapshot from seeded records.
  - **Unit** — empty save (no states, no factories) returns a valid snapshot
    with empty collections, not null.
  - **Unit** — missing-optional-field handling (e.g. no in-progress research).
  - **Integration** — `import-bridge` → `engine-core` with one domain factor
    model, proving the two contracts compose.
- Test data is seeded with DML inside `@isTest` (allowed here; the *runtime*
  path has no DML).

## Boundaries

- **Always:** SOQL read-only at call time; explicit field lists; immutable
  value objects; unmodifiable collections; return empty collections not null.
- **Ask first:** adding a new snapshot sub-object; changing `SaveSnapshot`
  shape; adding a query against an object not already in the import schema.
- **Never:** DML at call time; parsing `.v2` files (that is the import
  pipeline's job); computing derived metrics (that is `engine-core`);
  caching snapshots in static state (determinism requirement).

## Snapshot Query Surface

This is the contract `engine-core` and the six domain slices consume.

**Entry point:**

```apex
SaveSnapshot s = SaveSnapshotLoader.load(String saveId);
```

**What it returns:** one `SaveSnapshot` per save id, containing the v1 domain
inputs:

| Sub-object         | Feeds domain(s)                              |
|--------------------|----------------------------------------------|
| `TreasurySnapshot` | economy                                      |
| `StateSnapshot`    | economy, industry, rebellion, reform, colonization |
| `FactorySnapshot`  | industry                                     |
| `PopSnapshot`      | rebellion, reform                            |
| `TechSnapshot`     | war-goal, industry                           |
| `DiplomacySnapshot`| war-goal, colonization                       |
| `MilitarySnapshot` | war-goal, rebellion                          |

**Degenerate cases (must be handled, not thrown):**
- **Unknown save id:** return `null`. Caller (`shell`) is responsible for the
  "no save loaded" UI state.
- **Save exists but is empty:** return a valid `SaveSnapshot` with empty
  collections, not `null`. This is a real state — an early-campaign save — and
  factor models must handle it.
- **Fields missing on a record:** omit from the value object or default to
  `Decimal.valueOf(0)`; never `null` a numeric field that factor models read.

## Success Criteria

- [ ] `SaveSnapshotLoader.load(saveId)` returns a fully assembled snapshot
      from seeded records, covered by a unit test.
- [ ] Unknown save id returns `null`; empty save returns valid snapshot with
      empty collections — both covered by tests.
- [ ] `import-bridge` contains zero DML statements on the runtime path
      (verified by grep for `insert|update|delete|upsert` outside `@isTest`).
- [ ] Integration test composes `import-bridge` → `engine-core` with one
      domain factor model.
- [ ] All collections returned are unmodifiable (verified by test attempting
      mutation and expecting an exception).
- [ ] 90% coverage, `RunLocalTests` green.

## Open Questions

1. **Snapshot freshness.** Does `load(saveId)` re-query every call, or is a
   snapshot loaded once per session by `shell` and passed down? Default:
   `shell` loads once and passes down; `import-bridge` offers `load()` as the
   only entry point.
2. **Sub-object granularity.** Is one `StateSnapshot` per state the right
   grain, or should provinces be first-class? Default: state-level for v1;
   provinces deferred to v2 `domains-deep`.
3. **SOQL query count.** A full snapshot may exceed the 100-query governor
   limit if assembled naively. Default: assemble via a small fixed number of
   queries joined in memory; revisit if a real save exceeds the limit.
4. **Mod-swappable field mapping.** Imported objects mirror vanilla Victoria 2.
   Mods may change field names. Default: v1 hardcodes vanilla field names;
   v2 may route through `Game_Definition__mdt` field maps.
```

---

**Saved:** `SPEC-import-bridge.md` (above).

**Summary:** the read-only query surface feeding `engine-core`. Defines `SaveSnapshot` and its seven sub-objects, the `SaveSnapshotLoader.load(saveId)` entry point, and three degenerate cases (unknown id → `null`; empty save → valid empty snapshot; missing fields → defaulted, never `null`). Commits to no DML on the runtime path, immutable value objects, and unmodifiable collections.

**Open Questions:** four, above. None block approval. #1 and #3 are the ones that will matter most when `SPEC-shell.md` is written, since shell owns snapshot lifetime and the query-count budget is a real governor-limit risk on large saves.

**Per the workflow, I'm stopping here.** I will not write `SPEC-shell.md`, produce a plan, or write code in this turn. Review `SPEC-import-bridge.md` and tell me: approve, or request changes.
