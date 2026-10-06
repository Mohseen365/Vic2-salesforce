# Victoria 2 Geopolitical Hegemony & Industrial Modernization Simulator

## Problem Statement
How might we transform Victoria 2's deep global data model into an actionable geopolitical expansion advisor, wartime mobilization readiness suite, and industrial modernization simulator so players can dominate Great Power diplomacy, execute rapid economic upgrades, and win global conflicts?

## Recommended Direction
Synthesize **Geopolitical Expansion & Crisis Escalation Intelligence** with an **Industrial Mobility & Financial Default Simulator** and **1-Click Executive Decision Cards**.

The unified platform delivers three core capability layers:
1. **Geopolitical Expansion & Great War Intelligence:** Integrates the "Colonial Scramble Resource Optimizer", "Crisis Manager & Great War Escalation Advisor", and "1-Click Sphere of Influence Value Matrix" via Agentforce invocable actions (`GetColonialPriorityTargetAction`, `GetCrisisCoalitionStrengthAction`) to guide naval bases, alliance choices, and influence spending.
2. **Industrial Modernization & Counterfactual Sandbox:** Provides the "Artisan Demotion & POP Social Mobility Simulator", "Naval Blockade Simulator", "Debt Default Sandbox", and "Research Pathing Advisor" powered by pure Apex calculation engines (`EconomyCalculationEngine.cls`, `POPMobilitySimulator.cls`) to project POP class demotions, naval import dependency collapses, and sovereign default risks without save-file mutation.
3. **Actionable Executive Decision Support:** Features "RGO Extraction Bottleneck Cards" and "The 'War Readiness' Diagnostic Gauge" (`c-war-readiness-gauge`) to give players an immediate 0–100% military readiness score and 1-click infrastructure bottleneck remedies before declaring war.

## Key Assumptions to Validate
- [ ] **Colonial Resource Valuation Accuracy:** Validate that the uncolonized resource scoring algorithm correctly prioritizes late-game Rubber, Oil, and Opium provinces across 5 benchmark save states.
- [ ] **POP Mobility Simulation Speed:** Verify that in-memory tax-driven POP class demotion and artisan-to-craftsman transition calculations execute under 150ms in Apex heap limits.
- [ ] **Crisis Coalition Aggregation:** Confirm that alliance network aggregation (`GetCrisisCoalitionStrengthAction`) correctly sums total army regiments and military readiness scores across complex multi-national Great Power alliances.

## MVP Scope
- **Unified Command LWC (`c-geopolitical-hegemony-shell`):** Integrates Crisis Escalation Panel, Industrial Simulator Sandbox, and War Readiness Gauge.
- **War Readiness Diagnostic Gauge (`c-war-readiness-gauge`):** Visual 0–100% score aggregating military stockpile reserves (Small Arms, Canned Food), manpower, and treasury reserve days.
- **Sphere of Influence Profit Matrix (`c-sphere-value-matrix`):** Rank-ordered table sorting all target nations by net economic value returned per diplomatic influence point spent.
- **RGO Extraction Bottleneck Cards (`c-rgo-bottleneck-card`):** Identifies provinces where Railroad level or Life Rating is choking raw Coal, Iron, and Rubber output.
- **In-Memory POP & Debt Sandbox (`POPMobilitySimulator.cls`):** Interactive sliders predicting Artisan demotion rates and sovereign default Casus Belli risks.

## Not Doing (and Why)
- **Automatic Save File Mutation/Editing:** We will NOT modify or write `.v2` save files back to disk. *Reason:* Preserves absolute data integrity; system functions strictly as a decision-support advisor.
- **Dynamic AI Diplomacy Negotiation Engine:** We will NOT generate interactive diplomatic dialogue loops with foreign game AI. *Reason:* Focus purely on data-grounded metrics, military coalition ratios, and economic profit analysis.
- **Tactical Micro-Unit Combat Emulation:** We will NOT simulate individual battle tactics or die-roll tactical combat. *Reason:* Focus strictly on strategic war readiness, stockpiles, mobilization, and macro economy.

## Open Questions
- What weight should be assigned to military technology levels vs. raw regiment counts when computing the unified War Readiness Score?
- Should the Sphere Value Matrix factor in geographic distance and naval supply range when calculating target scores?
