# Victoria 2 Autonomous Economy Doctor & Policy Simulator

## Problem Statement
How might we transform Victoria 2's complex, opaque save-game data into instant root-cause economic diagnostics and deterministic "what-if" policy simulations so players can prevent financial collapse and optimize their national economy?

## Recommended Direction
Combine the single-screen **"Economy Doctor"** diagnostic view with a pure Apex **"What-If" Policy Simulator** and **Agentforce Grounded AI Guidance**.

Instead of forcing users to wade through 139 custom objects across 15 LWC tabs, the system delivers:
1. **Root-Cause Diagnostic Engine:** Instantly pinpoints top economic bottlenecks (e.g., unfulfilled pop life needs, factory input shortages, high rebellion/bankruptcy risk scores from `DerivedIntelligenceEngine.cls`).
2. **Interactive Policy Sandbox:** Allows players to tweak tax rates, tariffs, and subsidies using in-memory `EconomyCalculationEngine.cls` math to preview economic outcomes *before* unpausing in-game.
3. **Deterministic AI Strategic Guidance:** Extends Agentforce invocable actions (`GetEconomicMetricsAction`, `CampaignAdvisorVerifier.cls`) to generate grounded, verified recommended actions with numeric backings.

## Key Assumptions to Validate
- [ ] **Pure Math Parity in Scenarios:** Validate that `EconomyCalculationEngine` in-memory scenario math mirrors game formula notes within 0.01% parity tolerance across 10 test scenarios.
- [ ] **Diagnostic Relevance:** Test with 5 Victoria 2 save states to verify that the top 3 flagged "Doctor Diagnostics" accurately identify actual economic failures in the save file.
- [ ] **Low Latency In-Memory Simulation:** Verify that executing a policy shift simulation across 49 commodity market nodes completes under 200ms in Apex heap limits.

## MVP Scope
- **Single-Screen LWC (`c-economy-doctor`):** Replaces default multi-tab shell with a unified "Diagnostic & Simulator" dashboard.
- **Top 3 Diagnostic Cards:** Displays current Bankruptcy Risk Index, Rebellion Risk Score, and Primary Factory Shortage bottleneck.
- **Policy Sliders:** Interactive controls for Tax Rates (Poor/Middle/Rich), Tariffs, and Subsidy budget allocations.
- **In-Memory Delta Engine (`EconomyCalculationEngine.simulatePolicyShift()`):** Computes projected revenue, pop life-need fulfillment, and state treasury impact without performing DML persistence.
- **Grounded AI Advice Panel (`c-campaign-advisor`):** Renders 2–3 deterministic recommended in-game button actions based on simulation outcomes.

## Not Doing (and Why)
- **Multi-Country AI Counter-Policy Reaction:** We will NOT simulate how foreign AI countries adjust tariffs in response to player changes. *Reason:* Exponential computational complexity exceeding Apex governor limits.
- **Full Game Engine Tick Emulation:** We will NOT re-implement full military/diplomatic ticks. *Reason:* Focus strictly on economic policy and derived metrics.
- **Direct Save File Modification/Writing:** We will NOT write modified `.v2` files back to disk. *Reason:* The tool is a decision-support advisor, not a save editor.

## Open Questions
- What is the acceptable calculation tolerance when estimating global market demand shifts caused by national tariff changes?
- Should simulation presets (e.g., "Max Industrialization", "War Economy") be provided as one-click templates?
