# Victoria 2 Synthetic Resource Transition, Market Saturation & Purchasing Power Simulator

## Problem Statement
How might we transform Victoria 2's world market, factory input, and colonial migration metadata into an intelligent synthetic resource transition advisor, tariff purchasing power simulator, and real-time market price pulse so players can resolve industrial supply bottlenecks and maximize POP welfare?

## Recommended Direction
Synthesize **1-Screen Market Price Ticker & Bottleneck Cards** with **Agentforce Synthetic Transition & Plurality Intelligence** and an **In-Memory Tariff Purchasing Power & Colonial Migration Sandbox**.

The unified platform integrates three core architectural layers:
1. **1-Screen Market Price Pulse & Bottleneck Triage:** Delivers the real-time scrolling "Global Market Goods Price Fluctuation Ticker" (`c-market-price-ticker`) in `c-global-context-bar` and "The 1-Screen 'Top 3 Starved Factories' Input Bottleneck Card" (`c-starved-factory-card`) to instantly highlight global commodity price spikes and isolate manufacturing supply chain halts.
2. **Grounded Agentforce Synthetic Transition & Plurality Intelligence:** Extends Agentforce invocable Apex actions (`GetSyntheticResourceTransitionAction`, `PluralityRevoltWatcher.cls`) to advise when to build synthetic Oil and Rubber plants before WWI-era mobilizations stall, while tracking National Plurality and POP Consciousness to predict revolt timelines.
3. **In-Memory Tariff Purchasing Power & Colonial Resettlement Sandbox:** Provides interactive counterfactual simulation tools ("Tariff Revenue vs. Domestic Purchasing Power Sandbox", "Sphere Market Supply Saturation Sandbox", "Colonial Migration Sandbox") driven by pure Apex calculation engines (`SphereSupplySaturationSimulator.cls`, `ColonialMigrationSimulator.cls`) to preview tariff-driven price surges, sphere supply floods, and European homeland-to-colony migration velocity without modifying save file records.

## Key Assumptions to Validate
- [ ] **Synthetic Resource Transition Parity:** Validate that the Synthetic Resource Transition Advisor accurately predicts Oil and Rubber factory input deficits 2 years before WWI-era automobile and tank factories halt production across 5 test save states.
- [ ] **Sphere Saturation Price Projection:** Confirm that the Sphere Supply Saturation Simulator accurately projects RGO worker income drops when flooding domestic markets with sphered agricultural goods within a 5% margin of error.
- [ ] **Real-Time Market Ticker Latency:** Verify that streaming commodity price deltas across all 49 products in `c-market-price-ticker` executes under 100ms without DML performance overhead.

## MVP Scope
- **Unified LWC Workspace (`c-synthetic-transition-shell`):** Integrates Global Market Price Ticker, Starved Factory Bottleneck Card, and Tariff Purchasing Power Simulator Panel.
- **Global Market Price Fluctuation Ticker (`c-market-price-ticker`):** Scrolling header ticker displaying real-time world market price surges and crashes across 49 trade goods.
- **Top 3 Starved Factories Bottleneck Card (`c-starved-factory-card`):** Isolated view pinpointing factories with the highest days-without-input counts (Coal, Iron, Dye) with 1-click stockpile order adjustments.
- **In-Memory Tariff & Colonial Migration Sandbox (`SphereSupplySaturationSimulator.cls`):** Sliders predicting domestic POP Life-Need purchasing power changes under tariff shifts and European colonial resettlement velocity.
- **Invocable Synthetic Resource Action (`GetSyntheticResourceTransitionAction.cls`):** Calculates exact technological readiness and factory build locations for synthetic Oil and Synthetic Rubber plants.

## Not Doing (and Why)
- **Automatic Save File Editing/Mutation:** We will NOT write modified `.v2` save files back to disk. *Reason:* Preserves absolute data integrity; system functions strictly as a decision-support advisor.
- **Micro-Level Individual POP Consumption Modeling:** We will NOT simulate character-level consumption for millions of individual POPs. *Reason:* Aggregate state and country POP class groupings preserve high Apex calculation performance within governor limits.
- **Automated Direct Market Trading via Bot:** We will NOT execute direct automated buy/sell orders on the world market. *Reason:* The system provides analytical warnings and advice, preserving player agency and game rules.

## Open Questions
- What mathematical weight should be assigned to domestic synthetic plant production vs. foreign sphere raw imports when computing the Synthetic Resource Transition recommendation?
- Should the Global Market Price Fluctuation Ticker allow custom user threshold filtering (e.g., alert only on >15% commodity price spikes)?
