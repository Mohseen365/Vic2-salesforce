"""
Victoria 2 Economy Analyzer — Parity Harness Test Suite (Phase 9)
Tests compare.py and scope comparators against fixtures and edge cases.
"""

import unittest
import os
import json
import tempfile
import sys

# Ensure parity package path is importable
script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)

from compare import run_parity_comparison, sanitize_value, is_close
from scopes.states import compare_states
from scopes.factories import compare_factories
from scopes.artisans import compare_artisans

class TestParityHarness(unittest.TestCase):

    def setUp(self):
        self.fixtures_dir = os.path.join(script_dir, "fixtures")
        self.golden_bundle = os.path.join(self.fixtures_dir, "egypt_golden_bundle.json")
        self.target_bundle = os.path.join(self.fixtures_dir, "salesforce_export_bundle.json")

    def test_default_bundle_parity_passes(self):
        report = run_parity_comparison(self.golden_bundle, self.target_bundle)
        self.assertEqual(report['parity_status'], 'PASS')
        self.assertEqual(report['total_discrepancies'], 0)

    def test_sanitize_value_edge_cases(self):
        self.assertEqual(sanitize_value(None), 0.0)
        self.assertEqual(sanitize_value(float('nan')), 0.0)
        self.assertEqual(sanitize_value(float('inf')), 0.0)
        self.assertEqual(sanitize_value(float('-inf')), 0.0)
        self.assertEqual(sanitize_value("$1,234.56"), 1234.56)
        self.assertEqual(sanitize_value("£50.00"), 50.00)

    def test_is_close_tolerance(self):
        self.assertTrue(is_close(10.000, 10.009, 0.01))
        self.assertFalse(is_close(10.000, 10.020, 0.01))

    def test_states_comparator(self):
        golden_states = [{
            "Rank": "1", "Name": "state_1", "Country": "ENG", "Population": "1000",
            "GDP": "$100.00", "GDP_PerCapita": "$0.10", "RGO_Income": "$10.00",
            "PGDP": "$50.00", "AGDP": "$20.00", "FGDP": "$30.00",
            "Employees": "500", "Revenue": "$200.00", "Profit": "$50.00"
        }]
        target_states = [{
            "Rank": "1", "Name": "state_1", "Country": "ENG", "Population": "1000",
            "GDP": "100.00", "GDP_PerCapita": "0.10", "RGO_Income": "10.00",
            "PGDP": "50.00", "AGDP": "20.00", "FGDP": "30.00",
            "Employees": "500", "Revenue": "200.00", "Profit": "50.00"
        }]
        discrepancies, count = compare_states(golden_states, target_states)
        self.assertEqual(count, 1)
        self.assertEqual(len(discrepancies), 0)

    def test_factories_comparator(self):
        golden_factories = [{
            "Rank": "1", "State": "294", "Tag": "ENG", "Country": "ENG",
            "Building": "cement_factory", "Level": "10", "Employees": "99490",
            "Produces": "37.3734", "Leftover": "14.9845", "Money": "$10000.00",
            "Revenue": "$547.16", "Input Costs": "$376.35", "Pops_paychecks": "$3.09",
            "Profit": "$167.72", "GDP": "62346.35", "Productivity": "0.6266", "AvgWage": "0.00003"
        }]
        target_factories = [{
            "Rank": "1", "State": "294", "Tag": "ENG", "Country": "ENG",
            "Building": "cement_factory", "Level": "10", "Employees": "99490",
            "Produces": "37.3734", "Leftover": "14.9845", "Money": "10000.00",
            "Revenue": "547.16", "Input Costs": "376.35", "Pops_paychecks": "3.09",
            "Profit": "167.72", "GDP": "62346.35", "Productivity": "0.6266", "AvgWage": "0.00003"
        }]
        discrepancies, count = compare_factories(golden_factories, target_factories)
        self.assertEqual(count, 1)
        self.assertEqual(len(discrepancies), 0)

    def test_artisans_comparator(self):
        golden_artisans = [{
            "ID": "1", "Provid": "1", "Name": "Sitka", "Country": "USA", "State": "blank",
            "artisan_type": "furniture", "last_spending": "1.6034", "production_income": "2.3127",
            "AGDP": "0.7092", "Production": "0.4534"
        }]
        target_artisans = [{
            "ID": "1", "Provid": "1", "Name": "Sitka", "Country": "USA", "State": "blank",
            "artisan_type": "furniture", "last_spending": "1.6034", "production_income": "2.3127",
            "AGDP": "0.7092", "Production": "0.4534"
        }]
        discrepancies, count = compare_artisans(golden_artisans, target_artisans)
        self.assertEqual(count, 1)
        self.assertEqual(len(discrepancies), 0)

if __name__ == "__main__":
    unittest.main()
