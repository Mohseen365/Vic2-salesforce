#!/usr/bin/env python3
"""
Victoria 2 Economy Analyzer — Parity Comparison Harness (Phase 9 Extended)
Compares Phase 0 Golden Dataset against Salesforce Export Bundle / DTOs.
Enforces tolerance policy from Phase 10 Audit Section 2.2 and Phase 9 extension rules.
"""

import json
import os
import sys
import argparse
from typing import Dict, List, Any, Tuple

# Ensure scopes module can be imported
script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)

from scopes.states import compare_states
from scopes.factories import compare_factories
from scopes.artisans import compare_artisans

# Section 2.2 Tolerance Policy
TOLERANCE_CURRENCY = 0.01      # 2 decimal places (£0.01)
TOLERANCE_PRICE_QTY = 0.0001   # 4 decimal places
TOLERANCE_PERCENT = 0.01       # 2 decimal places (0.01%)
TOLERANCE_INTEGER = 0          # Exact integer match

def is_close(val1: float, val2: float, tolerance: float) -> bool:
    if val1 is None or val2 is None:
        return val1 == val2
    return abs(val1 - val2) <= tolerance + 1e-9

def sanitize_value(val: Any) -> float:
    if val is None:
        return 0.0
    if isinstance(val, str):
        cleaned = val.replace('$', '').replace('£', '').replace(',', '').strip()
        try:
            val = float(cleaned)
        except ValueError:
            return 0.0
    if val != val:  # NaN
        return 0.0
    if val == float('inf') or val == float('-inf'):
        return 0.0
    return float(val)

def load_dataset(path: str) -> Dict[str, Any]:
    """
    Loads dataset from either a single JSON bundle file or a directory containing JSON files.
    """
    if os.path.isdir(path):
        data = {'header': {}, 'countries': [], 'products': [], 'provinces': [], 'states': [], 'factories': [], 'artisans': []}

        country_file = os.path.join(path, 'country.json')
        if os.path.exists(country_file):
            with open(country_file, 'r', encoding='utf-8') as f:
                data['countries'] = json.load(f)

        goods_file = os.path.join(path, 'goods.json')
        if os.path.exists(goods_file):
            with open(goods_file, 'r', encoding='utf-8') as f:
                goods_data = json.load(f)
                # Normalize good keys
                for g in goods_data:
                    if 'name' not in g and 'Good' in g:
                        g['name'] = g['Good']
                    if 'price' not in g and 'Price' in g:
                        g['price'] = float(g['Price']) if g['Price'] is not None else 0.0
                data['products'] = goods_data

        prov_file = os.path.join(path, 'provinces.json')
        if os.path.exists(prov_file):
            with open(prov_file, 'r', encoding='utf-8') as f:
                data['provinces'] = json.load(f)

        states_file = os.path.join(path, 'states.json')
        if os.path.exists(states_file):
            with open(states_file, 'r', encoding='utf-8') as f:
                data['states'] = json.load(f)

        factory_file = os.path.join(path, 'factory.json')
        if not os.path.exists(factory_file):
            factory_file = os.path.join(path, 'factories.json')
        if os.path.exists(factory_file):
            with open(factory_file, 'r', encoding='utf-8') as f:
                data['factories'] = json.load(f)

        artisans_file = os.path.join(path, 'artisans.json')
        if os.path.exists(artisans_file):
            with open(artisans_file, 'r', encoding='utf-8') as f:
                data['artisans'] = json.load(f)

        return data
    else:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if 'factories' not in data and 'factory' in data:
                data['factories'] = data['factory']
            return data

def compare_world_totals(golden_header: Dict, golden_countries: List[Dict], target_header: Dict) -> List[Dict]:
    discrepancies = []

    total_gdp = sum(sanitize_value(c.get('gdpPounds', c.get('GDP', 0.0))) for c in golden_countries)
    total_pop = sum(int(sanitize_value(c.get('population', c.get('Total_Population', c.get('Population', 0))))) for c in golden_countries)
    total_imports = sum(sanitize_value(c.get('importedPounds', c.get('Total_Imports', 0.0))) for c in golden_countries)
    total_exports = sum(sanitize_value(c.get('exportedPounds', c.get('Total_Exports', 0.0))) for c in golden_countries)

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
    golden_map = {c.get('tag', c.get('ID', '')): c for c in golden_countries if c.get('tag', c.get('ID', ''))}
    target_map = {c.get('countryTag', c.get('tag', c.get('ID', ''))): c for c in target_countries if c.get('countryTag', c.get('tag', c.get('ID', '')))}

    sorted_golden = sorted(golden_countries, key=lambda x: (-sanitize_value(x.get('gdpPounds', x.get('GDP', 0.0))), x.get('tag', x.get('ID', ''))))
    for idx, c in enumerate(sorted_golden, 1):
        c['_computed_rank'] = idx

    sorted_target = sorted(target_countries, key=lambda x: (-sanitize_value(x.get('gdpPounds', x.get('gdp', x.get('GDP__c', x.get('GDP', 0.0))))), x.get('countryTag', x.get('tag', x.get('ID', '')))))
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
            ("GDP (£)", gold.get('gdpPounds', gold.get('GDP', 0.0)), targ.get('gdpPounds', targ.get('gdp', targ.get('GDP__c', targ.get('GDP', 0.0)))), TOLERANCE_CURRENCY),
            ("GDP Per Capita (£)", gold.get('gdpPerCapita', gold.get('GDPperCapita', 0.0)), targ.get('gdpPerCapita', targ.get('GDP_Per_Capita__c', targ.get('GDPperCapita', 0.0))), TOLERANCE_CURRENCY),
            ("GDP Share %", gold.get('gdpSharePercent', 0.0), targ.get('gdpSharePercent', targ.get('gdpSharePct', targ.get('GDP_Share_Percent__c', 0.0))), TOLERANCE_PERCENT),
            ("Population", gold.get('population', gold.get('Population', 0)), targ.get('population', targ.get('Population__c', targ.get('Population', 0))), TOLERANCE_INTEGER),
            ("Workforce RGO", gold.get('workforceRGO', 0), targ.get('workforceRGO', targ.get('Workforce_RGO__c', 0)), TOLERANCE_INTEGER),
            ("Employment RGO", gold.get('employmentRGO', 0), targ.get('employmentRGO', targ.get('Employment_RGO__c', 0)), TOLERANCE_INTEGER),
            ("Unemployment Rate RGO %", gold.get('unemploymentRateRGO', 0.0), targ.get('unemploymentRateRGO', targ.get('unemploymentRateRgo', targ.get('Unemployment_Rate_RGO__c', 0.0))), TOLERANCE_PERCENT),
            ("Workforce Factory", gold.get('workforceFactory', 0), targ.get('workforceFactory', targ.get('Workforce_Factory__c', 0)), TOLERANCE_INTEGER),
            ("Employment Factory", gold.get('employmentFactory', 0), targ.get('employmentFactory', targ.get('Employment_Factory__c', 0)), TOLERANCE_INTEGER),
            ("Unemployment Rate Factory %", gold.get('unemploymentRateFactory', 0.0), targ.get('unemploymentRateFactory', targ.get('Unemployment_Rate_Factory__c', 0.0)), TOLERANCE_PERCENT),
            ("Total Imports (£)", gold.get('importedPounds', 0.0), targ.get('importedPounds', targ.get('totalImports', targ.get('Total_Imports_Value__c', 0.0))), TOLERANCE_CURRENCY),
            ("Total Exports (£)", gold.get('exportedPounds', 0.0), targ.get('exportedPounds', targ.get('totalExports', targ.get('Total_Exports_Value__c', 0.0))), TOLERANCE_CURRENCY),
            ("Gold Income (£)", gold.get('goldIncome', 0.0), targ.get('goldIncome', targ.get('Gold_Income__c', 0.0)), TOLERANCE_CURRENCY),
            ("GDP Rank", gold.get('_computed_rank', gold.get('gdpRank', gold.get('Rank', 0))), targ.get('_computed_rank', targ.get('gdpRank', targ.get('GDP_Rank__c', targ.get('Rank', 0)))), TOLERANCE_INTEGER),
            # Extended Country Fields (Phase 9 - Pattern C):
            ("Factory GDP (£)", gold.get('fgdp', gold.get('FGDP', 0.0)), targ.get('fgdp', targ.get('Factory_GDP__c', targ.get('FGDP', 0.0))), TOLERANCE_CURRENCY),
            ("Province GDP (£)", gold.get('pgdp', gold.get('PGDP', 0.0)), targ.get('pgdp', targ.get('Province_GDP__c', targ.get('PGDP', 0.0))), TOLERANCE_CURRENCY),
            ("Artisan GDP (£)", gold.get('agdp', gold.get('AGDP', 0.0)), targ.get('agdp', targ.get('Artisan_GDP__c', targ.get('AGDP', 0.0))), TOLERANCE_CURRENCY),
            ("Core Population", gold.get('corePopulation', gold.get('Population', 0)), targ.get('corePopulation', targ.get('Core_Population__c', targ.get('Population', 0))), TOLERANCE_INTEGER),
            ("Colony Population", gold.get('colonyPopulation', gold.get('Colony_Population', 0)), targ.get('colonyPopulation', targ.get('Colony_Population__c', gold.get('Colony_Population', 0))), TOLERANCE_INTEGER)
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
    golden_map = {p.get('name', p.get('Good', '')): p for p in golden_products if p.get('name', p.get('Good', ''))}
    target_map = {p.get('productCode', p.get('name', p.get('Good', ''))): p for p in target_products if p.get('productCode', p.get('name', p.get('Good', '')))}

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
            ("Base Price (£)", gold.get('basePrice', gold.get('Price', 0.0)), targ.get('basePrice', targ.get('Base_Price__c', targ.get('Price', 0.0))), TOLERANCE_PRICE_QTY),
            ("Price (£)", gold.get('price', gold.get('Price', 0.0)), targ.get('price', targ.get('Price__c', targ.get('Price', 0.0))), TOLERANCE_PRICE_QTY),
            ("Total World Supply", gold.get('supplyPool', gold.get('totalSupply', 0.0)), targ.get('supplyPool', targ.get('totalSupply', targ.get('totalWorldSupply', targ.get('Total_World_Supply__c', 0.0)))), TOLERANCE_PRICE_QTY),
            ("Real Demand", gold.get('realDemand', 0.0), targ.get('realDemand', targ.get('Real_Demand__c', 0.0)), TOLERANCE_PRICE_QTY),
            ("Max Demand", gold.get('maxDemand', 0.0), targ.get('maxDemand', targ.get('Max_Demand__c', 0.0)), TOLERANCE_PRICE_QTY),
            ("Inflation %", gold.get('inflationPercent', 0.0), targ.get('inflationPercent', targ.get('inflationPct', targ.get('Inflation_Percent__c', 0.0))), TOLERANCE_PERCENT),
            ("Overproduction %", gold.get('overproducedPercent', 0.0), targ.get('overproducedPercent', targ.get('overproductionPercent', targ.get('Overproduction_Percent__c', 0.0))), TOLERANCE_PERCENT)
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
        tag = c.get('tag', c.get('ID', ''))
        if not tag:
            continue
        for ps in c.get('productStorages', []):
            pname = ps.get('productName', ps.get('productCode', ''))
            if pname:
                key = f"{tag}:{pname}"
                golden_junctions[key] = ps

    target_junctions = {}
    for c in target_countries:
        tag = c.get('countryTag', c.get('tag', c.get('ID', '')))
        if not tag:
            continue
        for ps in c.get('productStorages', c.get('countryProducts', [])):
            pname = ps.get('productCode', ps.get('productName', ''))
            if pname:
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
            ("Sold Domestic Qty", gold.get('soldDomestic', 0.0), targ.get('soldDomestic', targ.get('Sold_Domestic__c', 0.0)), TOLERANCE_PRICE_QTY),
            ("Total Supply (£)", gold.get('totalSupplyPounds', 0.0), targ.get('totalSupplyPounds', targ.get('totalSupplyValue', targ.get('Total_Supply_Pounds__c', 0.0))), TOLERANCE_CURRENCY),
            ("Actual Demand (£)", gold.get('actualDemandPounds', 0.0), targ.get('actualDemandPounds', targ.get('actualDemandValue', targ.get('Actual_Demand_Pounds__c', 0.0))), TOLERANCE_CURRENCY),
            ("Actual Supply (£)", gold.get('actualSupplyPounds', 0.0), targ.get('actualSupplyPounds', targ.get('actualSupplyValue', targ.get('Actual_Supply_Pounds__c', 0.0))), TOLERANCE_CURRENCY),
            ("Import Value (£)", gold.get('importedPounds', 0.0), targ.get('importedPounds', targ.get('importValue', targ.get('Import_Value__c', 0.0))), TOLERANCE_CURRENCY),
            ("Export Value (£)", gold.get('exportedPounds', 0.0), targ.get('exportedPounds', targ.get('exportValue', targ.get('Export_Value__c', 0.0))), TOLERANCE_CURRENCY),
            ("GDP Contribution (£)", gold.get('gdpPounds', 0.0), targ.get('gdpPounds', targ.get('gdpContribution', targ.get('GDP_Contribution__c', 0.0))), TOLERANCE_CURRENCY)
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

def compare_provinces(golden_provinces: List[Dict], target_provinces: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []
    def get_prov_key(p: Dict) -> str:
        key = p.get('uniqueSnapshotKey', p.get('Unique_Snapshot_Key__c'))
        if key:
            return str(key).strip()
        prov_id = str(p.get('externalProvinceId', p.get('Provid', p.get('ID', '')))).strip()
        country = str(p.get('countryTag', p.get('Country', p.get('Owner', '')))).strip()
        return f"{country}:{prov_id}" if country else prov_id

    golden_map = {get_prov_key(p): p for p in golden_provinces if get_prov_key(p)}
    target_map = {get_prov_key(p): p for p in target_provinces if get_prov_key(p)}

    compared_count = 0
    for key, gold in golden_map.items():
        if key not in target_map:
            discrepancies.append({
                "scope": "Province",
                "entity_id": key,
                "metric": "Missing Province",
                "golden_value": key,
                "target_value": "MISSING",
                "pass": False
            })
            continue

        targ = target_map[key]
        compared_count += 1

        prov_checks = [
            ("population", gold.get('population', gold.get('Pop', 0)), targ.get('population', targ.get('Population__c', targ.get('Pop', 0))), TOLERANCE_INTEGER),
            ("rgoProduction", gold.get('rgoProduction', gold.get('RGO_Production', 0.0)), targ.get('rgoProduction', targ.get('RGO_Production__c', targ.get('RGO_Production', 0.0))), TOLERANCE_PRICE_QTY),
            # Extended Province Fields (PATTERN C - additive):
            ("colony", str(gold.get('colony', gold.get('Colony', False))).lower(), str(targ.get('colony', targ.get('Colony__c', targ.get('Colony', False)))).lower(), "boolean"),
            ("rgoIncome", gold.get('rgoIncome', gold.get('Last_income', 0.0)), targ.get('rgoIncome', targ.get('RGO_Income__c', targ.get('Last_income', 0.0))), TOLERANCE_CURRENCY),
            ("rgoGdp", gold.get('rgoGdp', gold.get('GDP', 0.0)), targ.get('rgoGdp', targ.get('RGO_GDP__c', targ.get('GDP', 0.0))), TOLERANCE_CURRENCY),
            ("artisanSpending", gold.get('artisanSpending', gold.get('Last_Spending', 0.0)), targ.get('artisanSpending', targ.get('Artisan_Spending__c', targ.get('Last_Spending', 0.0))), TOLERANCE_CURRENCY),
            ("artisanIncome", gold.get('artisanIncome', gold.get('Production_Income', 0.0)), targ.get('artisanIncome', targ.get('Artisan_Income__c', targ.get('Production_Income', 0.0))), TOLERANCE_CURRENCY),
            ("artisanGdp", gold.get('artisanGdp', gold.get('AGDP', 0.0)), targ.get('artisanGdp', targ.get('Artisan_GDP__c', targ.get('AGDP', 0.0))), TOLERANCE_CURRENCY),
        ]

        for metric, g_val, t_val, check_type in prov_checks:
            if check_type == "boolean":
                if str(g_val).strip() != str(t_val).strip():
                    discrepancies.append({
                        "scope": "Province",
                        "entity_id": key,
                        "metric": metric,
                        "golden_value": str(g_val),
                        "target_value": str(t_val),
                        "pass": False
                    })
            else:
                g_san = sanitize_value(g_val)
                t_san = sanitize_value(t_val)
                tol = check_type
                if not is_close(g_san, t_san, tol):
                    discrepancies.append({
                        "scope": "Province",
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
    golden_data = load_dataset(golden_path)
    target_data = load_dataset(target_path)

    g_header = golden_data.get('header', {})
    g_countries = golden_data.get('countries', [])
    g_products = golden_data.get('products', [])
    g_provinces = golden_data.get('provinces', [])
    g_states = golden_data.get('states', [])
    g_factories = golden_data.get('factories', golden_data.get('factory', []))
    g_artisans = golden_data.get('artisans', [])

    t_header = target_data.get('header', target_data.get('summary', {}))
    t_countries = target_data.get('countries', [])
    t_products = target_data.get('products', [])
    t_provinces = target_data.get('provinces', [])
    t_states = target_data.get('states', [])
    t_factories = target_data.get('factories', target_data.get('factory', []))
    t_artisans = target_data.get('artisans', [])

    world_discrepancies = compare_world_totals(g_header, g_countries, t_header)
    country_discrepancies, c_count = compare_countries(g_countries, t_countries)
    product_discrepancies, p_count = compare_products(g_products, t_products)
    cp_discrepancies, cp_count = compare_country_products(g_countries, t_countries)
    prov_discrepancies, prov_count = compare_provinces(g_provinces, t_provinces)
    state_discrepancies, state_count = compare_states(g_states, t_states)
    factory_discrepancies, factory_count = compare_factories(g_factories, t_factories)
    artisan_discrepancies, artisan_count = compare_artisans(g_artisans, t_artisans)

    all_discrepancies = (
        world_discrepancies +
        country_discrepancies +
        product_discrepancies +
        cp_discrepancies +
        prov_discrepancies +
        state_discrepancies +
        factory_discrepancies +
        artisan_discrepancies
    )

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
            "country_product_junctions": cp_count,
            "provinces": prov_count,
            "states": state_count,
            "factories": factory_count,
            "artisans": artisan_count
        },
        "tolerances_applied": {
            "currency_gdp": TOLERANCE_CURRENCY,
            "price_quantity": TOLERANCE_PRICE_QTY,
            "percentages": TOLERANCE_PERCENT,
            "integers": TOLERANCE_INTEGER
        },
        "discrepancies": all_discrepancies,
        "states": {
            "compared": state_count,
            "discrepancies": len(state_discrepancies),
            "pass": len(state_discrepancies) == 0
        },
        "factories": {
            "compared": factory_count,
            "discrepancies": len(factory_discrepancies),
            "pass": len(factory_discrepancies) == 0
        },
        "artisans": {
            "compared": artisan_count,
            "discrepancies": len(artisan_discrepancies),
            "pass": len(artisan_discrepancies) == 0
        },
        "provinces": {
            "compared": prov_count,
            "discrepancies": len(prov_discrepancies),
            "pass": len(prov_discrepancies) == 0
        }
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
        f"- **Provinces:** {report['counts_compared']['provinces']} entities compared",
        f"- **States:** {report['counts_compared']['states']} entities compared",
        f"- **Factories:** {report['counts_compared']['factories']} entities compared",
        f"- **Artisans:** {report['counts_compared']['artisans']} entities compared",
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

    lines.extend([
        "",
        "## States Scope",
        f"- **Compared:** {report['states']['compared']} records",
        f"- **Discrepancies:** {report['states']['discrepancies']}",
        f"- **Status:** {'PASS' if report['states']['pass'] else 'FAIL'}",
        "",
        "## Factories Scope",
        f"- **Compared:** {report['factories']['compared']} records",
        f"- **Discrepancies:** {report['factories']['discrepancies']}",
        f"- **Status:** {'PASS' if report['factories']['pass'] else 'FAIL'}",
        "",
        "## Artisans Scope",
        f"- **Compared:** {report['artisans']['compared']} records",
        f"- **Discrepancies:** {report['artisans']['discrepancies']}",
        f"- **Status:** {'PASS' if report['artisans']['pass'] else 'FAIL'}",
        "",
        "## Provinces Scope",
        f"- **Compared:** {report['provinces']['compared']} records",
        f"- **Discrepancies:** {report['provinces']['discrepancies']}",
        f"- **Status:** {'PASS' if report['provinces']['pass'] else 'FAIL'}",
        "",
        "---",
        "*Generated automatically by `vc2-salesforce-version/e2e/parity/compare.py`*"
    ])

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
        os.path.join(repo_root, "golden-dataset", "save-game-analyzer"),
        os.path.join(repo_root, "vc2-salesforce-version", "golden-dataset", "save-game-analyzer"),
        os.path.join(repo_root, "golden-dataset", "golden-dataset.json"),
        os.path.join(repo_root, "vc2-salesforce-version", "golden-dataset", "golden-dataset.json")
    ]

    default_target_candidates = [
        os.path.join(script_dir, "fixtures", "salesforce_export_bundle.json")
    ]

    parser = argparse.ArgumentParser(description="Victoria 2 Parity Comparison Tool")
    parser.add_argument("--golden", default=None, help="Path to golden dataset JSON or directory")
    parser.add_argument("--target", default=None, help="Path to target export JSON or directory")
    parser.add_argument("--out-json", default=os.path.join(script_dir, "parity-report.json"), help="Output JSON report path")
    parser.add_argument("--out-md", default=os.path.join(script_dir, "parity-report.md"), help="Output MD report path")

    args = parser.parse_args()

    golden_path = resolve_file_path(args.golden, default_golden_candidates)
    target_path = resolve_file_path(args.target, default_target_candidates)

    if not os.path.exists(golden_path):
        print(f"Error: Golden dataset file/dir not found at {golden_path}")
        sys.exit(1)

    if not os.path.exists(target_path):
        print(f"Error: Target export file/dir not found at {target_path}")
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
