# 06. Victoria 2 Save File Data Quality and Validation Rules

## 1. Observed Save Game Anomalies & Edge Cases
- **Modded Commodities & Artisan Types:** Custom mods introduce new commodity codes (e.g. `fuel`, `electric_gear`) not in vanilla Victoria 2.
- **Unassigned / Landless Countries:** Defeated or unreleased country tags exist in the save file with 0 population, 0 provinces, and £0 treasury.
- **Floating-Point Precision:** Save files store floats with up to 5 decimal places (e.g., `3.91412`).
- **Composite State Keys:** State names in save files are non-unique across countries (e.g., "Cairo" or "Texas"). External keys must use composite format `<CountryTag>_<StateName>`.

---

## 2. Validation Rules & Safeguards

```text
RULE 1: Division-by-Zero Protection
All Apex formulas and custom formula fields MUST use IF safeguard:
IF(Denominator > 0, Numerator / Denominator, 0.0)

RULE 2: Modded Product Auto-Provisioning (GATE-1)
When an unrecognized commodity code is encountered during ingestion:
Auto-create Product__c record with Base_Price__c = 0.0 and log diagnostic warning.

RULE 3: Composite State External ID (GATE-2)
State__c external ID format MUST be enforced as '<CountryTag>_<StateName>'.

RULE 4: Idempotency & Unique Snapshot Keys
Every snapshot record MUST compute a Unique_Snapshot_Key__c formatted as:
<SaveFileName>_<EntityKey>
```
