# ADR-2C-GDP: Country GDP Formula Reconciliation

## Status
PROPOSED — pending human ratification

## Context
- Docs 10 and 13 describe Country GDP as:
      Factory_GDP + Province_GDP + Artisan_GDP
- EconomyCalculationEngine.cls (lines 128–152) implements:
      sumGdp      = Σ Country_Product_Economy__c.GDP_Contribution__c
      GDP_Contrib = max(soldUnits − intermediateConsumption, 0) × price
      Country.GDP = hasPreciousMetalJunction ? sumGdp : (sumGdp + goldIncome)
- vc2-salesforce-version/formula-notes.md (Gate 2, lines 39–79) documents
  the legacy implementation with matching semantics.
- No `.java` source files exist in the repository. formula-notes.md is the
  surviving bridge document.
- Phase 2D confirmed the three fields
      Actual_Sold_World__c, Worldmarket_Pool__c, Intermediate_Consumption__c
  are present in metadata and referenced by the engine but omitted from
  doc 12’s narrative inventory.

## Decision
- EconomyCalculationEngine.cls is authoritative.
- Docs 10 and 13 will be amended to reflect the actual computation chain.
- Doc 12 will be amended to list the three missing fields.
- formula-notes.md is ratified as the canonical specification of legacy
  behavior for this project.

## Consequences
- Documentation aligns with engine logic.
- No Apex or metadata change is required.
- If future evidence contradicts formula-notes.md, this ADR must be reopened.

## Ratification
- Architect: __________________ Date: __________
- Product:   __________________ Date: __________
