# Victoria 2 Industrial Resiliency, Infrastructure & Statehood Integration Simulator

## Problem Statement
How might we transform Victoria 2's detailed factory, infrastructure, and territorial metadata into an intelligent industrial bottleneck resolver, containment war early warning system, and colonial statehood integration sandbox so players can maintain industrial growth and prevent empire collapse?

## Recommended Direction
Synthesize **1-Screen Infrastructure & Bottleneck Cards** with **Agentforce Infamy & Input Resiliency Intelligence** and an **In-Memory Mobilization & Statehood Sandbox**.

The platform combines three core functional pillars:
1. **1-Screen Bottleneck & Infrastructure Visualization:** Delivers the "Top 5 Machine Parts Bottlenecks Card" (`c-machine-parts-card`) and SVG "Railroad Efficiency & Infrastructure Heatmap" (`c-infrastructure-heatmap`), allowing players to pinpoint stalled factory builds and under-built railroad states in seconds.
2. **Grounded Agentforce Infamy & Input Intelligence:** Extends Agentforce invocable Apex actions (`GetSyntheticFactoryConversionAction`, `GetImmigrationOptimizationAction`) and automated Infamy decay watchers (`InfamyDecayService.cls`) to advise on converting to synthetic factories (Dye/Synthetic Rubber), attracting European immigrants, and avoiding Containment Wars when Infamy exceeds 22.0.
3. **In-Memory Mobilization & Statehood Integration Sandbox:** Provides interactive counterfactual simulations ("Maximum Industrial Mobilization & Subsidies Simulator", "Colonial Statehood Integration Sandbox") driven by pure Apex calculation math (`SubsidyImpactSimulator.cls`, `StateIntegrationSimulator.cls`) to preview subsidy treasury drains and colonial upper-house shifts without save-game mutation.

## Key Assumptions to Validate
- [ ] **Infamy Threshold Alert Reliability:** Verify that the Infamy decay watcher correctly calculates years remaining until Infamy drops below 25.0 and fires platform events (`Economy_Anomaly_Event__e`) when Infamy > 22.0 across test save states.
- [ ] **Synthetic Factory Parity Calculation:** Validate that the synthetic factory conversion action accurately computes price parity points between RGO natural imports and synthetic factory input costs across 5 test economies.
- [ ] **Statehood Integration Simulation Speed:** Confirm that in-memory tax yield increases vs. upper-house political shifts during colonial state integration execute under 150ms in Apex heap limits.

## MVP Scope
- **Unified LWC Workspace (`c-industrial-resiliency-shell`):** Integrates Infrastructure Heatmap, Machine Parts Bottleneck Card, and Infamy Watchdog Toast.
- **Railroad Infrastructure Heatmap (`c-infrastructure-heatmap`):** SVG map overlay coloring states by Railroad Level (0–6) vs. RGO extraction capacity.
- **Top 5 Machine Parts Bottlenecks Card (`c-machine-parts-card`):** Aggregated view isolating exact stalled factory constructions due to Machine Parts shortages.
- **Infamy & Containment War Watchdog (`InfamyDecayService.cls`):** Proactive alert engine calculating Infamy decay timelines and Containment War risk.
- **In-Memory Subsidies & Statehood Sandbox (`SubsidyImpactSimulator.cls`):** Interactive sliders projecting global market price drops and treasury costs under 100% factory subsidies.

## Not Doing (and Why)
- **Automatic Save File Mutation/Editing:** We will NOT edit `.v2` save files back to disk. *Reason:* Preserves absolute data integrity; system functions strictly as a decision-support advisor.
- **Full Diplomatic AI Dialogue Simulation:** We will NOT build interactive conversational negotiation loops with foreign AI nations. *Reason:* Focus strictly on data-grounded metrics, infamy decay rates, and economic input calculations.
- **Direct Construction Ordering via API:** We will NOT attempt to directly queue in-game factory builds. *Reason:* The tool is a decision-support advisor, not an automated game bot.

## Open Questions
- What weight should be given to factory employment rates vs. raw RGO output when coloring the Railroad Infrastructure Heatmap?
- Should the Synthetic Factory Conversion Advisor prioritize domestic input security over foreign import price parity during wartime blockades?
