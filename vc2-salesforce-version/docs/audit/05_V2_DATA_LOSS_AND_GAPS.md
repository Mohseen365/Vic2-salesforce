# 05. Victoria 2 Save Game Data Loss and Gap Analysis

## 1. What Important Data Does `.v2` Contain That Is Currently Ignored?
1. **POP-Level Granular Data (46,282 records):** Detailed POP militancy, consciousness, literacy, cash reserves, and political issue distributions. Currently aggregated at Province level to prevent Salesforce LDV (Large Data Volume) governor limit exhaustion.
2. **Diplomacy & Sphere of Influence:** Spheres of influence, diplomatic relations (-200 to +200), truces, and alliance networks.
3. **Active and Past Military Conflicts:** War score, attacker/defender tags, war goals, and battle statistics.
4. **Technology & Inventions:** Specific researched technology codes and invention dates per nation.
5. **Political Parties and Elections:** Party ideology percentages in lower/upper house and voter preferences.

---

## 2. Information That Cannot Be Reliably Extracted Without External Game Files
1. **Human-Readable Localized Names:** Country names (e.g. `TUR` → "Ottoman Empire"), state names, culture names, and tech names require `localisation/*.csv`.
2. **Factory Input/Output Production Recipes:** Production throughput formulas and exact input goods per factory level require `common/production_types.txt`.
3. **Ideology and Issue Enum Map:** Numeric key mappings for issues (e.g., `1` → "Slavery: Allowed") require `common/ideologies.txt` and `common/issues.txt`.

---

## 3. Recommended Preservation Strategy
- **Preserve Raw `.v2` File:** Store the exact `.v2` file as a `ContentVersion` attached to `Economy_Analysis__c`.
- **Preserve Off-Heap Intermediate JSON:** Retain the full parsed JSON payload in external blob storage or Queueable payload for future feature expansion without re-parsing.
