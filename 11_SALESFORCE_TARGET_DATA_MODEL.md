# 11. Salesforce Target Data Model Architecture

## Overview
The Salesforce Target Data Model maps the Canonical Model into native Salesforce custom objects, master-detail relationships, lookup fields, external IDs, and formula fields.

---

## Object Architecture Diagram

```text
[Economy_Analysis__c] (Header)
  ├── (Master-Detail) ──> [Country_Economy__c]
  │                             ├── (Master-Detail) ──> [Country_Product_Economy__c]
  │                             ├── (Lookup) ─────────> [Country__c] (Master Tag)
  │                             ├── (Master-Detail) ──> [Province_Economy__c]
  │                             │                             └── (Lookup) ─> [Province__c]
  │                             └── (Lookup) ─────────> [State_Economy__c]
  │                                                           ├── (Lookup) ─> [State__c]
  │                                                           ├── (Lookup) ─> [Factory_Economy__c]
  │                                                           └── (Lookup) ─> [Artisan_Economy__c]
  ├── (Master-Detail) ──> [Product_Economy__c]
  │                             └── (Lookup) ─────────> [Product__c] (Master Product)
  ├── (Master-Detail) ──> [Factory_Economy__c]
  └── (Master-Detail) ──> [Artisan_Economy__c]
```

---

## Target Object Summaries

1. **`Economy_Analysis__c`**: Parent analysis header for each save file import.
2. **`Country__c`**: Master reference object for 3-letter ISO country tags.
3. **`Country_Economy__c`**: Country snapshot containing national population, GDP, employment, and trade.
4. **`Product__c`**: Master reference object for commodity codes and default base prices.
5. **`Product_Economy__c`**: Commodity market snapshot capturing global prices, supply, demand, and overproduction.
6. **`Country_Product_Economy__c`**: Country x Product junction snapshot storing domestic trade, import/export values, and GDP contributions.
7. **`State__c`**: Master reference object for state region definitions.
8. **`State_Economy__c`**: State regional snapshot capturing population, regional GDP, factory revenue, and artisan production.
9. **`Province__c`**: Master reference object for 3,248 geographic provinces.
10. **`Province_Economy__c`**: Regional province snapshot for population and RGO output.
11. **`Factory_Economy__c`**: Factory-level economic snapshot capturing level, workforce, revenue, input cost, and wages.
12. **`Artisan_Economy__c`**: Artisan demographic snapshot capturing local artisan production, income, and spending.
13. **`Economy_Import_Event__e`**: Platform event for real-time import status updates.
