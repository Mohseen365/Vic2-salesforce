# 07. Victoria 2 External Game File Dependencies

## Overview
While the primary economic metrics (prices, supplies, demands, cash pools, factory levels) can be parsed directly from `egypt.v2`, full semantic enrichment requires reference data from Victoria 2 installation files.

---

## Dependency Classification

| External File Path | Information Provided | Necessity Level | Salesforce Strategy |
| ------------------ | -------------------- | --------------- | ------------------- |
| `common/production_types.txt` | Base prices, factory input/output goods, factory workforce ratios | OPTIONAL ENRICHMENT | Pre-loaded into `Product__c` custom settings or master data records. |
| `localisation/*.csv` | Localized country names, province names, ideology labels | OPTIONAL ENRICHMENT | Mapped via static lookup maps in Apex or custom metadata types. |
| `map/definition.csv` | Province ID to geographic coordinates and region mappings | OPTIONAL ENRICHMENT | Pre-populated into `Province__c` master records. |
| `history/countries/*.txt` | Starting national culture, religion, and capital definitions | OPTIONAL ENRICHMENT | Fallback lookup for uninitialized tags. |

---

## Fallback Strategy When External Files Are Missing
1. **Country Tag Fallback:** Display tag (e.g., `TUR`, `EGY`) as the country name if localized string is unavailable.
2. **Modded Commodity Auto-Provisioning:** Assign `Base_Price__c = 0.0` and fallback name equal to code.
3. **Province Mapping:** Fallback to numeric province ID string as province name.
