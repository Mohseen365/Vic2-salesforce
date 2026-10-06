# Victoria 2 Westernization, Colonial Penetration & Great Power Coalition Suite

## Problem Statement
How might we synthesize Victoria 2's uncivilized reform, colonial penetration, and military alliance metadata into a unified westernization speed optimizer, colonial scramble engine, and defensive war attrition simulator so uncivilized, secondary, and great powers can accelerate modernization, expand overseas empires, and win global coalition wars?

## Recommended Direction
Synthesize **1-Screen Executive Triage Cards & SVG Heatmaps** with **Grounded Agentforce Westernization & Coalition Intelligence** and an **In-Memory Attrition & Monopolization Sandbox**.

The platform combines three core capability pillars:
1. **1-Screen Executive Triage Cards & Heatmaps:** Delivers "The 1-Screen 'Top 3 Uncolonized High-Value RGOs' Card" (`c-uncolonized-rgo-card`), "The 1-Click 'Sphere Defense Target' Matrix" (`c-sphere-defense-matrix`), "Great War Military Coalition Power Ratio Gauge" (`c-coalition-power-gauge`), and SVG "Colonial Life-Rating Penetration Coastline Heatmap" (`c-colonial-life-rating-heatmap`) alongside a real-time "Global Munitions & Explosives Supply Ticker" (`c-munitions-supply-ticker`) in `c-global-context-bar`.
2. **Grounded Agentforce Westernization & Coalition Intelligence:** Extends Agentforce invocable Apex actions (`GetWesternizationSequenceAction`, `GetColonialTechReadinessAction`, `GetRivalThreatAssessmentAction`, `GetLoanRefinancingPlanAction`) and proactive monitors (`SubstateInfluenceWatcher.cls`, `FlashpointEscalationWatcher.cls`, `ArtisanInputPriceWatcher.cls`, `WarExhaustionWatcher.cls`) to guide uncivilized reform ordering, colonial tech timing, substate sphere defense, and loan refinancing.
3. **In-Memory Defensive Attrition & Resource Monopolization Sandbox:** Provides interactive counterfactual simulation tools ("Machine Gun Defensive War Attrition Sandbox", "Substate Sphere Annexation Sandbox", "Capitalist Auto-Build Preferences Sandbox", "Conscription Famine Sandbox", "Great Power Resource Monopolization Sandbox") driven by pure Apex calculation math (`WesternizationRevoltSimulator.cls`, `MachineGunDefenseSimulator.cls`) to preview fortified border defense casualties, substate annexation yields, and mobilization famine risks without save-file mutation.

## Key Assumptions to Validate
- [ ] **Westernization Sequence Parity:** Validate that the Westernization Sequence Action correctly calculates reactionary militancy spikes across reform tiers to prevent civil war rebellions across 5 test save states.
- [ ] **Machine Gun Defensive Attrition Speed:** Confirm that the Machine Gun Attrition Simulator accurately calculates enemy regiment casualty rates in fortified mountain provinces within a 5% error margin.
- [ ] **Colonial Tech Readiness Timing:** Verify that the Colonial Tech Readiness Advisor accurately projects the exact month Prophylaxis Against Malaria unlocks low life-rating interior colonization.

## MVP Scope
- **Unified Command LWC Workspace (`c-westernization-coalition-shell`):** Integrates Uncolonized RGO Card, Coalition Power Ratio Gauge, Munitions Supply Ticker, and Defensive Attrition Simulator Panel.
- **Great War Coalition Power Ratio Gauge (`c-coalition-power-gauge`):** Visual gauge displaying army regiment and warship ratios between friendly vs. opposing Great Power coalitions.
- **Colonial Life-Rating Penetration Heatmap (`c-colonial-life-rating-heatmap`):** SVG coastal map highlighting colonizable interior borders as medical tech unlocks low life ratings.
- **Sphere Defense Target Matrix (`c-sphere-defense-matrix`):** Rank-ordered table isolating endangered sphered partners under rival diplomatic threat with 1-click expulsion recommendations.
- **In-Memory Westernization & Defense Sandbox (`MachineGunDefenseSimulator.cls`):** Interactive sliders predicting enemy casualties under fortified defense and conscription food drops.

## Not Doing (and Why)
- **Automatic Save File Mutation/Editing:** We will NOT write modified `.v2` save files back to disk. *Reason:* Preserves absolute data integrity; system functions strictly as a decision-support advisor.
- **Micro-Tactical Unit Battle Emulation:** We will NOT simulate individual battle die-rolls or unit positioning. *Reason:* Focus strictly on strategic munitions stockpiles, defensive attrition modifiers, and mobilization readiness.
- **Dynamic AI Great Power Dialogue Trees:** We will NOT generate interactive conversational dialogue loops with foreign AI nations. *Reason:* Focus purely on data-grounded metrics, alliance military ratios, and trade pool calculation math.

## Open Questions
- What weight should be given to military reform progress vs. economic reform progress when calculating the optimal Westernization sequence for uncivilized nations?
- Should the Great War Coalition Gauge automatically factor in mobilization reserve brigades when computing total army power ratios?
