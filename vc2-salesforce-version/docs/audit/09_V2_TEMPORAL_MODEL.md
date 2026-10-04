# 09. Victoria 2 Temporal and Multi-Save Comparison Model

## Overview
This document specifies how time series analysis, multi-save trend tracking, and snapshot comparison operate across multiple Victoria 2 saves.

---

## 1. Multi-Save Hierarchy

```text
Campaign (Optional logical grouping)
  ├── Save Snapshot A (In-Game Date: 1836.01.01)
  ├── Save Snapshot B (In-Game Date: 1845.06.12)
  └── Save Snapshot C (In-Game Date: 1872.09.25)
```

---

## 2. Natural Key and Unique External ID Design

To prevent cross-save data contamination and ensure strict idempotency, all snapshot entities enforce composite external IDs prefixed with `Save_File_Name__c`:

| Object | Natural Key Components | Composite External ID Pattern (`Unique_Snapshot_Key__c`) |
| ------ | ---------------------- | ------------------------------------------------------- |
| `Economy_Analysis__c` | Save File Name | `<SaveFileName>` |
| `Country_Economy__c` | Save File Name + Country Tag | `<SaveFileName>_<CountryTag>` |
| `Product_Economy__c` | Save File Name + Product Code | `<SaveFileName>_<ProductCode>` |
| `Country_Product_Economy__c` | Save File Name + Country Tag + Product Code | `<SaveFileName>_<CountryTag>_<ProductCode>` |
| `State_Economy__c` | Save File Name + Country Tag + State Name | `<SaveFileName>_<CountryTag>_<StateName>` |
| `Province_Economy__c` | Save File Name + Province ID | `<SaveFileName>_<ProvinceId>` |
| `Factory_Economy__c` | Save File Name + State Key + Building Type + Index | `<SaveFileName>_<CountryTag>_<StateName>_<BuildingType>_<OccurrenceIndex>` |
| `Artisan_Economy__c` | Save File Name + Province ID + Product Code | `<SaveFileName>_<ProvinceId>_<ProductCode>` |

---

## 3. Comparative Save Delta Logic (`AnalysisComparisonDTO`)
When two snapshots (Save A = Baseline, Save B = Comparison) are queried in `EconomyAnalysisController.compareAnalyses`:
- **Absolute Delta:** $\Delta X = X_B - X_A$
- **Percentage Growth:** $\% \Delta X = rac{X_B - X_A}{X_A} 	imes 100\%$
- **Rank Change:** $\Delta 	ext{Rank} = 	ext{Rank}_A - 	ext{Rank}_B$ (Positive value indicates rank improvement).
