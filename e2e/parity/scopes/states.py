"""
Victoria 2 Economy Analyzer — State Scope Comparator (Phase 9)
Enforces tolerance policy and field comparisons for States scope.
"""

from typing import Dict, List, Tuple, Any

TOLERANCE_CURRENCY = 0.01      # £0.01
TOLERANCE_PERCENT = 0.01       # 0.01%
TOLERANCE_INTEGER = 0          # Exact integer match

def is_close(val1: float, val2: float, tolerance: float) -> bool:
    if val1 is None or val2 is None:
        return val1 == val2
    return abs(val1 - val2) <= tolerance + 1e-9

def sanitize_value(val: Any) -> float:
    if val is None:
        return 0.0
    if isinstance(val, str):
        # Remove currency symbols or commas if present
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

def compare_states(golden_states: List[Dict], target_states: List[Dict]) -> Tuple[List[Dict], int]:
    discrepancies = []

    def get_state_key(s: Dict) -> str:
        # Match by stateCode or Name + Country
        code = str(s.get('stateCode', s.get('State_Code__c', s.get('Name', s.get('stateName', ''))))).strip()
        country = str(s.get('countryTag', s.get('Country_Tag__c', s.get('Country', '')))).strip()
        return f"{country}:{code}" if code else f"{country}:{s.get('Rank', '')}"

    golden_map = {get_state_key(s): s for s in golden_states}
    target_map = {get_state_key(s): s for s in target_states}

    # Deterministic ranking by GDP descending, stateCode ascending
    sorted_golden = sorted(golden_states, key=lambda x: (-sanitize_value(x.get('gdp', x.get('GDP', 0.0))), get_state_key(x)))
    for idx, s in enumerate(sorted_golden, 1):
        s['_computed_rank'] = idx

    sorted_target = sorted(target_states, key=lambda x: (-sanitize_value(x.get('gdp', x.get('GDP__c', x.get('GDP', 0.0)))), get_state_key(x)))
    for idx, s in enumerate(sorted_target, 1):
        s['_computed_rank'] = idx

    compared_count = 0
    for key, gold in golden_map.items():
        if key not in target_map:
            discrepancies.append({
                "scope": "State",
                "entity_id": key,
                "metric": "Missing State",
                "golden_value": key,
                "target_value": "MISSING",
                "pass": False
            })
            continue

        targ = target_map[key]
        compared_count += 1

        state_checks = [
            ("stateCode", str(gold.get('stateCode', gold.get('Name', ''))), str(targ.get('stateCode', targ.get('State_Code__c', targ.get('Name', '')))), "string"),
            ("stateName", str(gold.get('stateName', gold.get('Name', ''))), str(targ.get('stateName', targ.get('Name', ''))), "string"),
            ("countryTag", str(gold.get('countryTag', gold.get('Country', ''))), str(targ.get('countryTag', targ.get('Country_Tag__c', targ.get('Country', '')))), "string"),
            ("population", gold.get('population', gold.get('Population', 0)), targ.get('population', targ.get('Population__c', targ.get('Population', 0))), TOLERANCE_INTEGER),
            ("gdp", gold.get('gdp', gold.get('GDP', 0.0)), targ.get('gdp', targ.get('GDP__c', targ.get('GDP', 0.0))), TOLERANCE_CURRENCY),
            ("gdpPerCapita", gold.get('gdpPerCapita', gold.get('GDP_PerCapita', 0.0)), targ.get('gdpPerCapita', targ.get('GDP_Per_Capita__c', targ.get('GDP_PerCapita', 0.0))), TOLERANCE_CURRENCY),
            ("gdpRank", gold.get('_computed_rank', gold.get('gdpRank', gold.get('Rank', 0))), targ.get('_computed_rank', targ.get('gdpRank', targ.get('GDP_Rank__c', targ.get('Rank', 0)))), TOLERANCE_INTEGER),
            ("rgoIncome", gold.get('rgoIncome', gold.get('RGO_Income', 0.0)), targ.get('rgoIncome', targ.get('RGO_Income__c', targ.get('RGO_Income', 0.0))), TOLERANCE_CURRENCY),
            ("pgdp", gold.get('pgdp', gold.get('PGDP', 0.0)), targ.get('pgdp', targ.get('PGDP__c', targ.get('PGDP', 0.0))), TOLERANCE_CURRENCY),
            ("agdp", gold.get('agdp', gold.get('AGDP', 0.0)), targ.get('agdp', targ.get('AGDP__c', targ.get('AGDP', 0.0))), TOLERANCE_CURRENCY),
            ("fgdp", gold.get('fgdp', gold.get('FGDP', 0.0)), targ.get('fgdp', targ.get('FGDP__c', targ.get('FGDP', 0.0))), TOLERANCE_CURRENCY),
            ("factoryEmployees", gold.get('factoryEmployees', gold.get('Employees', 0)), targ.get('factoryEmployees', targ.get('Factory_Employees__c', targ.get('Employees', 0))), TOLERANCE_INTEGER),
            ("factoryRevenue", gold.get('factoryRevenue', gold.get('Revenue', 0.0)), targ.get('factoryRevenue', targ.get('Factory_Revenue__c', targ.get('Revenue', 0.0))), TOLERANCE_CURRENCY),
            ("factoryProfit", gold.get('factoryProfit', gold.get('Profit', 0.0)), targ.get('factoryProfit', targ.get('Factory_Profit__c', targ.get('Profit', 0.0))), TOLERANCE_CURRENCY)
        ]

        for metric, g_val, t_val, check_type in state_checks:
            if check_type == "string":
                if str(g_val).strip() != str(t_val).strip():
                    discrepancies.append({
                        "scope": "State",
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
                        "scope": "State",
                        "entity_id": key,
                        "metric": metric,
                        "golden_value": round(g_san, 4),
                        "target_value": round(t_san, 4),
                        "diff": round(abs(g_san - t_san), 4),
                        "tolerance": tol,
                        "pass": False
                    })

    return discrepancies, compared_count
