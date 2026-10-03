# Pipeline Extraction Summary

```text
egypt.v2
  ↓
EUGFileIO / CWordFile
  ↓
EUGScanner (Tokenizing Clausewitz syntax)
  ↓
GenericObjectConsumer (Root level routing)
  ├── loadProvince() -> Country population, workforce, RGO gold income
  ├── loadCountry() -> ProductStorage, soldDomestic, factory stockpiles
  └── loadGlobalProductInfo() -> World market prices, demand, supply pools
  ↓
Report.countTotals()
  ├── Country.innerCalculations() -> ProductStorage sold, imported, exported, GDP
  ├── Country.calcGdpPart() -> Global GDP Share %
  └── Product.getOverproduced() & getInflation()
  ↓
GoldenDatasetExporterMain -> RAW, DERIVED, EXPECTED, CSV, Markdown
```
