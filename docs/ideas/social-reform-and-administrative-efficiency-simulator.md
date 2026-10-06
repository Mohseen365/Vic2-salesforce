# Victoria 2 Social Reform, Industrial Labor Cost & Administrative Efficiency Simulator

## Problem Statement
How might we transform Victoria 2's complex POP labor, social reform, and state bureaucrat data into an actionable labor-cost policy simulator, administrative efficiency optimizer, and capital investment watchdog so players can safely expand worker welfare, maximize tax collection, and prevent fiscal ruin?

## Recommended Direction
Synthesize **1-Screen Administrative & Factory Triage Cards** with **Agentforce Labor, Capital & Conscription Intelligence** and an **In-Memory Labor Cost & Stockpile Sandbox**.

The unified platform integrates three core architectural layers:
1. **1-Screen Administrative & Factory Triage:** Delivers "The 1-Screen 'Top 3 Unprofitable Subsidized Factories' Triage Card" (`c-unprofitable-factory-card`) and SVG "Bureaucrat Efficiency & Administrative Tax Heatmap" (`c-admin-efficiency-heatmap`) to instantly identify money-losing factories and uncollected state tax revenues caused by low bureaucrat density (<1.0%).
2. **Grounded Agentforce Labor, Capital & Conscription Intelligence:** Extends Agentforce invocable Apex actions (`GetLiteracyOptimizationAction`, `GetMobilizationCapacityAction`) and proactive monitors (`ForeignInvestmentTracker.cls`, `TextileInputMonitor.cls`) to advise on clergy allocation targets (2.0%), track foreign factory capital takeovers (>30%), warn of organic dye input shortages, and forecast conscription reserve replenishment.
3. **In-Memory Labor Cost & Fiscal Solvency Sandbox:** Provides interactive counterfactual simulation tools ("Minimum Wage & Safety Reform Industrial Cost Simulator", "Sphere Tariff Exemption Sandbox", "Military Stockpile Buy-Limit Sandbox") driven by pure Apex calculation engines (`SocialReformSimulator.cls`, `StockpileSimulationService.cls`) to preview wage cost surges, lost sphere tariff revenues, and daily military treasury burn rates without modifying save file records.

## Key Assumptions to Validate
- [ ] **Wage Reform Profit Margin Impact:** Validate that the Social Reform Simulator accurately calculates factory profit margin erosion across minimum wage tiers (10% to 50% wage increases) against 5 test save states.
- [ ] **Bureaucrat Efficiency Tax Correlation:** Confirm that state administrative efficiency percentages (<1.0% bureaucrat density) correlate cleanly with uncollected tax revenue losses in `State_Economy__c`.
- [ ] **Textile Input Anomaly Trigger:** Verify that the Textile Input Monitor accurately detects global Dye and Cotton supply deficits before domestic textile factory bankruptcies occur.

## MVP Scope
- **Unified LWC Workspace (`c-social-reform-shell`):** Integrates Administrative Tax Heatmap, Unprofitable Factory Triage Card, and Labor Cost Simulator Panel.
- **Administrative Tax Efficiency Heatmap (`c-admin-efficiency-heatmap`):** SVG map coloring states by Bureaucrat Density / Administrative Efficiency to pinpoint tax leakage.
- **Top 3 Unprofitable Subsidized Factories Card (`c-unprofitable-factory-card`):** Aggregated view isolating heavy treasury-draining subsidized factories with 1-click subsidy removal toggles.
- **In-Memory Social Reform & Stockpile Sandbox (`SocialReformSimulator.cls`):** Sliders predicting factory bankruptcy risk under Minimum Wage/Safety reform tiers and military stockpile funding levels.
- **Invocable Conscription & Literacy Actions (`GetMobilizationCapacityAction.cls`):** Delivers target Clergy funding percentages (2.0%) and mobilizable brigade replenishment rates.

## Not Doing (and Why)
- **Automatic Save File Editing/Mutation:** We will NOT write modified `.v2` files back to disk. *Reason:* Preserves absolute data integrity; system functions strictly as a decision-support advisor.
- **Dynamic Trade Union Strike Simulation:** We will NOT simulate microscopic local labor union strike events. *Reason:* Focus strictly on macro social reform wage costs, factory margins, and national tax collection.
- **Direct Foreign Factory Confiscation via API:** We will NOT execute direct in-game nationalization commands. *Reason:* The system provides analytical warnings and advice, preserving player decision-making.

## Open Questions
- What mathematical weight should be assigned to POP consciousness growth vs. factory profit erosion when evaluating social reform recommendations?
- Should military stockpile buy-limits automatically adjust during active mobilization in the simulator sandbox?
