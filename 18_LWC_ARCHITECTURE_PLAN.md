# 18. Lightning Web Component (LWC) Architecture Plan

## Overview
The frontend architecture provides a tabbed analytical suite powered by 15 LWC bundles.

---

## LWC Workspace Component Tree

```text
c-economy-analyzer-shell (Main Container Shell)
├── c-economy-analysis-header (Analysis selector & global KPI header)
├── c-save-game-watcher-status (EMP API event listener for real-time import updates)
├── c-economic-export-modal & c/economicExportUtils (CSV export engine)
└── Tab Workspace Views:
    ├── 🌐 Global Overview (c-global-economy-dashboard)
    ├── 🏛️ Country Explorer (c-country-dashboard)
    ├── 📦 Product Market (c-product-list-view & c-product-dashboard)
    ├── 📈 Analytics & Visualizations (c-economic-charts-container - SVG Charts)
    └── 📊 Compare Saves (c-analysis-compare)
```

---

## Component Specifications

1. **`c-global-economy-dashboard`**: Displays top 10 country GDP table, top 10 commodities table, world KPIs, and embedded SVG chart views.
2. **`c-country-dashboard`**: Country detail view featuring economic trade breakdown datatable, per capita metrics, and regional SVG breakdown.
3. **`c-product-list-view` & `c-product-dashboard`**: Commodity search grid, market equilibrium indicators, and country trade participation sub-tables.
4. **`c-economic-charts-container`**: Pure SVG rendering engine for bar charts, scatter plots, and market distribution graphs.
5. **`c-analysis-compare`**: Comparative delta selection tool comparing two save snapshots side-by-side with GDP growth indicators.
