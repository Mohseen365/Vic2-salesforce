# Victoria 2 Macroeconomic Triage & Geopolitical Policy Simulator

## Problem Statement
How might we transform Victoria 2's dense, multi-faceted save-game data into proactive geopolitical trade/rebellion intelligence and real-time counterfactual policy simulations so players can instantly diagnose economic bottlenecks, prevent revolution, and dominate global markets?

## Recommended Direction
Synthesize **1-Screen Macroeconomic Triage** with **Grounded Agentforce Trade/Rebellion Intelligence** and an **In-Memory Policy Sandbox**.

The platform converges on three tightly integrated capabilities:
1. **1-Screen Macroeconomic Triage & Prevention:** Delivers the "30-Second Bankruptcy Preventer" and "Factory Health & Subsidies Triage Card" alongside a "Next 5 Years" trajectory forecaster (`TimeSeriesController.cls`), giving players immediate actionable remedies for fiscal bleeding without navigating 15 complex tabs.
2. **Grounded Agentforce Trade & Rebellion Intelligence:** Extends Agentforce invocable Apex actions (`GetRivalSupplyChainBottlenecksAction`, `GetRebellionRiskAction`, `GetOptimalFactoryBuildsAction`) and `CampaignAdvisorVerifier.cls` to identify rival trade dependencies, map POP militancy back to specific missing life/everyday goods, and recommend optimal industrial factory builds.
3. **In-Memory Policy & Market Integration Sandbox:** Enables interactive counterfactual simulations ("Tariff & Free-Trade Impact Sandbox", "Spheres of Influence Integration Sandbox") powered by pure Apex calculation math (`EconomyCalculationEngine.cls`) to preview tariff yield, domestic factory survival, and sphere market shifts before unpausing in-game.

## Key Assumptions to Validate
- [ ] **Pure Apex Simulation Latency:** Verify that in-memory tariff and sphere market integration simulation across 49 commodity nodes executes under 200ms in Apex heap limits without DML persistence.
- [ ] **POP Shortage to Militancy Correlation:** Validate against 5 Victoria 2 save states that flagged POP radicalization warnings accurately trace to specific unfulfilled life/everyday product supply deficits in `Country_Product_Economy__c`.
- [ ] **Trajectory Forecast Accuracy:** Verify that the 5-year linear/polynomial forecast service in `TimeSeriesController.cls` accurately projects treasury and GDP trends across 3–12 save snapshots within a 5% margin of error.

## MVP Scope
- **Unified LWC Workspace (`c-macroeconomic-triage-shell`):** Houses the 1-Screen Triage Dashboard, Policy Simulator Panel, and Agentforce Geopolitical Advisor.
- **Factory Health & Subsidies Triage Card (`c-factory-triage-card`):** Categorizes national factories into "Profitable", "Input Tech Shortage", and "Money Pit" with bulk-subsidy toggle hooks.
- **30-Second Bankruptcy Preventer:** One-click emergency fiscal adjustment recommendation engine based on negative daily treasury velocity and `DerivedIntelligenceEngine.computeBankruptcyRisk()`.
- **Interactive Tariff & Sphere Sandbox:** Sliders for Tax/Tariff adjustments and Sphere member toggles feeding pure Apex `TariffSimulationService.cls`.
- **Grounded Trade & POP Intelligence Actions:** Invocable actions delivering targeted tariff embargo recommendations against rivals and missing-good relief strategies for radical POPs.

## Not Doing (and Why)
- **Multi-Country Foreign AI Retaliation Modeling:** We will NOT simulate how foreign AI nations reactively adjust their tariffs or sphere decisions in response to player moves. *Reason:* Exponential computational complexity exceeding Apex governor limits.
- **Direct Save File Editing/Writing:** We will NOT edit or write `.v2` files back to disk. *Reason:* The system functions strictly as a decision-support advisor and analytics suite, preserving data integrity.
- **Full Tactical Military Battle Simulation:** We will NOT simulate regiment-level tactical combat outcomes. *Reason:* Focus strictly on trade, industrialization, fiscal stability, and POP militancy.

## Open Questions
- What is the optimal mathematical weighting for domestic factory protection vs. government tariff revenue when calculating recommended tariff rates?
- Should sphere market integration forecasts account for foreign domestic supply priority rules before allocating remaining commodities to sphere partners?
