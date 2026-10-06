# Victoria 2 Command Center: UX/UI Possibility Map & LWC Component Architecture

## 0. Design Principles

| Principle | Implication |
|---|---|
| **Question-first, not table-first** | Users arrive asking "why is my economy stalling?", not "show me `Country_Economy__c`". Navigation is organized by *questions* (Layers 2 and 3) as well as by domains (Layer 1). |
| **Three-level progressive disclosure** | **Glance** (KPI and headline) → **Explore** (interactive chart) → **Evidence** (table, formula, source record). No screen starts at Evidence. |
| **Max 4 visual encodings per chart** | Position, color, size and time. A fifth variable goes into a tooltip or a linked panel. |
| **Context is global and linked** | Save, snapshot date, country and comparison set live in one shared context. Every widget reacts to it. |
| **Never color alone** | Pair color with shape, arrow or label (accessibility and colorblind safety). Use a diverging palette that stays distinguishable under deuteranopia. |
| **Show provenance** | Every derived number is one click from its formula, version and source fields. Derived metrics carry a "heuristic" badge. |
| **Grand-strategy mood on SLDS rails** | Use SLDS grid, tokens, utilities and base components. Theming goes through SLDS styling hooks and CSS custom properties, not forked SLDS CSS. |

**Theme modes**
- **Ledger** (light): parchment neutrals, ink-blue accents, gold highlights. For analysis and reading.
- **War Room** (dark): slate/charcoal, desaturated reds/teals, glow for alerts. For war and crisis monitoring.
- **Density toggle:** Comfortable / Compact (SLDS `slds-p-around_*` scale swapped via a class on the shell).

---

## 1. Master Workspace Layout & Shell (`c-save-game-analyzer-shell`)

### 1.1 Zone Map

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ A. GLOBAL CONTEXT BAR                                                                │
│ [≡] [🏴 EGY ▾] 1864-03-01 ▾ │ Save: egypt.v2 │ ⏱ Δ vs [1861-01-01 ▾] │ 🔍 ⌘K │ 🔔3 │ 💬 │
│ KPI strip: Treasury £1.2M ▲2.1% │ GDP £… ▲ │ GDP/cap │ Prestige │ GP Rank │ Mil. │ ⚠ │
├────────┬─────────────────────────────────────────────────────────────┬───────────────┤
│ B.     │ C. WORKSPACE TABS  [Overview ✕][Market ✕][Wars ✕][+]        │ E. UTILITY    │
│ LEFT   │ ┌─────────────────────────────────────────────────────────┐ │    DRAWER     │
│ RAIL   │ │ D. VIEW TOOLBAR: breadcrumbs · filters · view mode ·    │ │ (tabs:        │
│        │ │    export · pin · split                                 │ │  Alerts /     │
│ Domain │ ├─────────────────────────────────────────────────────────┤ │  Advisor /    │
│ groups │ │                                                         │ │  Inspector /  │
│        │ │            ACTIVE DASHBOARD (grid of cards)             │ │  Notes)       │
│        │ │                                                         │ │               │
│        │ └─────────────────────────────────────────────────────────┘ │               │
├────────┴─────────────────────────────────────────────────────────────┴───────────────┤
│ F. STATUS BAR: import status ● · parser version · rollup schema v · last refresh     │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Global Context Bar (`c-global-context-bar`)

- **Save selector:** typeahead over saves (campaign, date, player). It shows a status chip (`Published` / `Validating` / `Failed`) from the import-run state, so unvalidated data is never silently displayed.
- **Snapshot scrubber (mini):** a compact slider/segmented control over the 3 to 12 snapshots, with event ticks (war start, reform, crisis). Changing it re-scopes the entire workspace.
- **Country switcher:** flag + tag + name, with a "Player", "Great Powers" and "Pinned" quick list. Selecting a non-player country puts the workspace in **Observer mode**, with a persistent banner and a tinted bar so users never confuse perspectives.
- **Compare baseline:** a "Δ vs…" selector (previous snapshot, first snapshot, pinned snapshot, another country). Every KPI delta and every delta-enabled chart uses this one baseline.
- **KPI strip (`c-kpi-ribbon` + `c-kpi-tile`):** 6 to 8 user-configurable tiles. Each tile shows a value, a delta arrow with %, a 12-point sparkline and a status dot. Click a tile to open that metric's detail tab; hover for formula and source. Defaults: Treasury, GDP, GDP/capita, Prestige, GP rank, Unemployment, Avg militancy, Sovereign risk (`MET-D-042`).
- **Flags:** a `c-flag-badge` resolves `tag → static resource` (flag zip). It falls back to a deterministic generated badge (tag initials on a hash color) for unknown or mod tags, so a missing asset never breaks layout.

### 1.3 Left Rail Navigation (`c-nav-rail`)

Collapsible (icon-only ↔ labeled), grouped by intent, with badges for live counts:

| Group | Items (feature) |
|---|---|
| **Command** | Overview (home dashboard), Save Header & Settings (`FEAT-01`) |
| **Economy** | Market (`FEAT-02`), Macro Ledger (`FEAT-03`), State Inspector (`FEAT-16`) |
| **Society** | POP Demographics (`FEAT-04`), Politics & Reforms (`FEAT-05`), Rebels (`FEAT-12`) |
| **Power** | Military OOB (`FEAT-06`), Wars (`FEAT-10`), Battles (`FEAT-11`) |
| **Foreign** | Diplomacy (`FEAT-09`), Sphere & Focus (`FEAT-08`), Colonies & Crises (`FEAT-14`), AI Matrix (`FEAT-07`) |
| **Intelligence** | Cross-Domain Lenses (`FEAT-17`), Metric Suite (`FEAT-18`), Anomalies |
| **Time** | Compare Suite (`FEAT-15`), Timeline |
| **Archive** | Newspaper (`FEAT-13`), Community (`FEAT-22`) |

Tab-launch behavior:
- Click opens or focuses a tab (no duplicates unless Shift-click, which opens a second instance for side-by-side use).
- **Pin tab** keeps it fixed and unclosable. **Split tab** sends it to a second pane (`c-workspace-split`), a 50/50 or 70/30 divider with the pane context optionally *unlinked* so each pane holds a different country or date.

### 1.4 Workspace Tabs & Context Plumbing

- **`c-workspace-tabs`** is a custom tab manager (not `lightning-tabset`, which eagerly renders). It keeps a registry `{tabId, componentKey, params, lastActive}`. Only the active tab is mounted; inactive tabs are **unmounted but state-snapshotted** (scroll position, filters, selection) into the store, then restored.
- **Dynamic loading:** use lazy rendering with `lwc:if` plus dynamic components (`lwc:is`) for the component registry. Confirm availability and limits on your API version; fall back to a static `switch` of `lwc:if` blocks if needed.
- **Context store (`c-context-store`, JS module singleton) + Lightning Message Service channel `SaveContext__c`:**
  ```
  { saveId, snapshotId, snapshotDate, countryTag, observerMode,
    baselineType, baselineRef, compareSet[], theme, density, rollupSchemaVersion }
  ```
  Child components subscribe once, never poll. Changing context fires a single batched event, and components decide whether to refetch (see §6 caching keys).
- **Deep links:** URL state via `NavigationMixin` page-reference state (`c__tab`, `c__country`, `c__snap`). Anything shareable (a chart view, a comparison) can be pasted into Slack or Chatter. This is also the target of alert "Investigate" buttons.
- **Command palette (`c-command-palette`, ⌘/Ctrl+K):** fuzzy search across countries, provinces, goods, wars, treaties, metrics and actions ("Compare to GBR", "Open Rebel Monitor", "Export view"). It is also the accessibility shortcut layer.
- **Keyboard map:** `G` then `E` = Economy, `[`/`]` = prev/next snapshot, `C` = toggle compare, `A` = alerts, `/` = advisor, `?` = shortcut overlay.

### 1.5 Overview Home (`c-command-overview`)

A "morning briefing" screen made of 6 to 8 cards on a 12-column SLDS grid:

1. **Situation headline:** a templated one-sentence summary generated in Apex (not an LLM), e.g. "GDP +4.2% since 1861; unemployment risk rising in 3 states."
2. **Top movers:** 5 biggest positive and negative deltas across all domains.
3. **Alerts digest:** the top 3 open alerts.
4. **War status mini-strip:** active wars with war-score bars.
5. **Composite scorecard:** HDI, IPS, MSC, and Sovereign Risk as small gauges.
6. **Rank snapshot:** GP rank and industrial/military/prestige sub-ranks with trend arrows.
7. **Pinned lenses:** the user's saved cross-domain lenses.
8. **Import and data health:** reconciliation pass/fail, parser version.

---

## 2. Domain Dashboards & Component Patterns

### 2.1 Global Market & Economy Dashboard (`FEAT-02/03`)

```
┌ TICKER TAPE ───────────────────────────────────────────────────────────────┐
│ Iron £4.1 ▲3.2% │ Grain £2.3 ▼1.1% │ Steel £… │ Coal … │ (pause on hover) │
├──────────────────────────────────┬─────────────────────────────────────────┤
│ GOODS HEATMAP                    │ GOOD DETAIL (on select)                 │
│ metric: [Price/Base ▾]           │ price history (snapshot line)           │
│ rows=goods  grouped by category  │ supply vs demand bullet                 │
│ ■■■□■■□□■  ■ = hot (over/under)  │ top producers / consumers               │
│                                  │ artisan vs factory share (stacked)      │
├──────────────────────────────────┴─────────────────────────────────────────┤
│ GDP TREEMAP (goods by GDP contribution)   │  MACRO LEDGER / BUDGET WATERFALL │
└────────────────────────────────────────────────────────────────────────────┘
```

**Components**
- **`c-price-ticker`:** CSS-transform marquee. It respects `prefers-reduced-motion` (falls back to a static horizontally scrollable chip list), pauses on hover/focus, and shows ▲/▼ plus % so color isn't the only cue. Items click through to the detail pane.
- **`c-goods-heatmap`:** canvas-rendered grid (≈50 to 80 goods × 3 to 6 metrics is small enough for SVG, but canvas keeps hover cheap if you add time columns).
  - **Metric switcher:** Inflation % (`price/basePrice`), Overproduction % (`supply/demand`), Real demand, Total supply, GDP contribution.
  - **Diverging scale** centered on neutral (100% inflation or 100% overproduction), with legend and numeric labels in cells at Comfortable density.
  - **Category grouping** (raw, industrial, consumer, luxury) with sticky group headers.
- **`c-supply-demand-bullet`:** a bullet chart per good (bar = supply, marker = demand, bands = shortage/balanced/glut) in a sortable list. This is much more scannable than paired bars.
- **`c-gdp-treemap`:** treemap by `ProductStorage` GDP (£), where color encodes delta vs baseline. It shows the composition of GDP at a glance, and `goldIncome` appears as a distinct tile so the Gate 2 formula is visible rather than hidden.
- **`c-budget-waterfall`:** income sources → expenditures → net, as a waterfall (the "macro ledger" screen the Vic2 player lives in). Add a slider-state marker (set vs effective) for taxes.
- **Price-driver decomposition (new capability suggested in the review):** a small "Why did this price move?" panel showing the supply/demand ratio over snapshots, plus the top contributing producers.

### 2.2 Country Politics & POP Demographics Explorer (`FEAT-04/05/12`)

**Politics dashboard (`c-politics-dashboard`)**
- **Parliament arc (`c-parliament-arc`):** a semicircle dot-chart of upper-house seats by party, colored by ideology, with a ruling-party marker and a "majority threshold" line.
- **Reform ladder (`c-reform-ladder`):** one horizontal stepper per reform category (voting rights, press, trade unions...), the current step highlighted and the next step showing the backing POP strata and estimated militancy effect (`CAP-D-001`, `CAP-D-044`).
- **Party economic stance matrix:** a parties × policies dot grid (`CAP-D-003`).

**POP Explorer (`c-pop-explorer`) works only against pre-aggregated rollups.** Drill path: **Country → State → Province (top-N)**, never raw POP rows. A breadcrumb shows the current grain, and an info chip shows "Rollup grain: country × culture × type, schema v3".

| Visualization | Component | Notes |
|---|---|---|
| **Ideology breakdown** | `c-ideology-stack` | 100% stacked bar per POP type (rows) × ideologies (segments). Toggle to population-weighted or absolute. Delta mode overlays shift arrows vs baseline. |
| **Literacy × Militancy matrix** | `c-pop-bubble-matrix` | Matrix of POP type (rows) × culture or religion (columns); bubble size = population, bubble fill = militancy, bubble ring = literacy. Click a bubble to open an inspector drawer. Switch to a scatter (x = literacy, y = militancy, size = pop) from the same data. |
| **Social mobility funnel** | `c-mobility-sankey` | Sankey from strata (Poor → Middle → Rich) and POP type flows (e.g., farmers → labourers), derived from **snapshot deltas**, labeled "Observed change", not a game formula. Hide flows under a threshold; group the tail into "Other". |
| **Wealth/needs** | `c-needs-gauge-grid` | Life/everyday/luxury needs satisfaction as three-segment gauges per POP type. |
| **Unemployment** | `c-employment-split` | RGO vs Factory workforce/employment as paired bullets, using the formula-matrix fields (materialized, not recomputed in the client). |
| **Geographic distribution** | `c-state-cartogram` | State tile-map colored by selected demographic metric (see §2.3 for map approach). |

**Rebel Monitor (`c-rebel-monitor`)**
- A rebel-type lane chart with active rebel counts and militancy-surge sparkline per state.
- A **threat strip** at top: "Rebellion risk index: 62 (↑9) — drivers: Unemployment, Consciousness, War exhaustion" (contribution bars from `MET-D-041`).

### 2.3 Military OOB & Active War Command Center (`FEAT-06/10/11`)

**Map approach (decision needed).** No game map exists in Salesforce, so three options, in ascending cost:
1. **State tile cartogram** (recommended for v1): each state is one square or hex tile, positioned by a precomputed layout stored in a static resource. Python can compute it from province centroids at ingest. It is cheap, readable and has no zoom.
2. **Region grid** (continent → region → state grouping): no geography, just structure. Cheapest fallback.
3. **Static SVG province map** generated by the Python tier from the game's map data (simplified paths, ≈ 500 KB to 2 MB). Richest, but heavy; load lazily and render shapes as one `<path>` per state, not per province.

**OOB Explorer (`c-oob-explorer`)**
- **Left:** a virtualized tree (`c-virtual-tree`): Army → Division → Brigade (and Fleet → Ships), showing strength bars, morale and supply. Counts and rollups appear on collapsed rows (e.g., "Army 3 · 42,000 men · Org 78%").
- **Center:** the force-distribution cartogram, with tile glyphs or a size-scaled disc by troop count and a ring color by army allegiance. Hovering shows a mini-card.
- **Right:** a unit composition panel (stacked bars by unit type), leader card (traits, prestige, assignment), and a maintenance ratio dial (`CAP-D-006`).
- **Filters:** by army, unit type, tech tier, location, readiness (low morale/org flagged).

**War Command Center (`c-war-command-center`)**

```
┌─ WAR HEADER ─────────────────────────────────────────────────────────────────┐
│ 🏴EGY ◄████████░░░░░░▲░░░░░░░░░░► 🏴TUR   WAR SCORE +34  │ Day 412 │ Truce: —  │
├───────────────┬───────────────────────────────────┬──────────────────────────┤
│ SIDE A ROSTER │ BATTLE MAP / CARTOGRAM            │ SIDE B ROSTER            │
│ participants  │ fronts highlighted, battles ⚔     │ participants             │
│ power share   │                                   │ power share              │
├───────────────┴───────────────────────────────────┴──────────────────────────┤
│ CASUALTY COUNTERS  [ KIA A 12,410 ][ KIA B 18,203 ][ Ratio 1:1.47 ] [Cost/loss]│
│ ATTRITION CHART (line: strength by side over snapshots, battle markers)       │
│ WAR GOALS & PEACE PIPELINE (stepper: offers → score → treaty → truce)         │
└───────────────────────────────────────────────────────────────────────────────┘
```

- **Tug-of-war bar (`c-war-score-bar`):** a center-anchored bar with directional marker; it shows score decomposition on hover (battles, occupation, blockade).
- **Side rosters:** participant chips with power share (industrial + military) and war exhaustion mini-bars, plus an **alliance reliability** badge (`CAP-D-056`).
- **Casualty counters (`c-stat-counter`):** big-number tiles with count-up animation (disabled for reduced motion, and animated only on first mount, never on scroll or re-render). Include cost efficiency (`MET-D-035`).
- **Attrition chart:** dual-line (strength by side per snapshot) with battle markers sized by casualties. Clicking a marker opens the battle detail drawer.
- **Battle timeline (`c-battle-timeline`, `FEAT-11`):** a horizontal swimlane per theater, battle glyphs positioned by date, win/loss shown by glyph shape *and* color. Zoom with wheel/pinch and an overview brush underneath.
- **Peace pipeline (`c-peace-pipeline`):** a horizontal stepper (war goals → offers → accepted/rejected → treaty → truce). It is aspirational and depends on adding the peace-treaty capabilities flagged in the architecture review.

### 2.4 Diplomatic & Sphere Network Visualizer (`FEAT-08/09`)

Offer **three linked views** of the same data, selectable by a segmented control, because network graphs fail at density:

1. **Force-directed network (`c-diplomacy-graph`)**
   - **Layout is precomputed** in Python (e.g., stable seed, saved `x,y` per node per snapshot), so the browser *doesn't run a physics simulation*. That is what keeps it at 60fps. Optional "relax" button runs a short bounded simulation (≤ 100 ticks) on demand.
   - **Node encoding:** size = GP score or industrial score; ring = civilization status; fill = sphere membership.
   - **Edge encoding:** alliance (solid thick), military access (dashed), guarantee (arrowed), vassal/sphere (arrow + faint line), war (red, zig-zag or double-line so it's not color-only), customs union (convex hull shading around members).
   - **Cap:** show ≤ 250 nodes; default to "Great Powers + their spheres + neighbors of selected country (1 to 2 hops)", with "expand" controls.
2. **Adjacency matrix (`c-diplomacy-matrix`):** countries ordered by cluster/sphere (use `MET-D-022–025` clusters) so blocks emerge visually. Cell glyph shows relation type; row/column hover cross-highlights. This is the best view for dense relationships and for accessibility.
3. **Sphere solar-system (`c-sphere-radial`):** a Great Power at center, satellites on concentric rings by influence level, and ring thickness showing influence points. Click a satellite to see influence-point spend and the market-capture indicator (`CAP-D-021`).

Supporting components:
- **Influence ledger (`c-influence-ledger`):** per-GP bars for influence points allocated, with a "contested" stripe where two GPs compete in one country.
- **Trade flow chord/Sankey (`c-trade-chord`)** for the Tableau CRM version (`PLAT-D-016`) or an SVG fallback.
- **Treaty timeline:** a truce/expiry Gantt (`CAP-D-059`) with "expires within 12 months" highlighted.
- **Relationship card (`c-relationship-card`):** a pairwise A↔B summary (relations value, treaties, trade volume, CBs, shared enemies) opened from any edge or matrix cell.

---

## 3. Cross-Domain & Derived Intelligence UX (`FEAT-17` & `FEAT-18`)

### 3.1 The "Lens" Model (avoid dashboard overload)

Each cross-domain capability (`CAP-D-*`) is delivered as a **Lens**: one question, one primary chart, one insight sentence, one evidence drawer. The Cross-Domain tab is a **gallery of lens cards** grouped by pair (Economy × Politics, etc.), each with a headline number, a micro-chart and a status chip. Opening a lens gives:

```
┌ LENS: Tax Impact on Growth & Unrest ──────────────────────────────────────┐
│ INSIGHT (templated): "Raising taxes from 40%→55% coincided with GDP growth │
│  −3.1pp and militancy +1.8 among craftsmen."      Confidence: Observed ⓘ   │
├────────────────────────────────────────┬──────────────────────────────────┤
│ PRIMARY: bubble scatter w/ time trail  │ DRIVERS (ranked contribution)    │
│ x=tax rate  y=GDP growth               │ ▇▇▇▇▇ Tax slider        +0.42     │
│ size=pop  color=militancy              │ ▇▇▇   Unemployment      +0.21     │
│ ▶ scrub across snapshots               │ ▇▂    War exhaustion    −0.08     │
├────────────────────────────────────────┴──────────────────────────────────┤
│ EVIDENCE ▸ table · formula · source fields · rollup grain · metric version │
└───────────────────────────────────────────────────────────────────────────┘
```

**Anti-overwhelm rules**
- Lens opens at **Glance** with a single insight sentence generated in Apex from templates (deterministic, testable).
- "Advanced" toggle reveals secondary encodings and the correlation view.
- Maximum **3 linked panels** per lens.
- Every chart has an "Explain this chart" popover (axes, definitions, how to read), seen first time and available after.

### 3.2 Visualization Selection Guide

| Interaction type | Best visual | Why |
|---|---|---|
| Two main variables + context (tax vs GDP growth vs militancy) | **Bubble scatter with time trail** (x, y, size = pop, color = militancy) | Rosling-style playback across 3 to 12 snapshots shows trajectory. |
| "Where should I worry?" across many countries | **Quadrant grid (2×2)** with labeled zones (e.g., "High growth / high unrest" = *Overheating*) | Converts continuous data into decisions. Drag the quadrant thresholds. |
| Compare a country to a benchmark across 6 to 8 dimensions | **Radar** (≤ 8 axes, normalized 0 to 100, benchmark polygon overlaid) **or a dumbbell chart** | Radar is intuitive for composites but poor for precise reading; always offer the dumbbell/bar toggle. |
| Many metrics over many countries | **Small multiples** (sparkline grid) | Preserves comparability and avoids spaghetti. |
| Before/after change | **Slope chart** or **delta table with variance bars** | Fast, honest comparison between two points. |
| What changed most? | **Diverging bar "top movers"** ranked by z-score of change | Directs attention to variance. |
| Which metrics move together? | **Correlation heatmap** (advanced mode) | Hidden by default; useful for analysts. |
| How is a composite built? | **Waterfall decomposition** | Explains HDI/risk as sum of weighted components. |
| Is this value unusual? | **Sparkline with expected band** (± σ from the rolling mean) | Anomaly context without extra charts. |
| Rank change over time | **Bump chart** (GP rank, industrial rank) | Great for the "rise of powers" story. |

### 3.3 Composite Score Design (HDI, IPS, MSC, Sovereign Bankruptcy Risk)

**Standard Score Card (`c-score-card`)**, reused for all 45 `MET-D-*`:
- **Header:** metric name, score ring or gauge (0 to 100), delta vs baseline, and a status band (Low/Moderate/Elevated/Critical) with icon + label (not color only).
- **Decomposition strip:** weighted component bars (waterfall on expand), each linking to its source metric.
- **Trust badges:** `Heuristic` / `Deterministic` / `Forecast` plus formula version (`v1.2`) and "last computed" time.
- **Sparkline** with historical band across snapshots.
- **ⓘ "How computed"** drawer: formula, weights, input fields, and golden-test status (ties to the RSK-24 mitigation).

**Sovereign Bankruptcy Risk (`c-solvency-panel`)**
- **Runway bar:** "Treasury covers ~7.4 months at current net flow." Red notch where it crosses a threshold.
- **Cash-flow waterfall:** income vs expenditure categories.
- **Debt stack:** loans and interest burden.
- **What-if sliders (optional, labeled as simulation):** tax and spending sliders that reapply the deterministic score client-side using the same coefficients exposed via Apex DTO. Keep these clearly separate from "real save data".
- **Risk tier banner** with the top 3 drivers.

**Variance highlighting** is global: any numeric cell or chart mark whose change vs baseline exceeds ±1.5σ gets a subtle **outline + ▲▼ glyph** (not a loud fill). A global toggle, "Highlight significant changes", controls it.

**Forecast display:** a forecast line has a dashed style and a confidence funnel, and is labeled "Projection (linear)" (`MET-D-015`). It is never visually identical to observed data.

---

## 4. Multi-Save Time Series Comparison Suite (`FEAT-15`)

### 4.1 Layout

```
┌ SNAPSHOT FILMSTRIP (3–12 slots) ───────────────────────────────────────────┐
│ [1836] [1841] [1846★] [1851] [1856] [1861] [empty] … ← drag to reorder/pin  │
│  ▲ event ticks: ⚔ war  ⚖ reform  ⚠ crisis  🏭 tech                          │
├───────────────────────────────────────────────────────────────────────────┤
│ MODE: ( Split ) ( Overlay ) ( Delta Table ) ( Rank/Bump )   NORMALIZE: [Idx▾] │
├───────────────────────────────────────────────────────────────────────────┤
│ …active comparison view…                                                  │
└───────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Modes

1. **Split-screen (A | B):** two panes, each locked to a snapshot (or country). A **linked cursor** highlights the same entity in both, scroll and selection sync, and a center "variance spine" shows delta arrows between rows. Good for 2-up deep comparison.
2. **Overlay:** multi-line chart of up to 12 points for chosen metrics (indexed to 100 at baseline), with a **growth/decay band** shading the area above and below the baseline line. Hovering shows the value at each snapshot plus CAGR.
3. **Delta table (`c-analysis-compare`, reused):** metrics × snapshots, cells showing value + inline variance bar and ▲▼ %. Sort by absolute change, % change, or z-score. Frozen first column and header.
4. **Small multiples:** one sparkline per metric in a grid, sorted by volatility or by biggest decline.
5. **Rank/Bump:** how the country ranked among peers on GDP, military, prestige over snapshots.
6. **Nation vs nation:** the same suite with the comparison axis switched from time to country (Egypt vs GBR at 1864), reusing the same components.

### 4.3 Variance & Insight Layer
- **Biggest movers:** the top 5 improvements and top 5 deteriorations between any two snapshots.
- **Waterfall between snapshots:** decomposes GDP change into contributions by good, e.g. "+£210k from steel, −£95k from grain."
- **Event overlay:** markers (wars, reforms, crises) on the time axis show *why* a curve bent, with click-through to details.
- **Normalization options:** Absolute / Index (=100) / % change / Per-capita / Z-score. The active normalization appears in the axis title, so it is never ambiguous.
- **Missing data:** gaps render as visible breaks, with a "no data for this snapshot" hatch; the chart never interpolates silently.
- **Capacity UX:** the filmstrip shows `7 / 12 slots`. Adding a 13th prompts "Replace oldest?" This mirrors the Apex cap (RSK-03), so users understand it rather than hitting an error.
- **Reuse:** `c-multi-save-trend` and `c-analysis-compare` form the engine, with new wrappers for the filmstrip and the mode switcher.
- **Data shape:** the server returns a **narrow long-format** payload (`metricKey, snapshotId, value`) per request. The client pivots as needed.

---

## 5. Enterprise Platform & AI UX Extensions

### 5.1 Real-Time Anomaly Alert Hub (`FEAT-19`)

**Entry points:** a bell icon with count in the context bar, plus toast popups for Critical only.

**Notification Drawer (`c-alert-drawer`)**
```
┌ ALERTS ─────────────────── ⚙ filters ┐
│ ● Critical (1)  ▲ High (2)  ● Info (5) │
├───────────────────────────────────────┤
│ ⚠ GDP −22% in 1 snapshot       2m ago │
│   Egypt · Δ vs 1861 · Driver: war     │
│   [Investigate] [Snooze 1d] [Ack]     │
├───────────────────────────────────────┤
│ ⚔ War declared: TUR → EGY      14m    │
│   [Open War Center]                   │
├───────────────────────────────────────┤
│ ▸ 5 info alerts grouped (Import done) │
└───────────────────────────────────────┘
```

- **Alert card anatomy:** severity icon + label, headline, entity chip (country/metric), delta, timestamp, and actions (**Investigate** deep-links by setting shell context and opening the right tab; **Ack**; **Snooze**; **Mute rule**).
- **Smart grouping:** duplicates collapse ("GDP anomaly ×3"), and info alerts batch into one row (aligns with RSK-13/RSK-16/RSK-18 "avoid spam").
- **Severity ladder and delivery:** Critical → toast + drawer + optional Slack/push; High → drawer + badge; Info → drawer only. Toast duration is longer for Critical and requires dismissal.
- **Delivery tech:** subscribe through `empApi` (as in `c-save-game-watcher-status`), debounced into the store, with one subscription owned by the shell and fan-out via LMS. Do not subscribe per component.
- **Rule UI (`c-alert-rule-builder`):** a "metric × operator × threshold × window" builder with a preview ("would have fired 3 times in your saves"). The default threshold is the ≥ 20% rule.
- **Slack-style timeline view:** a full-page alert feed with filters, date grouping, and thread-style "context" expansions (sparkline + related alerts).
- **Import-complete toast:** a single, unified event (not per chunk).

### 5.2 Agentforce Campaign Advisor Side Panel (`FEAT-20`, `c-campaign-advisor`)

```
┌ CAMPAIGN ADVISOR ──────────── ⚙ ✕ ┐
│ 📌 Egypt · 1864-03-01 · egypt.v2   │  ← pinned context banner (always visible)
├────────────────────────────────────┤
│ SUGGESTED (contextual to open tab) │
│ [Why is my rebellion risk rising?] │
│ [Compare my industry to Great      │
│  Britain] [What's draining my      │
│  treasury?] [Biggest war risks?]   │
├────────────────────────────────────┤
│ You: Why is rebellion risk spiking?│
│                                    │
│ ✅ FACTS (from your save)          │
│  • Rebellion risk: 62 (↑9)  ⓘsrc  │
│  • Unemployment (RGO): 14.2% ⓘ    │
│ 💡 INTERPRETATION (model inference)│
│  Likely driven by…                 │
│  [Open Rebel Monitor] [Show data]  │
│ 👍 👎  Copy · Saved to notes       │
├────────────────────────────────────┤
│ [ Ask about this save…         ➤ ] │
└────────────────────────────────────┘
```

**UX patterns that support the anti-hallucination architecture**
- **Pinned context banner:** always shows save, date and country, and cannot scroll away. It is the main defense against wrong-save answers.
- **Fact vs Interpretation structure:** two visibly distinct blocks, with a different background and icon, as specified in the data-layer plan.
- **Number chips with provenance:** each number is a chip (`£1,234,567`) that, on hover/click, shows the source field and lets the user "Open in view". Numbers that failed the post-generation verification never render as chips (they trigger a regeneration or a "couldn't verify" state).
- **"Show data" expander:** reveals the exact action payload as a small table. It builds trust and is great for debugging.
- **Context-aware quick-prompt chips:** chips change with the active tab (e.g., Military tab → "Which armies are understrength?", "Maintenance cost vs GDP"). Four to six chips max, with a "More ideas" overflow.
- **Action cards:** responses can end with deep-link buttons ("Open comparison with GBR", "Pin this lens"), which let the advisor *drive the UI*, not just talk.
- **Streaming and states:** a skeleton while actions run ("Checking treasury…" step list), a graceful `NOT_AVAILABLE` message ("I don't have data on that for this save"), and an offline/error fallback with "Try the Lens gallery instead."
- **Memory and notes:** "Save to Campaign Notes" pins an answer (with its frozen data) to a notes list, so answers stay tied to the snapshot they were generated for.
- **Feedback:** 👍/👎 with reason categories (wrong number, wrong save, unclear), writing into the interaction log.
- **Presentation mode:** the panel docks right (default), pops out into a wider overlay, or converts to a full-tab "Advisor" workspace for long conversations.

### 5.3 Experience Cloud Community Portal (`FEAT-22`)

Built on an **LWR site** with the same chart components in a **read-only, DTO-fed mode** (a `isPublic` flag disables drill-through to internal objects). Use the guest/community security model and read-only views per RSK-14/15.

**Pages**
1. **Campaign Gallery (home):** cards with campaign title, nation flag, in-game date range, tagline, 3 headline stats and a sparkline. Filters: era, nation, outcome, tags. Sort: popular, most improved, recent.
2. **Campaign Page (shareable):** hero banner (flag, country, dates), "Story so far" (generated narrative from `MET-D-037–040`), a **Timeline** with events, key charts (GDP, rank bump chart, war record), and a "Tale of the Tape" scorecard. Social share and a generated OG image/summary card.
3. **Head-to-Head (`c-h2h-compare`):** two campaigns or nations side by side with a center column of metric rows, each showing both values, a winner marker (◀ ▶ or =), and a **Battle Bar** (proportional split). A summary "scoreboard" at top ("Egypt wins 9 of 14 categories"). Optional per-era normalization so a 1840 nation isn't compared to an 1890 one unfairly.
4. **Leaderboards:** top campaigns by GDP growth, largest empire, fastest industrialization, with anti-cheat caveats (mods and settings listed).
5. **Player Profile:** anonymized or handle-based (RSK-15). Opt-in public, with aliasing by default.
6. **Upload & publish flow:** a wizard (select save → choose what to publish → preview public view → confirm). The preview shows *exactly* what guests will see.

**Privacy and safety UX:** a visible "Public / Private / Link-only" toggle, a "What's shared" disclosure panel, and a **Revoke** action.

---

## 6. Performance & Frontend Best Practices

### 6.1 Budgets

| Metric | Target |
|---|---|
| Interaction response (hover, tab switch with warm cache) | < 100 ms |
| Frame budget during scroll/animation | ≤ 16 ms (60fps) |
| Tab first meaningful content | < 1.5 s on warm Apex cache (skeleton at < 200 ms) |
| DOM nodes per view | Aim < 1,500; hard stop at ~5,000 |
| Payload per request | < 1 MB typical (< 4 MB hard) |
| Chart elements | SVG ≤ ~1,500; above that → Canvas |

### 6.2 Large-Table Patterns

| Data size | Pattern |
|---|---|
| ≤ ~300 rows | `lightning-datatable` with `enable-infinite-loading` and sorting. Note it renders all loaded rows, so it isn't truly virtualized. |
| 300 to 5,000 rows | **Custom virtual list (`c-virtual-table`):** fixed row height, windowed rendering (visible rows + 5-row buffer), absolute-positioned rows in a spacer container, scroll handler throttled with `requestAnimationFrame`. |
| > 5,000 | Never client-side. **Server-side keyset pagination** (cursor by `(sortKey, Id)`, not `OFFSET`; SOQL OFFSET caps at 2,000), plus server-side filter and sort, with a "Top N + search" UX. |
| Hierarchies (OOB, factories by state) | **`c-virtual-tree`:** flatten the visible tree to an array, window it, and lazy-load children on expand. |

Additional table UX: sticky headers and first column; column chooser; "Density" aware row heights (don't use variable height in virtual lists); skeleton rows during page loads; keyboard navigation (arrow keys, `Home`/`End`) and ARIA grid roles.

### 6.3 Rendering Strategy for Visualizations

- **SVG for ≤ ~1,500 marks** (bar/line/scatter on rollups, treemaps with ≤ 200 tiles). It's accessible and crisp. This is the strength of the existing `c-economic-charts-container`.
- **Canvas for dense or fast-updating charts** (heatmaps with time axis, large scatter, network with > 300 edges). Keep an **SVG overlay** for axes, labels and hit-regions, and use a spatial index (grid bucket or quadtree) for hover rather than per-element listeners.
- **One shared chart contract:** all charts accept `{series, scales, theme, onSelect}` and emit standardized `select`/`brush` events. This lets linked brushing work across chart types.
- **Never recompute layout in render:** compute scales and paths in a memoized function keyed by `(dataVersion, width, height)`.
- **`ResizeObserver` with debounce** (not window resize listeners); disconnect in `disconnectedCallback`.
- **Animations:** transform/opacity only; avoid animating layout properties; cap simultaneous animations; skip entirely under `prefers-reduced-motion`.
- **Off-main-thread:** assume Web Workers are *not* reliably available under Lightning Web Security. Instead, do heavy work server-side (Python/Apex), and chunk any remaining client computation with `requestIdleCallback` or `setTimeout` slicing.

### 6.4 Data Shaping & Wire Strategy

- **Columnar payloads:** return `{ids:[…], values:[…], …}` arrays instead of arrays of objects. This cuts JSON size and parse cost, and is cheaper to freeze.
- **Freeze large immutable datasets** (`Object.freeze`) and keep them out of reactive tracking, since LWC's reactive proxies add overhead on deeply nested data. Pass IDs/indices to child components rather than giant objects.
- **Materialized metrics only:** the UI should never compute composite scores; it renders what Apex serves (aligned with the "materialize anything chartable" recommendation).
- **Request coalescing:** a single `getWorkspaceBundle(saveId, snapshotId, countryTag, views[])` call for a tab's initial load rather than 12 imperative calls.
- **Progressive loading:** load KPIs and skeletons first, then charts, then secondary panels. Use `IntersectionObserver` to defer below-the-fold cards.

### 6.5 Caching Architecture

| Layer | Mechanism | Key | Invalidation |
|---|---|---|---|
| Apex | `@AuraEnabled(cacheable=true)` + Platform Cache (Org/Session partition) for expensive DTOs | `saveId:snapshotId:grain:schemaVersion` | On `ImportComplete` event |
| LWC module store | Singleton `Map` with LRU (e.g., 30 entries, byte-budgeted) | Same composite key | LMS message on import/publish; manual "Refresh" |
| `@wire` | Use for reactive, cacheable reads; use imperative Apex for user-triggered heavy loads | n/a | `refreshApex` after known data changes |
| Static assets | Flags, cartogram layout, icons in a static resource (versioned file names) | file version | Deploy |
| Browser storage | Light preferences only (theme, density, pinned tabs) | n/a | Version prefix; assume storage may be restricted |

**Stale-while-revalidate:** show cached data instantly with a subtle "Updated 2m ago ⟳" chip and refresh in the background. Because snapshots are immutable once published, they are *infinitely cacheable* (key by snapshot ID). Only "latest" pointers need invalidation.

### 6.6 LWC Hygiene
- **Keep components small and single-purpose,** and avoid re-rendering parents when only a child changes (pass primitives; use getters for derived values; avoid creating new arrays/objects in getters called on every render).
- **Use `key` attributes properly** on iterations, with stable IDs, never array indexes.
- **Use `lwc:if`** (not the deprecated `if:true`) and avoid hidden-but-mounted heavy components. Unmount inactive tabs.
- **Event discipline:** throttle hover events; use a single delegated listener on chart containers.
- **Memory:** clean up listeners, `empApi` subscriptions, `ResizeObserver`s, and timers in `disconnectedCallback`.
- **Debounce filters** (250 ms) and cancel in-flight imperative calls with a request-token pattern, so slow older responses can't overwrite newer ones.
- **Error boundaries:** every card renders independently in `loading` / `empty` / `error` / `stale` states, so one failing widget never blanks a dashboard.

### 6.7 Accessibility & Testing
- **A11y:** ARIA roles for custom grids/trees; focus management on drawer open/close; visible focus rings; every chart gets a text summary and a "View as table" toggle; contrast of ≥ 4.5:1; keyboard-operable network and matrix views (arrow-key cell navigation).
- **Perf testing:** a synthetic-data generator (10k factories, 5k provinces, 250 countries × 12 snapshots), Chrome Performance traces for scroll and tab-switch, and scripted frame-time checks in CI where feasible.
- **Jest tests** for the store, the data-shaping utils, and virtualization math. **Visual regression snapshots** for score cards and legends.
- **Reduced-data fallback:** a "Lite mode" (no animation, tables instead of heavy charts) that users can toggle, and which kicks in automatically if long tasks are detected.

---

## 7. Component Architecture Summary

```
c-save-game-analyzer-shell
├─ c-global-context-bar
│   ├─ c-save-selector · c-snapshot-scrubber · c-country-switcher · c-flag-badge
│   ├─ c-kpi-ribbon → c-kpi-tile (sparkline)
│   └─ c-alert-bell
├─ c-nav-rail · c-command-palette
├─ c-workspace-tabs → c-workspace-split
│   └─ [Registry of views]
│       ├─ c-command-overview
│       ├─ Economy: c-market-dashboard (c-price-ticker, c-goods-heatmap, c-gdp-treemap,
│       │           c-supply-demand-bullet, c-budget-waterfall) · c-state-inspector
│       ├─ Society: c-pop-explorer · c-politics-dashboard · c-rebel-monitor
│       ├─ Power:   c-oob-explorer · c-war-command-center · c-battle-timeline
│       ├─ Foreign: c-diplomacy-hub (graph | matrix | radial) · c-sphere-focus · c-colony-crisis
│       ├─ Intelligence: c-lens-gallery → c-lens-view · c-metric-suite → c-score-card
│       └─ Time: c-compare-suite (c-snapshot-filmstrip, c-multi-save-trend*, c-analysis-compare*)
├─ c-utility-drawer
│   ├─ c-alert-drawer · c-campaign-advisor · c-record-inspector · c-campaign-notes
└─ c-status-bar → c-save-game-watcher-status*
                                    (* = existing asset reused)
Shared kernel: c-context-store · c-data-cache · c-chart-kit (svg/canvas/scales/legend/tooltip)
               c-virtual-table · c-virtual-tree · c-skeleton · c-empty-state · c-explain-popover
```

**Suggested delivery alignment with the revised roadmap:** build the shell, context store, chart kit, virtual table, and score card in Phase 1 alongside `FEAT-01/03/02`. They are the reusable spine. Then prove the Lens pattern with the five-lens Phase 2 slice before scaling it to all 65 cross-domain capabilities.

I can turn any section into something more concrete: an interactive HTML mockup of the shell and a Lens view, a detailed LWC component contract (public API, events, and DTO shapes) for the shared kernel, or a SLDS styling-hooks theme spec for the Ledger and War Room modes.
