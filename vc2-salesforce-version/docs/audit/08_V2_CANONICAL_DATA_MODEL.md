# 08. Victoria 2 Canonical Domain Model

## Overview
The Canonical Domain Model is a technology-agnostic representation of the Victoria 2 economic domain. It separates persistent master definitions from temporal snapshot metrics and derived domain calculations.

---

## 1. Domain Entities & Conceptual Schema

```text
Campaign (1) ─── (N) SaveSnapshot
                     ├── (N) CountrySnapshot
                     │       ├── (N) StateSnapshot
                     │       │       ├── (N) FactorySnapshot
                     │       │       └── (N) ProvinceSnapshot
                     │       │               ├── (N) RGO
                     │       │               └── (N) ArtisanSnapshot
                     │       └── (N) CountryProductSnapshot
                     └── (N) ProductSnapshot
```

---

## 2. Entity Definitions & Record Grain

### A. SaveSnapshot
- **Record Grain:** 1 record per uploaded `.v2` save file.
- **Attributes:** SaveFileName, IngameDate, AnalysisTimestamp, PlayerCountryTag, TotalWorldGDP, TotalWorldPopulation, TotalWorldImports, TotalWorldExports, ImportStatus.

### B. CountrySnapshot
- **Record Grain:** 1 record per Country Tag per SaveSnapshot.
- **Attributes:** CountryTag, Population, CorePopulation, ColonyPopulation, Treasury, GDP, GDPPerCapita, GDPRank, FactoryWorkforce, FactoryEmployment, RGOWorkforce, RGOEmployment, FactoryGDP, RGOGDP, ArtisanGDP.

### C. ProductSnapshot
- **Record Grain:** 1 record per Commodity Code per SaveSnapshot.
- **Attributes:** ProductCode, BasePrice, Price, TotalWorldSupply, RealDemand, MaxDemand, InflationPercent, OverproductionPercent.

### D. CountryProductSnapshot
- **Record Grain:** 1 record per Country Tag x Commodity Code per SaveSnapshot.
- **Attributes:** CountryTag, ProductCode, SoldDomestic, BoughtQuantity, SoldQuantity, ThrownToMarket, ImportValue, ExportValue, DomesticSalesValue, GDPContribution.

### E. StateSnapshot
- **Record Grain:** 1 record per State Code per SaveSnapshot.
- **Attributes:** CountryTag, StateCode, Population, GDP, FactoryEmployees, FactoryRevenue, FactoryProfit, PGDP, FGDP, AGDP.

### F. FactorySnapshot
- **Record Grain:** 1 record per Factory Instance per SaveSnapshot.
- **Attributes:** StateCode, BuildingType, Level, Employees, InputCost, Revenue, WagesPaid, Profit, Productivity, CapitalReserves.

### G. ArtisanSnapshot
- **Record Grain:** 1 record per Province x Product per SaveSnapshot.
- **Attributes:** ProvinceId, ProductCode, ArtisanType, ProductionQuantity, Income, Spending, AGDP.
