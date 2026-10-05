# Victoria 2 Economy Analyzer — Manual End-to-End Test Script

This document provides a step-by-step manual test procedure to verify the complete user journey and technical workflows of the Victoria 2 Economy Analyzer Salesforce Application.

---

## Environment Prerequisites

- Salesforce Org with `Economy_Analyzer_Admin` Permission Set assigned.
- `Economy_Analysis__c`, `Country_Economy__c`, `Product_Economy__c`, `Country_Product_Economy__c`, and `Province_Economy__c` custom objects deployed.
- Off-heap EUG parser service or curl/Postman configured to transmit save JSON payloads to REST endpoint `/services/apexrest/economy/import`.

---

## Step-by-Step Test Procedure

### Step 1: Ingest Save Game via REST Endpoint

1. Send a `POST` request to `/services/apexrest/economy/import` carrying a save payload (e.g. `egypt.v2` parsed JSON bundle).
2. **Expected Response:**
   - HTTP Status: `200 OK` or `202 Accepted`
   - Response Body:
     ```json
     {
       "analysisId": "a00...",
       "status": "RECEIVED",
       "message": "Analysis import payload received successfully."
     }
     ```

---

### Step 2: Observe Real-Time Status Transitions in Header Watcher

1. Open the Lightning App **Victoria 2 Economy Analyzer**.
2. Observe the watcher status pill in `c-save-game-watcher-status` (driven by `lightning/empApi` listening to `Economy_Import_Event__e`).
3. **Expected State Transitions:**
   - `RECEIVED` (Blue badge) → `PROCESSING` (Yellow badge) → `CALCULATING` (Purple badge) → `COMPLETED` (Green badge).
4. Upon reaching `COMPLETED`, the UI automatically refreshes analysis combobox options and loads current metrics.

---

### Step 3: Tab Navigation & Dashboard Exploration

#### 3.1 Global Overview Tab
- **Action:** Select Global Overview tab in `c-economy-analyzer-shell`.
- **Expected Outcome:** Displays overall Save File Name, Ingame Date, Player Country Tag, Total World GDP (£), Total Population, World Imports (£), and World Exports (£).

#### 3.2 Country Explorer Tab
- **Action:** Select Country Explorer tab.
- **Expected Outcome:**
  - Datatable lists all 118 countries sorted by `GDP__c` descending with deterministic tie-breaking by `Country_Tag__c` ascending.
  - Search box filters countries dynamically by tag or official name.
  - Selecting a country row displays SVG charts (`c-economic-charts-container`) showing GDP per capita and top exported goods.

#### 3.3 Product Market Tab
- **Action:** Select Product Market tab.
- **Expected Outcome:**
  - Displays grid of 49 products with price, inflation %, real demand, and overproduction %.
  - Clicking a product row drills into `c-product-dashboard` detailing world market supply/demand ratio and country breakdown.
  - Clicking **Back to Product List** returns to the main grid.

#### 3.4 Analytics Tab
- **Action:** Select Analytics tab.
- **Expected Outcome:** Displays SVG multi-chart workspace (World GDP Share pie/donut SVG, Top Export Commodities bar SVG, Price Trend line SVG).

#### 3.5 Compare Saves Tab
- **Action:** Select Compare Saves tab.
- **Expected Outcome:** Displays placeholder notice confirming compare UI reservation for future releases.

---

### Step 4: Data Export & RFC 4180 Download

1. Click the **Export Data** button from Header, Country Explorer, or Product Market.
2. The modal dialog (`c-economic-export-modal`) opens with the selected scope (`Summary`, `Countries`, `Products`, `CountryProducts`, or `Provinces`).
3. Verify the row count preview indicator:
   - For ≤ 5,000 rows (e.g., `Countries` scope with 118 rows): Client-side export module `c/economicExportUtils` generates CSV.
   - For > 5,000 rows: Calls Apex fallback `EconomyAnalysisController.exportCsv`.
4. Click **Export CSV**.
5. **Expected Outcome:**
   - File downloads automatically with name pattern `${saveFileName}_${scope}_${ingameDate}.csv` (e.g. `egypt_1836_countries_1836-01-01.csv`).
   - SLDS Success Toast displays: `"Export completed successfully"`.

---

### Step 5: CSV Parity Verification

1. Open the downloaded CSV file in a text editor or spreadsheet tool.
2. Compare against the corresponding Phase 0 golden CSV in `vc2-salesforce-version/golden-dataset/csv/`.
3. **Expected Outcome:**
   - Values match byte-for-byte or within Section 2.2 tolerances (Monetary: 2 dec, Prices: 4 dec, Percentages: 2 dec, Ranks: Exact integer).
