"""
Victoria 2 Economy Analyzer — Artisan Scope Comparator (Phase 9)
Enforces tolerance policy and field comparisons for Artisan scope.
"""

from typing import Dict, List, Tuple, Any

TOLERANCE_CURRENCY = 0.01      # £0.01
TOLERANCE_PRICE_QTY = 0.0001   # 0.0001

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

def compare_artisans(golden_artisans: List[Dict], target_artisans: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []

    def get_artisan_key(a: Dict) -> str:
        key = a.get('uniqueSnapshotKey', a.get('Unique_Snapshot_Key__c'))
        if key:
            return str(key).strip()
        prov_id = str(a.get('externalProvinceId', a.get('Provid', a.get('ID', '')))).strip()
        artisan_type = str(a.get('artisanType', a.get('artisan_type', ''))).strip()
        country = str(a.get('countryTag', a.get('Country', ''))).strip()
        return f"{country}:{prov_id}:{artisan_type}"

    golden_map = {get_artisan_key(a): a for a in golden_artisans}
    target_map = {get_artisan_key(a): a for a in target_artisans}

    compared_count = 0
    for key, gold in golden_map.items():
        if key not in target_map:
            discrepancies.append({
                "scope": "Artisan",
                "entity_id": key,
                "metric": "Missing Artisan",
                "golden_value": key,
                "target_value": "MISSING",
                "pass": False
            })
            continue

        targ = target_map[key]
        compared_count += 1

        artisan_checks = [
            ("uniqueSnapshotKey", get_artisan_key(gold), get_artisan_key(targ), "string"),
            ("externalProvinceId", str(gold.get('externalProvinceId', gold.get('Provid', gold.get('ID', '')))), str(targ.get('externalProvinceId', targ.get('External_Province_Id__c', targ.get('Provid', targ.get('ID', ''))))), "string"),
            ("countryTag", str(gold.get('countryTag', gold.get('Country', ''))), str(targ.get('countryTag', targ.get('Country_Tag__c', targ.get('Country', '')))), "string"),
            ("stateCode", str(gold.get('stateCode', gold.get('State', ''))), str(targ.get('stateCode', targ.get('State_Code__c', targ.get('State', '')))), "string"),
            ("artisanType", str(gold.get('artisanType', gold.get('artisan_type', ''))), str(targ.get('artisanType', targ.get('Artisan_Type__c', targ.get('artisan_type', '')))), "string"),
            ("spending", gold.get('spending', gold.get('last_spending', 0.0)), targ.get('spending', targ.get('Spending__c', targ.get('last_spending', 0.0))), TOLERANCE_CURRENCY),
            ("income", gold.get('income', gold.get('production_income', 0.0)), targ.get('income', targ.get('Income__c', targ.get('production_income', 0.0))), TOLERANCE_CURRENCY),
            ("agdp", gold.get('agdp', gold.get('AGDP', 0.0)), targ.get('agdp', targ.get('AGDP__c', targ.get('AGDP', 0.0))), TOLERANCE_CURRENCY),
            ("productionQuantity", gold.get('productionQuantity', gold.get('Production', 0.0)), targ.get('productionQuantity', targ.get('Production_Quantity__c', targ.get('Production', 0.0))), TOLERANCE_PRICE_QTY)
        ]

        for metric, g_val, t_val, check_type in artisan_checks:
            if check_type == "string":
                if str(g_val).strip() != str(t_val).strip():
                    discrepancies.append({
                        "scope": "Artisan",
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
                        "scope": "Artisan",
                        "entity_id": key,
                        "metric": metric,
                        "golden_value": round(g_san, 4),
                        "target_value": round(t_san, 4),
                        "diff": round(abs(g_san - t_san), 4),
                        "tolerance": tol,
                        "pass": False
                    })

    return discrepancies, compared_count
