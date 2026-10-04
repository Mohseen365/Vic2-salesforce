# Victoria 2 Economy Analyzer — Save Game Import Contract Specification

**Document Status:** AUTHORITATIVE & FROZEN
**Contract Version:** `1.0.0`
**Target Pipeline:** External Off-Heap Save-Game Parser → Salesforce Ingestion API (`/services/apexrest/economy/import`)

---

## 1. System Boundary Architecture

```
┌───────────────────────────────┐
│ Victoria 2 Save File (.v2)    │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│ External EUG Parser (Off-Heap)│  Extracts raw nodes & transforms to DTO JSON payload
└───────────────┬───────────────┘
                │
                ▼ JSON Payload (Contract Version 1.0.0)
┌───────────────────────────────┐
│ REST Ingestion Endpoint       │  `EconomyImportRestResource.cls`
└───────────────┬───────────────┘
                │
                ▼ Deserialization
┌───────────────────────────────┐
│ EconomyImportRequestDTO       │  Apex Data Transfer Objects
└───────────────┬───────────────┘
                │
                ▼ Persistence & Business Logic
┌───────────────────────────────┐
│ EconomyImportService          │  Phase 6 Ingestion Pipeline & Auto-Provisioning
└───────────────────────────────┘
```

---

## 2. Ingestion Entity Specifications

### 2.1 Analysis Metadata (`AnalysisDTO`)
- **JSON Object Path:** `$.analysis`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `saveFileName` | string | String | `Economy_Analysis__c.Save_File_Name__c` | Text | Yes | Source save game identifier |
| `ingameDate` | string | String | `Economy_Analysis__c.Ingame_Date__c` | `YYYY-MM-DD` | Yes | In-game save timestamp date |
| `sourceFileName` | string | String | `Economy_Analysis__c.Source_Save_File_Name__c` | Text | No | Original source path / filename |
| `playerCountryTag` | string | String | `Economy_Analysis__c.Player_Country_Tag__c` | Text(10) | No | 3-letter country tag for player nation |
| `contractVersion` | string | String | — | SemVer (`1.0.0`) | Yes | Schema version tag |

---

### 2.2 Country Entities (`CountryDTO`)
- **JSON Array Path:** `$.countries[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `tag` | string | String | `Country__c.Tag__c` / `Country_Tag__c` | Text(10) | Yes | Master external key / Country Tag |
| `name` | string | String | `Country__c.Name` | Text | No | Country name |
| `flagUrl` | string | String | `Country__c.Flag_URL__c` | URL | No | Flag icon URL |
| `corePopulation` | number | Integer | `Country_Economy__c.Core_Population__c` | Headcount | No | Core non-colonial population |
| `colonyPopulation` | number | Integer | `Country_Economy__c.Colony_Population__c` | Headcount | No | Colonial population |
| `population` | number | Integer | `Country_Economy__c.Population__c` | Headcount | No | Total national population |
| `workforce` | number | Integer | `Country_Economy__c.Workforce__c` | Headcount | No | Total workforce |
| `employment` | number | Integer | `Country_Economy__c.Employment__c` | Headcount | No | Total employment |
| `gdp` | number | Decimal | `Country_Economy__c.GDP__c` | Annual £ | No | Total national GDP |
| `factoryGdp` | number | Decimal | `Country_Economy__c.Factory_GDP__c` | Annual £ | No | Factory sector GDP |
| `provinceGdp` | number | Decimal | `Country_Economy__c.Province_GDP__c` | Annual £ | No | RGO/Province sector GDP |
| `artisanGdp` | number | Decimal | `Country_Economy__c.Artisan_GDP__c` | Daily £ | No | Net artisan sector GDP |
| `goldIncome` | number | Decimal | `Country_Economy__c.Gold_Income__c` | Daily £ | No | National gold income |
| `totalImports` | number | Decimal | `Country_Economy__c.Total_Imports_Value__c` | Annual £ | No | Total import value |
| `totalExports` | number | Decimal | `Country_Economy__c.Total_Exports_Value__c` | Annual £ | No | Total export value |

---

### 2.3 Product Entities (`ProductDTO`)
- **JSON Array Path:** `$.products[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `code` | string | String | `Product__c.Code__c` / `Product_Code__c` | Text(50) | Yes | Product master code |
| `name` | string | String | `Product__c.Name` | Text | No | Product display name |
| `basePrice` | number | Decimal | `Product__c.Base_Price__c` / `Product_Economy__c.Base_Price__c` | Currency(18, 4) | No | Base commodity price |
| `price` | number | Decimal | `Product_Economy__c.Price__c` | Currency(18, 4) | No | Market price |
| `totalWorldSupply` | number | Decimal | `Product_Economy__c.Total_World_Supply__c` | Physical units | No | Total world supply |
| `realDemand` | number | Decimal | `Product_Economy__c.Real_Demand__c` | Physical units | No | Real market demand |
| `maxDemand` | number | Decimal | `Product_Economy__c.Max_Demand__c` | Physical units | No | Maximum market demand |

---

### 2.4 Country x Product Junction Entities (`CountryProductDTO`)
- **JSON Array Path:** `$.countryProducts[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `countryTag` | string | String | — | Text(10) | Yes | Parent Country lookup resolver |
| `productCode` | string | String | — | Text(50) | Yes | Parent Product lookup resolver |
| `soldDomestic` | number | Decimal | `Country_Product_Economy__c.Sold_Domestic__c` | Physical units | No | Quantity sold domestically |
| `boughtQuantity` | number | Decimal | `Country_Product_Economy__c.Bought_Quantity__c` | Physical units | No | Quantity bought |
| `thrownToMarket` | number | Decimal | `Country_Product_Economy__c.Thrown_To_Market__c` | Physical units | No | Quantity thrown to world market |
| `actualSoldWorld` | number | Decimal | `Country_Product_Economy__c.Actual_Sold_World__c` | Physical units | No | Quantity sold on world market |
| `worldmarketPool` | number | Decimal | `Country_Product_Economy__c.Worldmarket_Pool__c` | Physical units | No | World market pool volume |
| `intermediateConsumption` | number | Decimal | `Country_Product_Economy__c.Intermediate_Consumption__c` | Physical units | No | Quantity consumed internally |
| `totalSupplyPounds` | number | Decimal | `Country_Product_Economy__c.Total_Supply_Pounds__c` | Currency(18, 2) | No | Total supply monetary value |
| `actualSupplyPounds` | number | Decimal | `Country_Product_Economy__c.Actual_Supply_Pounds__c` | Currency(18, 2) | No | Actual supply monetary value |
| `actualDemandPounds` | number | Decimal | `Country_Product_Economy__c.Actual_Demand_Pounds__c` | Currency(18, 2) | No | Actual demand monetary value |

---

### 2.5 Province Entities (`ProvinceDTO`)
- **JSON Array Path:** `$.provinces[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `externalProvinceId` | string/number | Object/String | `Province__c.External_Province_Id__c` | Text(50) | Yes | External Province ID |
| `countryTag` | string | String | — | Text(10) | Yes | Parent Country tag |
| `stateCode` | string | String | — | Text(50) | No | Parent State Code (`<Tag>_<Name>`) |
| `population` | number | Integer | `Province_Economy__c.Population__c` | Headcount | No | Province population |
| `rgoProduction` | number | Decimal | `Province_Economy__c.RGO_Production__c` | Physical units | No | RGO production volume |
| `colony` | boolean | Boolean | `Province_Economy__c.Colony__c` | Boolean | No | Colonial status flag |
| `rgoIncome` | number | Decimal | `Province_Economy__c.RGO_Income__c` | Daily £ | No | RGO daily income |
| `rgoGdp` | number | Decimal | `Province_Economy__c.RGO_GDP__c` | Annual £ | No | RGO annual GDP contribution |
| `artisanSpending` | number | Decimal | `Province_Economy__c.Artisan_Spending__c` | Daily £ | No | Province artisan daily spending |
| `artisanIncome` | number | Decimal | `Province_Economy__c.Artisan_Income__c` | Daily £ | No | Province artisan daily income |
| `artisanGdp` | number | Decimal | `Province_Economy__c.Artisan_GDP__c` | Daily £ | No | Province artisan daily net AGDP |

---

### 2.6 State Entities (`StateDTO`)
- **JSON Array Path:** `$.states[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `stateCode` | string | String | `State__c.State_Code__c` | Text(50) | Yes | External State Code (`<Tag>_<Name>`) |
| `stateName` | string | String | `State__c.Name` | Text | No | Display state name |
| `countryTag` | string | String | — | Text(10) | Yes | Parent Country tag |
| `population` | number | Integer | `State_Economy__c.Population__c` | Headcount | No | State total population |
| `gdp` | number | Decimal | `State_Economy__c.GDP__c` | Annual £ | No | State total annual GDP |
| `gdpRank` | number | Integer | `State_Economy__c.GDP_Rank__c` | Integer | No | State GDP rank |
| `rgoIncome` | number | Decimal | `State_Economy__c.RGO_Income__c` | Daily £ | No | State RGO daily income |
| `pgdp` | number | Decimal | `State_Economy__c.PGDP__c` | Annual £ | No | State RGO annual GDP |
| `agdp` | number | Decimal | `State_Economy__c.AGDP__c` | Daily £ | No | State net artisan AGDP |
| `fgdp` | number | Decimal | `State_Economy__c.FGDP__c` | Annual £ | No | State factory annual GDP |
| `factoryEmployees` | number | Integer | `State_Economy__c.Factory_Employees__c` | Headcount | No | Total factory employees |
| `factoryRevenue` | number | Decimal | `State_Economy__c.Factory_Revenue__c` | Daily £ | No | Total factory daily revenue |
| `factoryProfit` | number | Decimal | `State_Economy__c.Factory_Profit__c` | Daily £ | No | Total factory daily profit |

---

### 2.7 Factory Entities (`FactoryDTO`)
- **JSON Array Path:** `$.factories[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `stateCode` | string | String | — | Text(50) | Yes | Parent State Code resolver |
| `countryTag` | string | String | — | Text(10) | Yes | Parent Country Tag resolver |
| `productCode` | string | String | — | Text(50) | No | Output Product code resolver |
| `buildingType` | string | String | `Factory_Economy__c.Building_Type__c` | Text(100) | Yes | Building building_type string |
| `occurrenceIndex` | number | Integer | `Factory_Economy__c.Occurrence_Index__c` | Integer | Yes | 1-based occurrence index in state |
| `level` | number | Integer | `Factory_Economy__c.Level__c` | Integer | No | Building expansion level |
| `employees` | number | Integer | `Factory_Economy__c.Employees__c` | Headcount | No | Factory headcount |
| `outputQuantity` | number | Decimal | `Factory_Economy__c.Output_Quantity__c` | Physical units | No | Daily production output |
| `unsoldQuantity` | number | Decimal | `Factory_Economy__c.Unsold_Quantity__c` | Physical units | No | Unsold leftover stock |
| `capitalReserves` | number | Decimal | `Factory_Economy__c.Capital_Reserves__c` | £ | No | Factory cash reserves (`money / 1000`) |
| `revenue` | number | Decimal | `Factory_Economy__c.Revenue__c` | Daily £ | No | Daily revenue |
| `inputCost` | number | Decimal | `Factory_Economy__c.Input_Cost__c` | Daily £ | No | Daily input cost |
| `wagesPaid` | number | Decimal | `Factory_Economy__c.Wages_Paid__c` | Daily £ | No | Daily wages paid |
| `injectedMoney` | number | Decimal | `Factory_Economy__c.Injected_Money__c` | £ | No | State subsidy injected money |
| `factoryGdp` | number | Decimal | `Factory_Economy__c.Factory_GDP__c` | Annual £ | No | Factory annual GDP (`(Rev - Cost) * 365`) |
| `profitRank` | number | Integer | `Factory_Economy__c.Profit_Rank__c` | Integer | No | Factory profit rank |

---

### 2.8 Artisan Entities (`ArtisanDTO`)
- **JSON Array Path:** `$.artisans[]`

| DTO Field | JSON Type | Apex Type | Target Salesforce Field | Unit / Format | Required | Description |
|---|---|---|---|---|---|---|
| `externalProvinceId` | string/number | Object/String | — | Text(50) | Yes | Parent Province ID resolver |
| `countryTag` | string | String | — | Text(10) | Yes | Parent Country Tag resolver |
| `stateCode` | string | String | — | Text(50) | No | Optional parent State Code |
| `productCode` | string | String | — | Text(50) | Yes | Parent Product Code resolver |
| `artisanType` | string | String | `Artisan_Economy__c.Artisan_Type__c` | Text(100) | No | Raw artisan category string |
| `spending` | number | Decimal | `Artisan_Economy__c.Spending__c` | Daily £ | No | Daily spending |
| `income` | number | Decimal | `Artisan_Economy__c.Income__c` | Daily £ | No | Daily income |
| `agdp` | number | Decimal | `Artisan_Economy__c.AGDP__c` | Daily £ | No | Daily net AGDP (clamped per Phase 1) |
| `productionQuantity` | number | Decimal | `Artisan_Economy__c.Production_Quantity__c` | Physical units | No | Physical production output |

---

## 3. Explicit Exclusions & Derivation Rules

The DTO contract **explicitly excludes** the following field categories. Incoming JSON payloads must not specify these fields; if present, they are ignored during ingestion:

1. **Salesforce Formula Fields:**
   - `State_Economy__c.GDP_Per_Capita__c`
   - `Country_Economy__c.GDP_Per_Capita__c`
   - `Factory_Economy__c.Profit__c`
   - `Factory_Economy__c.Productivity__c`
   - `Factory_Economy__c.Average_Wage__c`
   - `Product_Economy__c.Inflation_Percent__c`
   - `Product_Economy__c.Overproduction_Percent__c`
   - `Country_Economy__c.GDP_Share_Percent__c`
2. **Phase 5 Apex Calculation Engine Derived Fields:**
   - `Country_Product_Economy__c.Export_Value__c`
   - `Country_Product_Economy__c.Import_Value__c`
   - `Country_Product_Economy__c.Domestic_Sales_Value__c`
   - `Country_Product_Economy__c.GDP_Contribution__c`
3. **Constructed External Snapshot Keys (Constructed by Ingestion Pipeline):**
   - `State_Economy__c.Unique_Snapshot_Key__c` (`<AnalysisId>_<StateCode>`)
   - `Province_Economy__c.Unique_Snapshot_Key__c` (`<AnalysisId>_<ExternalProvId>`)
   - `Factory_Economy__c.Unique_Snapshot_Key__c` (`<AnalysisId>_<StateCode>_<BuildingType>_<OccurrenceIndex>`)
   - `Artisan_Economy__c.Unique_Snapshot_Key__c` (`<AnalysisId>_<ExternalProvId>_<ProductCode>`)

---

## 4. Idempotency & Versioning Policy

- **Contract Version Policy:** `contractVersion` is required inside `analysis`. Ingestion endpoints enforce strict major-version checks (`1.x.x`). Mismatched major versions are rejected immediately with HTTP 400.
- **Idempotency Strategy:** Snapshot keys are deterministically generated from business keys and analysis ID. Repeated imports for the same save file name update existing snapshot records safely without duplication.

---

## 5. GATE-1 Resolution Rules (Modded Commodities & Artisan Types)

1. **Unknown Products:** If a `productCode` in an incoming payload does not match an existing master `Product__c` record, the import pipeline automatically provisions a minimal `Product__c` record (`Code__c = productCode`, `Name = productCode`, `Base_Price__c = 0.0`).
2. **Unknown Artisan Types:** If an `artisanType` string in an incoming payload cannot be normalized to a valid product/artisan type, the import pipeline logs a diagnostic warning message to `Economy_Analysis__c.Import_Diagnostic_Message__c` and skips the individual artisan record without failing the import transaction.
