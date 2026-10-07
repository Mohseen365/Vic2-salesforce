Here's what I now think you want:

- Outcome:      The full Victoria 2 platform (economy, factory/industry, war-goal
                prediction, rebellion, social reform, colonization, and the rest of §3)
                built breadth-first on Salesforce — every domain's headline card stood up
                early as a thin slice, then deepened over time. Each thin slice shows the
                computed metric plus its one-line binding constraint (e.g., "War Goal
                Achievability: low — because military tech trails by 2 levels").
- User:         You — an experienced Victoria 2 player, mid-campaign, on your own saves.
- Why now:      The .v2 → Salesforce import pipeline already works, so the analytical
                layer is the bottleneck; and you want the whole tool visible, not one
                domain finished.
- Success:      You open the tool mid-campaign and see every domain at once — each
                domain's headline number with the constraint that explains it — even
                before any domain is deep.
- Constraint:   Salesforce/Apex governor limits; pure-math compute path, no DML;
                solo build; deterministic factor models (no simulation, no probability);
                each slice must name its binding constraint, not just show a number.
- Out of scope: Tick-by-tick simulation, Monte Carlo, coalition handling (v1), and the
                deep versions of each domain (full sandboxes, Agentforce layer, per-domain
                watcher suites) — those come after the breadth-first v1 exists.

Yes / no / refine?
