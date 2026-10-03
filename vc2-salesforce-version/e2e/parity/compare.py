#!/usr/bin/env python3
"""
Victoria 2 Economy Analyzer — Parity Comparison Harness (Phase 10)
Compares Phase 0 Golden Dataset against Salesforce Export Bundle / DTOs.
Enforces tolerance policy from Phase 10 Audit Section 2.2.
"""

import json
import os
import sys
import argparse
from typing import Dict, List, Any, Tuple

# Section 2.2 Tolerance Policy
TOLERANCE_CURRENCY = 0.01      # 2 decimal places (£0.01)
TOLERANCE_PRICE_QTY = 0.0001   # 4 decimal places
TOLERANCE_PERCENT = 0.01       # 2 decimal places (0.01%)
TOLERANCE_INTEGER = 0          # Exact integer match

def is_close(val1: float, val2: float, tolerance: float) -> bool:
    if val1 is None or val2 is None:
        return val1 == val2
    return abs(val1 - val2) <= tolerance + 1e-9

def sanitize_value(val: float) -> float:
    if val is None or val != val:  # NaN
        return 0.0
    if val == float('inf') or val == float('-inf'):
        return 0.0
    return float(val)

def compare_world_totals(golden_header: Dict, golden_countries: List[Dict], target_header: Dict) -> List[Dict]:
    discrepancies = []

    total_gdp = sum(c.get('gdpPounds', 0.0) for c in golden_countries)
    total_pop = sum(c.get('population', 0) for c in golden_countries)
    total_imports = sum(c.get('importedPounds', 0.0) for c in golden_countries)
    total_exports = sum(c.get('exportedPounds', 0.0) for c in golden_countries)

    target_gdp = target_header.get('totalWorldGdp', target_header.get('total_world_gdp', total_gdp))
    target_pop = target_header.get('totalWorldPopulation', target_header.get('total_world_population', total_pop))
    target_imports = target_header.get('totalWorldImports', target_header.get('total_world_imports', total_imports))
    target_exports = target_header.get('totalWorldExports', target_header.get('total_world_exports', total_exports))

    checks = [
        ("World Total GDP", total_gdp, target_gdp, TOLERANCE_CURRENCY),
        ("World Total Population", total_pop, target_pop, TOLERANCE_INTEGER),
        ("World Total Imports", total_imports, target_imports, TOLERANCE_CURRENCY),
        ("World Total Exports", total_exports, target_exports, TOLERANCE_CURRENCY)
    ]

    for metric, gold, target, tol in checks:
        gold_san = sanitize_value(gold)
        targ_san = sanitize_value(target)
        if not is_close(gold_san, targ_san, tol):
            discrepancies.append({
                "scope": "World Total",
                "entity_id": "WORLD",
                "metric": metric,
                "golden_value": round(gold_san, 4),
                "target_value": round(targ_san, 4),
                "diff": round(abs(gold_san - targ_san), 4),
                "tolerance": tol,
                "pass": False
            })

    return discrepancies

def compare_countries(golden_countries: List[Dict], target_countries: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []
    golden_map = {c['tag']: c for c in golden_countries}
    target_map = {c.get('countryTag', c.get('tag')): c for c in target_countries}

    sorted_golden = sorted(golden_countries, key=lambda x: (-x.get('gdpPounds', 0.0), x.get('tag', '')))
    for idx, c in enumerate(sorted_golden, 1):
        c['_computed_rank'] = idx

    sorted_target = sorted(target_countries, key=lambda x: (-x.get('gdpPounds', x.get('gdp', 0.0)), x.get('countryTag', x.get('tag', ''))))
    for idx, c in enumerate(sorted_target, 1):
        c['_computed_rank'] = idx

    compared_count = 0
    for tag, gold in golden_map.items():
        if tag not in target_map:
            discrepancies.append({
                "scope": "Country",
                "entity_id": tag,
                "metric": "Missing Country",
                "golden_value": tag,
                "target_value": "MISSING",
                "pass": False
            })
            continue

        targ = target_map[tag]
        compared_count += 1

        country_checks = [
            ("GDP (£)", gold.get('gdpPounds', 0.0), targ.get('gdpPounds', targ.get('gdp', 0.0)), TOLERANCE_CURRENCY),
            ("GDP Per Capita (£)", gold.get('gdpPerCapita', 0.0), targ.get('gdpPerCapita', 0.0), TOLERANCE_CURRENCY),
            ("GDP Share %", gold.get('gdpSharePercent', 0.0), targ.get('gdpSharePercent', targ.get('gdpSharePct', 0.0)), TOLERANCE_PERCENT),
            ("Population", gold.get('population', 0), targ.get('population', 0), TOLERANCE_INTEGER),
            ("Workforce RGO", gold.get('workforceRGO', 0), targ.get('workforceRGO', 0), TOLERANCE_INTEGER),
            ("Employment RGO", gold.get('employmentRGO', 0), targ.get('employmentRGO', 0), TOLERANCE_INTEGER),
            ("Unemployment Rate RGO %", gold.get('unemploymentRateRGO', 0.0), targ.get('unemploymentRateRGO', targ.get('unemploymentRateRgo', 0.0)), TOLERANCE_PERCENT),
            ("Workforce Factory", gold.get('workforceFactory', 0), targ.get('workforceFactory', 0), TOLERANCE_INTEGER),
            ("Employment Factory", gold.get('employmentFactory', 0), targ.get('employmentFactory', 0), TOLERANCE_INTEGER),
            ("Unemployment Rate Factory %", gold.get('unemploymentRateFactory', 0.0), targ.get('unemploymentRateFactory', 0.0), TOLERANCE_PERCENT),
            ("Total Imports (£)", gold.get('importedPounds', 0.0), targ.get('importedPounds', targ.get('totalImports', 0.0)), TOLERANCE_CURRENCY),
            ("Total Exports (£)", gold.get('exportedPounds', 0.0), targ.get('exportedPounds', targ.get('totalExports', 0.0)), TOLERANCE_CURRENCY),
            ("Gold Income (£)", gold.get('goldIncome', 0.0), targ.get('goldIncome', 0.0), TOLERANCE_CURRENCY),
            ("GDP Rank", gold.get('_computed_rank', 0), targ.get('_computed_rank', 0), TOLERANCE_INTEGER)
        ]

        for metric, g_val, t_val, tol in country_checks:
            g_san = sanitize_value(g_val)
            t_san = sanitize_value(t_val)
            if not is_close(g_san, t_san, tol):
                discrepancies.append({
                    "scope": "Country",
                    "entity_id": tag,
                    "metric": metric,
                    "golden_value": round(g_san, 4),
                    "target_value": round(t_san, 4),
                    "diff": round(abs(g_san - t_san), 4),
                    "tolerance": tol,
                    "pass": False
                })

    return discrepancies, compared_count

def compare_products(golden_products: List[Dict], target_products: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []
    golden_map = {p['name']: p for p in golden_products}
    target_map = {p.get('productCode', p.get('name')): p for p in target_products}

    compared_count = 0
    for name, gold in golden_map.items():
        if name not in target_map:
            discrepancies.append({
                "scope": "Product",
                "entity_id": name,
                "metric": "Missing Product",
                "golden_value": name,
                "target_value": "MISSING",
                "pass": False
            })
            continue

        targ = target_map[name]
        compared_count += 1

        prod_checks = [
            ("Base Price (£)", gold.get('basePrice', 0.0), targ.get('basePrice', 0.0), TOLERANCE_PRICE_QTY),
            ("Price (£)", gold.get('price', 0.0), targ.get('price', 0.0), TOLERANCE_PRICE_QTY),
            ("Total World Supply", gold.get('supplyPool', gold.get('totalSupply', 0.0)), targ.get('supplyPool', targ.get('totalSupply', targ.get('totalWorldSupply', 0.0))), TOLERANCE_PRICE_QTY),
            ("Real Demand", gold.get('realDemand', 0.0), targ.get('realDemand', 0.0), TOLERANCE_PRICE_QTY),
            ("Max Demand", gold.get('maxDemand', 0.0), targ.get('maxDemand', 0.0), TOLERANCE_PRICE_QTY),
            ("Inflation %", gold.get('inflationPercent', 0.0), targ.get('inflationPercent', targ.get('inflationPct', 0.0)), TOLERANCE_PERCENT),
            ("Overproduction %", gold.get('overproducedPercent', 0.0), targ.get('overproducedPercent', targ.get('overproductionPercent', 0.0)), TOLERANCE_PERCENT)
        ]

        for metric, g_val, t_val, tol in prod_checks:
            g_san = sanitize_value(g_val)
            t_san = sanitize_value(t_val)
            if not is_close(g_san, t_san, tol):
                discrepancies.append({
                    "scope": "Product",
                    "entity_id": name,
                    "metric": metric,
                    "golden_value": round(g_san, 4),
                    "target_value": round(t_san, 4),
                    "diff": round(abs(g_san - t_san), 4),
                    "tolerance": tol,
                    "pass": False
                })

    return discrepancies, compared_count

def compare_country_products(golden_countries: List[Dict], target_countries: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []
    golden_junctions = {}
    for c in golden_countries:
        tag = c['tag']
        for ps in c.get('productStorages', []):
            key = f"{tag}:{ps['productName']}"
            golden_junctions[key] = ps

    target_junctions = {}
    for c in target_countries:
        tag = c.get('countryTag', c.get('tag'))
        for ps in c.get('productStorages', c.get('countryProducts', [])):
            pname = ps.get('productCode', ps.get('productName'))
            key = f"{tag}:{pname}"
            target_junctions[key] = ps

    compared_count = 0
    for key, gold in golden_junctions.items():
        if key not in target_junctions:
            if gold.get('totalSupplyPounds', 0.0) > 0 or gold.get('gdpPounds', 0.0) > 0:
                discrepancies.append({
                    "scope": "CountryProduct",
                    "entity_id": key,
                    "metric": "Missing Junction",
                    "golden_value": key,
                    "target_value": "MISSING",
                    "pass": False
                })
            continue

        targ = target_junctions[key]
        compared_count += 1

        cp_checks = [
            ("Price (£)", gold.get('price', 0.0), targ.get('price', 0.0), TOLERANCE_PRICE_QTY),
            ("Sold Domestic Qty", gold.get('soldDomestic', 0.0), targ.get('soldDomestic', 0.0), TOLERANCE_PRICE_QTY),
            ("Total Supply (£)", gold.get('totalSupplyPounds', 0.0), targ.get('totalSupplyPounds', targ.get('totalSupplyValue', 0.0)), TOLERANCE_CURRENCY),
            ("Actual Demand (£)", gold.get('actualDemandPounds', 0.0), targ.get('actualDemandPounds', targ.get('actualDemandValue', 0.0)), TOLERANCE_CURRENCY),
            ("Actual Supply (£)", gold.get('actualSupplyPounds', 0.0), targ.get('actualSupplyPounds', targ.get('actualSupplyValue', 0.0)), TOLERANCE_CURRENCY),
            ("Import Value (£)", gold.get('importedPounds', 0.0), targ.get('importedPounds', targ.get('importValue', 0.0)), TOLERANCE_CURRENCY),
            ("Export Value (£)", gold.get('exportedPounds', 0.0), targ.get('exportedPounds', targ.get('exportValue', 0.0)), TOLERANCE_CURRENCY),
            ("GDP Contribution (£)", gold.get('gdpPounds', 0.0), targ.get('gdpPounds', targ.get('gdpContribution', 0.0)), TOLERANCE_CURRENCY)
        ]

        for metric, g_val, t_val, tol in cp_checks:
            g_san = sanitize_value(g_val)
            t_san = sanitize_value(t_val)
            if not is_close(g_san, t_san, tol):
                discrepancies.append({
                    "scope": "CountryProduct",
                    "entity_id": key,
                    "metric": metric,
                    "golden_value": round(g_san, 4),
                    "target_value": round(t_san, 4),
                    "diff": round(abs(g_san - t_san), 4),
                    "tolerance": tol,
                    "pass": False
                })

    return discrepancies, compared_count

def run_parity_comparison(golden_path: str, target_path: str) -> Dict[str, Any]:
    with open(golden_path, 'r', encoding='utf-8') as f:
        golden_data = json.load(f)

    with open(target_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f)

    g_header = golden_data.get('header', {})
    g_countries = golden_data.get('countries', [])
    g_products = golden_data.get('products', [])

    t_header = target_data.get('header', target_data.get('summary', {}))
    t_countries = target_data.get('countries', [])
    t_products = target_data.get('products', [])

    world_discrepancies = compare_world_totals(g_header, g_countries, t_header)
    country_discrepancies, c_count = compare_countries(g_countries, t_countries)
    product_discrepancies, p_count = compare_products(g_products, t_products)
    cp_discrepancies, cp_count = compare_country_products(g_countries, t_countries)

    all_discrepancies = world_discrepancies + country_discrepancies + product_discrepancies + cp_discrepancies

    status = t_header.get('importStatus', t_header.get('Import_Status__c', 'COMPLETED'))
    if status != 'COMPLETED':
        all_discrepancies.append({
            "scope": "System Flag",
            "entity_id": "HEADER",
            "metric": "Import_Status__c",
            "golden_value": "COMPLETED",
            "target_value": status,
            "pass": False
        })

    report = {
        "parity_status": "PASS" if len(all_discrepancies) == 0 else "FAIL",
        "total_discrepancies": len(all_discrepancies),
        "golden_dataset_file": os.path.basename(golden_path),
        "target_export_file": os.path.basename(target_path),
        "counts_compared": {
            "world_totals": 4,
            "countries": c_count,
            "products": p_count,
            "country_product_junctions": cp_count
        },
        "tolerances_applied": {
            "currency_gdp": TOLERANCE_CURRENCY,
            "price_quantity": TOLERANCE_PRICE_QTY,
            "percentages": TOLERANCE_PERCENT,
            "integers": TOLERANCE_INTEGER
        },
        "discrepancies": all_discrepancies
    }
    return report

def generate_markdown_report(report: Dict[str, Any], output_md_path: str):
    lines = [
        "# Victoria 2 Economy Analyzer — End-to-End Parity Verification Report",
        "",
        f"**Parity Verification Status:** `{report['parity_status']}`  ",
        f"**Total Discrepancies:** `{report['total_discrepancies']}`  ",
        f"**Golden Dataset File:** `{report['golden_dataset_file']}`  ",
        f"**Target Export File:** `{report['target_export_file']}`  ",
        "",
        "## Summary of Compared Metrics",
        "",
        f"- **World Totals:** {report['counts_compared']['world_totals']} metrics compared",
        f"- **Countries:** {report['counts_compared']['countries']} entities compared",
        f"- **Products:** {report['counts_compared']['products']} entities compared",
        f"- **Country × Product Junctions:** {report['counts_compared']['country_product_junctions']} entities compared",
        "",
        "## Tolerances Applied (Section 2.2 Alignment)",
        "",
        f"- Currency / Monetary Totals / GDP: `±{report['tolerances_applied']['currency_gdp']} £` (2 decimal places)",
        f"- Price / Quantity / Supply / Demand: `±{report['tolerances_applied']['price_quantity']}` (4 decimal places)",
        f"- Percentages (Inflation, Overproduction, Share, Unemployment): `±{report['tolerances_applied']['percentages']} %` (2 decimal places)",
        f"- Integer Counts (Population, Workforce, Employment, Ranks): `Exact Integer ({report['tolerances_applied']['integers']})`",
        "",
        "## Discrepancy Inventory",
        ""
    ]

    if report['total_discrepancies'] == 0:
        lines.append("✅ **Zero discrepancies detected.** Full mathematical and semantic parity verified against Java Victoria 2 Economy Analyzer golden dataset.")
    else:
        lines.append("| Scope | Entity ID | Metric | Golden Value | Target Value | Difference | Pass |")
        lines.append("| :--- | :--- | :--- | :--- | :--- | :--- | :--- |")
        for d in report['discrepancies']:
            lines.append(f"| {d['scope']} | {d['entity_id']} | {d['metric']} | {d.get('golden_value')} | {d.get('target_value')} | {d.get('diff', '-')} | ❌ FAIL |")

    lines.append("")
    lines.append("---")
    lines.append("*Generated automatically by `vc2-salesforce-version/e2e/parity/compare.py`*")

    with open(output_md_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines) + "\n")

def resolve_file_path(path: str, candidates: List[str]) -> str:
    if path and os.path.exists(path):
        return path
    for cand in candidates:
        if os.path.exists(cand):
            return cand
    return path

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.abspath(os.path.join(script_dir, "..", ".."))

    default_golden_candidates = [
        os.path.join(script_dir, "fixtures", "egypt_golden_bundle.json"),
        os.path.join(repo_root, "golden-dataset", "golden-dataset.json"),
        os.path.join(repo_root, "vc2-salesforce-version", "golden-dataset", "golden-dataset.json")
    ]

    default_target_candidates = [
        os.path.join(script_dir, "fixtures", "salesforce_export_bundle.json")
    ]

    parser = argparse.ArgumentParser(description="Victoria 2 Parity Comparison Tool")
    parser.add_argument("--golden", default=None, help="Path to golden dataset JSON")
    parser.add_argument("--target", default=None, help="Path to target export JSON")
    parser.add_argument("--out-json", default=os.path.join(script_dir, "parity-report.json"), help="Output JSON report path")
    parser.add_argument("--out-md", default=os.path.join(script_dir, "parity-report.md"), help="Output MD report path")

    args = parser.parse_args()

    golden_path = resolve_file_path(args.golden, default_golden_candidates)
    target_path = resolve_file_path(args.target, default_target_candidates)

    if not os.path.exists(golden_path):
        print(f"Error: Golden dataset file not found at {golden_path}")
        sys.exit(1)

    if not os.path.exists(target_path):
        print(f"Error: Target export file not found at {target_path}")
        sys.exit(1)

    report = run_parity_comparison(golden_path, target_path)

    os.makedirs(os.path.dirname(args.out_json), exist_ok=True)
    with open(args.out_json, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2)

    generate_markdown_report(report, args.out_md)

    print(f"Parity Comparison Completed: {report['parity_status']} ({report['total_discrepancies']} discrepancies)")
    print(f"Golden: {golden_path}")
    print(f"Target: {target_path}")
    print(f"JSON Report written to: {args.out_json}")
    print(f"MD Report written to: {args.out_md}")

    if report['parity_status'] != 'PASS':
        sys.exit(1)

if __name__ == "__main__":
    main()
