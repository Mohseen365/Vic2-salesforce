# Victoria 2 Hegemonic Ascension, Total War & Macroeconomic Policy Suite

## Problem Statement
How might we synthesize Victoria 2's comprehensive global data model into a unified Great Power ascension engine, total war procurement watchdog, and macroeconomic party-policy simulator so secondary and great powers can optimize geopolitical hegemony, execute political reforms, and maintain fiscal solvency?

## Recommended Direction
Synthesize **1-Screen Executive Triage Cards & SVG Heatmaps** with **Grounded Agentforce Hegemonic Intelligence** and an **In-Memory Party Policy & Market Monopoly Sandbox**.

The platform combines three core architectural pillars:
1. **1-Screen Executive Triage Cards & Heatmaps:** Delivers "The 1-Page War Mobilization Readiness Summary Card" (`c-mobilization-readiness-card`), "The 1-Click Sphere Profit Matrix" (`c-sphere-profit-matrix`), "Great Power Ascension Proximity Gauge" (`c-gp-ascension-gauge`), and SVG "Uncollected Tax Leakage Heatmap" (`c-tax-leakage-heatmap`) alongside a real-time "Global Military Hardware Market Ticker" (`c-military-hardware-ticker`) in `c-global-context-bar`.
2. **Grounded Agentforce Hegemonic & Reform Intelligence:** Extends Agentforce invocable Apex actions (`GetGreatPowerAscensionTargetAction`, `GetUpperHouseReformFeasibilityAction`, `GetDebtRepaymentPlanAction`) and proactive monitors (`WartimeMunitionsTracker.cls`, `SphereInfluenceDefenseWatcher.cls`, `UnemployedCraftsmanWatcher.cls`) to advise on rank-8 ascension score targets, socialist upper-house reform voting majorities, sphere defense alerts, and unemployed craftsman revolt risks.
3. **In-Memory Macroeconomic & Party Policy Sandbox:** Provides interactive counterfactual simulation tools ("Laissez-Faire vs. Planned Economy Tariff/GDP Sandbox", "Sphere Monopolization Sandbox", "Healthcare Population Boom Sandbox", "Artisan Tax Squeeze Demotion Sandbox") driven by pure Apex calculation math (`EconomicPolicyPartySimulator.cls`, `GoldInflationSimulator.cls`) to preview party platform GDP impact, gold inflation devaluation, and debt-default Casus Belli risks without modifying save file records.

## Key Assumptions to Validate
- [ ] **Great Power Ascension Score Parity:** Validate that the Ascension Target Action accurately calculates prestige, industrial, and military score gaps required to displace Rank 8 Great Powers across 5 benchmark save states.
- [ ] **Wartime Munitions Shortage Alert Speed:** Confirm that the Wartime Munitions Tracker detects Small Arms and Artillery stockpile exhaustion 3 months before regiment organization collapses to zero during total war.
- [ ] **Economic Party Switch Simulation Parity:** Verify that the Party Simulator accurately projects Capitalist private investment velocity under Laissez-Faire vs. state factory building costs under State Capitalism within a 5% margin of error.

## MVP Scope
- **Unified Command LWC (`c-hegemonic-ascension-shell`):** Integrates Ascension Proximity Gauge, Military Hardware Market Ticker, Sphere Profit Matrix, and Party Policy Simulator Panel.
- **Great Power Ascension Proximity Gauge (`c-gp-ascension-gauge`):** Visual gauge displaying rank-8 score distance and targeted industrial GDP requirements.
- **Sphere Profit & Monopolization Matrix (`c-sphere-profit-matrix`):** Rank-ordered matrix sorting target non-sphered nations by economic market value returned per influence point spent.
- **Uncollected Tax Leakage Heatmap (`c-tax-leakage-heatmap`):** SVG state map highlighting tax revenue lost to low Bureaucrat density (<1.0%).
- **In-Memory Party & Inflation Sandbox (`EconomicPolicyPartySimulator.cls`):** Interactive controls predicting GDP growth and factory closure rates across Laissez-Faire, Interventionism, State Capitalism, and Planned Economy regimes.

## Not Doing (and Why)
- **Automatic Save File Mutation/Editing:** We will NOT write modified `.v2` save files back to disk. *Reason:* Preserves absolute data integrity; system functions strictly as a decision-support advisor.
- **Tactical Battle Simulation Engine:** We will NOT simulate individual battle tactical choices or regiment die-rolls. *Reason:* Focus strictly on strategic munitions procurement, war readiness, mobilization stockpiles, and macroeconomic stability.
- **Dynamic AI Great Power Dialogue Generator:** We will NOT generate interactive conversational dialogue trees with foreign AI nations. *Reason:* Focus purely on data-grounded metrics, alliance military ratios, and trade pool calculation math.

## Open Questions
- What weight should be given to industrial GDP vs. prestige score when projecting Great Power ascension timelines for Rank 9–12 secondary powers?
- Should the Military Hardware Market Ticker issue automated platform event alerts when global Small Arms prices spike by >20% during Great Power wars?
