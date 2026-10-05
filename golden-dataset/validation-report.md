# Victoria 2 Economy Analyzer — Phase 0 Validation Report

## 1. Input Save File
- **File:** `egypt.v2`
- **Path:** `/tmp/file_attachments/savegames/egypt.v2`
- **Size:** 27059272 bytes (27.06 MB)
- **SHA-256:** `f203943cf601df8771e15bf158b05c7f7f1606283c6ce1a86b2a227f58715154`
- **Parse Status:** SUCCESS

## 2. Parser Execution
- **Parser Class:** `eug.parser.CWordFile` / `Vic2SaveGameCustom`
- **Consumer:** `Report.GenericObjectConsumer`
- **Modifications:** None. Standard production legacy parser used without altering economic formulas.

## 3. Dataset Record Summary
- **Countries Parsed:** 118
- **Provinces Parsed:** 3248
- **Products Parsed:** 49
- **ProductStorage Records:** 3772
- **Derived Calculation Records:** 3940

## 4. Economic Calculation Verifications
- **GDP Verified:** YES (`Country.innerCalculations()` + `ProductStorage.getGdpPounds()`)
- **GDP Share Verified:** YES (`Country.calcGdpPart()`)
- **Overproduction Verified:** YES (`Product.getOverproduced()` = `supply / demand * 100`)
- **Inflation Verified:** YES (`Product.getInflation()` = `price / basePrice * 100`)
- **Gold / Precious Metals Handling:** Verified (`precious_metal` RGO income tracked in `goldIncome` and added to country GDP).
- **Division-by-zero Safeguards:** Verified. `Float.NaN` and `Float.POSITIVE_INFINITY` sanitized to `0.0` in Golden Exporter.

## 5. Regional & Key Nation Summary (`egypt.v2`)
- **Save Game Note:** In `egypt.v2`, tag `EGY` (Egypt) is an unowned/inactive tag node (population = 0, no active state/provinces). The Ottoman Empire (`TUR`) controls the region.
- **TUR (Ottoman Empire / Region Control):** Population = 189927264, GDP = 22681.33 £, Rank = 2
- **ENG (United Kingdom):** Population = 89656212, GDP = 15961.11 £, Rank = 3
- **FRA (France):** Population = 40694084, GDP = 11182.59 £, Rank = 5
- **USA (United States):** Population = 13842876, GDP = 3849.17 £, Rank = 10

## 6. Reproducibility Command
```bash
cd vic2_economy_analyzer/vic2_economy_analyzer-master
./gradlew classes
java -cp "build/classes/java/main:build/resources/main:libs/*:$HOME/.gradle/caches/modules-2/files-2.1/com.google.code.gson/gson/2.8.9/*/gson-2.8.9.jar" \
  org.victoria2.tools.vic2sgea.export.GoldenDatasetExporterMain \
  "/tmp/file_attachments/savegames/egypt.v2" \
  "../../vc2-salesforce-version/golden-dataset/sample-game-data" \
  "../../vc2-salesforce-version/golden-dataset/sample-game-data" \
  "../../vc2-salesforce-version/golden-dataset"
```
