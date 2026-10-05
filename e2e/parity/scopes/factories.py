"""
Victoria 2 Economy Analyzer — Factory Scope Comparator (Phase 9)
Enforces tolerance policy and field comparisons for Factory scope.
"""

from typing import Dict, List, Tuple, Any

TOLERANCE_CURRENCY = 0.01      # £0.01
TOLERANCE_PRICE_QTY = 0.0001   # 0.0001
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

def compare_factories(golden_factories: List[Dict], target_factories: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []

    def get_factory_key(f: Dict) -> str:
        key = f.get('uniqueSnapshotKey', f.get('Unique_Snapshot_Key__c'))
        if key:
            return str(key).strip()
        country = str(f.get('countryTag', f.get('Tag', f.get('Country', '')))).strip()
        state = str(f.get('stateCode', f.get('State', ''))).strip()
        building = str(f.get('buildingType', f.get('Building', ''))).strip()
        idx = str(f.get('occurrenceIndex', f.get('Rank', '1'))).strip()
        return f"{country}:{state}:{building}:{idx}"

    golden_map = {get_factory_key(f): f for f in golden_factories}
    target_map = {get_factory_key(f): f for f in target_factories}

    # Computed profit rank
    sorted_golden = sorted(golden_factories, key=lambda x: (-sanitize_value(x.get('profit', x.get('Profit', 0.0))), get_factory_key(x)))
    for idx, f in enumerate(sorted_golden, 1):
        f['_computed_profit_rank'] = idx

    sorted_target = sorted(target_factories, key=lambda x: (-sanitize_value(x.get('profit', x.get('Profit__c', x.get('Profit', 0.0)))), get_factory_key(x)))
    for idx, f in enumerate(sorted_target, 1):
        f['_computed_profit_rank'] = idx

    compared_count = 0
    for key, gold in golden_map.items():
        if key not in target_map:
            discrepancies.append({
                "scope": "Factory",
                "entity_id": key,
                "metric": "Missing Factory",
                "golden_value": key,
                "target_value": "MISSING",
                "pass": False
            })
            continue

        targ = target_map[key]
        compared_count += 1

        factory_checks = [
            ("uniqueSnapshotKey", get_factory_key(gold), get_factory_key(targ), "string"),
            ("stateCode", str(gold.get('stateCode', gold.get('State', ''))), str(targ.get('stateCode', targ.get('State_Code__c', targ.get('State', '')))), "string"),
            ("countryTag", str(gold.get('countryTag', gold.get('Tag', gold.get('Country', '')))), str(targ.get('countryTag', targ.get('Country_Tag__c', targ.get('Tag', targ.get('Country', ''))))), "string"),
            ("buildingType", str(gold.get('buildingType', gold.get('Building', ''))), str(targ.get('buildingType', targ.get('Building_Type__c', targ.get('Building', '')))), "string"),
            ("occurrenceIndex", gold.get('occurrenceIndex', gold.get('Occurrence_Index__c', 1)), targ.get('occurrenceIndex', targ.get('Occurrence_Index__c', 1)), TOLERANCE_INTEGER),
            ("level", gold.get('level', gold.get('Level', 0)), targ.get('level', targ.get('Level__c', targ.get('Level', 0))), TOLERANCE_INTEGER),
            ("employees", gold.get('employees', gold.get('Employees', 0)), targ.get('employees', targ.get('Employees__c', targ.get('Employees', 0))), TOLERANCE_INTEGER),
            ("outputQuantity", gold.get('outputQuantity', gold.get('Produces', 0.0)), targ.get('outputQuantity', targ.get('Output_Quantity__c', targ.get('Produces', 0.0))), TOLERANCE_PRICE_QTY),
            ("unsoldQuantity", gold.get('unsoldQuantity', gold.get('Leftover', 0.0)), targ.get('unsoldQuantity', targ.get('Unsold_Quantity__c', targ.get('Leftover', 0.0))), TOLERANCE_PRICE_QTY),
            ("capitalReserves", gold.get('capitalReserves', gold.get('Money', 0.0)), targ.get('capitalReserves', targ.get('Capital_Reserves__c', targ.get('Money', 0.0))), TOLERANCE_CURRENCY),
            ("revenue", gold.get('revenue', gold.get('Revenue', 0.0)), targ.get('revenue', targ.get('Revenue__c', targ.get('Revenue', 0.0))), TOLERANCE_CURRENCY),
            ("inputCost", gold.get('inputCost', gold.get('Input Costs', 0.0)), targ.get('inputCost', targ.get('Input_Cost__c', targ.get('Input Costs', 0.0))), TOLERANCE_CURRENCY),
            ("wagesPaid", gold.get('wagesPaid', gold.get('Pops_paychecks', 0.0)), targ.get('wagesPaid', targ.get('Wages_Paid__c', targ.get('Pops_paychecks', 0.0))), TOLERANCE_CURRENCY),
            ("profit", gold.get('profit', gold.get('Profit', 0.0)), targ.get('profit', targ.get('Profit__c', targ.get('Profit', 0.0))), TOLERANCE_CURRENCY),
            ("factoryGdp", gold.get('factoryGdp', gold.get('GDP', 0.0)), targ.get('factoryGdp', targ.get('Factory_GDP__c', targ.get('GDP', 0.0))), TOLERANCE_CURRENCY),
            ("productivity", gold.get('productivity', gold.get('Productivity', 0.0)), targ.get('productivity', targ.get('Productivity__c', targ.get('Productivity', 0.0))), TOLERANCE_PRICE_QTY),
            ("averageWage", gold.get('averageWage', gold.get('AvgWage', 0.0)), targ.get('averageWage', targ.get('Average_Wage__c', targ.get('AvgWage', 0.0))), TOLERANCE_PRICE_QTY),
            ("profitRank", gold.get('_computed_profit_rank', gold.get('profitRank', gold.get('Rank', 0))), targ.get('_computed_profit_rank', targ.get('profitRank', targ.get('Profit_Rank__c', targ.get('Rank', 0)))), TOLERANCE_INTEGER)
        ]

        for metric, g_val, t_val, check_type in factory_checks:
            if check_type == "string":
                if str(g_val).strip() != str(t_val).strip():
                    discrepancies.append({
                        "scope": "Factory",
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
                        "scope": "Factory",
                        "entity_id": key,
                        "metric": metric,
                        "golden_value": round(g_san, 4),
                        "target_value": round(t_san, 4),
                        "diff": round(abs(g_san - t_san), 4),
                        "tolerance": tol,
                        "pass": False
                    })

    return discrepancies, compared_count
