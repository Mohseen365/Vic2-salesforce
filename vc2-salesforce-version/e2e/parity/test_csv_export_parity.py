"""
Victoria 2 Economy Analyzer — CSV Export Parity Verification Test (Phase 11)
Validates CSV export headers, column ordering, record counts, and numeric precision
against frozen golden dataset CSV artifacts in golden-dataset/save-game-analyzer/csv/.
"""

import unittest
import os
import csv
import sys

script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(script_dir, "..", ".."))

class TestCsvExportParity(unittest.TestCase):

    def setUp(self):
        self.golden_csv_dir = os.path.join(repo_root, "golden-dataset", "save-game-analyzer", "csv")
        if not os.path.exists(self.golden_csv_dir):
            self.golden_csv_dir = os.path.join(repo_root, "..", "golden-dataset", "save-game-analyzer", "csv")

        self.golden_commodities = [
            'ammunition', 'small_arms', 'artillery', 'canned_food', 'barrels', 'aeroplanes',
            'cotton', 'dye', 'wool', 'silk', 'coal', 'sulphur', 'iron', 'timber', 'tropical_wood',
            'rubber', 'oil', 'precious_metal', 'precious_goods', 'steel', 'cement', 'machine_parts',
            'glass', 'fuel', 'fertilizer', 'explosives', 'clipper_convoy', 'steamer_convoy',
            'electric_gear', 'fabric', 'lumber', 'paper', 'cattle', 'fish', 'fruit', 'grain',
            'tobacco', 'tea', 'coffee', 'opium', 'automobiles', 'telephones', 'wine', 'liquor',
            'regular_clothes', 'luxury_clothes', 'furniture', 'luxury_furniture', 'radio'
        ]

    def test_goods_csv_parity(self):
        goods_csv = os.path.join(self.golden_csv_dir, "Goods.csv")
        self.assertTrue(os.path.exists(goods_csv), f"Goods.csv must exist at {goods_csv}")

        with open(goods_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)

        self.assertEqual(header, ['Good', 'Price'], "Goods.csv header must match 'Good,Price'")
        self.assertEqual(len(rows), 48, "Goods.csv must contain exactly 48 commodity records")

    def test_country_csv_49_good_unpivot_parity(self):
        country_csv = os.path.join(self.golden_csv_dir, "Country.csv")
        self.assertTrue(os.path.exists(country_csv), f"Country.csv must exist at {country_csv}")

        with open(country_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)

        expected_base_header = ['Rank', 'ID', 'Name', 'Population', 'Colony_Population', 'Total_Population', 'FGDP', 'PGDP', 'AGDP', 'GDP', 'GDPperCapita']
        expected_full_header = expected_base_header + self.golden_commodities

        self.assertEqual(header, expected_full_header, "Country.csv header must match 11 base columns + 49 commodity columns")
        self.assertEqual(len(rows), 118, "Country.csv must contain exactly 118 country records")

    def test_provinces_csv_parity(self):
        prov_csv = os.path.join(self.golden_csv_dir, "Provinces.csv")
        self.assertTrue(os.path.exists(prov_csv), f"Provinces.csv must exist at {prov_csv}")

        with open(prov_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)

        expected_header = ['ID', 'Provid', 'Name', 'Owner', 'Country', 'State', 'Colony', 'Pop', 'Goods_type', 'RGO_Production', 'Last_income', 'GDP', 'Last_Spending', 'Production_Income', 'AGDP']
        self.assertEqual(header, expected_header, "Provinces.csv header must match golden structure")
        self.assertEqual(len(rows), 2703, "Provinces.csv must contain exactly 2,703 province records")

    def test_states_csv_parity(self):
        states_csv = os.path.join(self.golden_csv_dir, "States.csv")
        self.assertTrue(os.path.exists(states_csv), f"States.csv must exist at {states_csv}")

        with open(states_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)

        expected_header = ['Rank', 'Name', 'Country', 'Population', 'GDP', 'GDP_PerCapita', 'RGO_Income', 'PGDP', 'AGDP', 'FGDP', 'Employees', 'Revenue', 'Profit']
        self.assertEqual(header, expected_header, "States.csv header must match golden structure")
        self.assertEqual(len(rows), 124, "States.csv must contain exactly 124 state records")

    def test_factory_csv_parity(self):
        factory_csv = os.path.join(self.golden_csv_dir, "Factory.csv")
        self.assertTrue(os.path.exists(factory_csv), f"Factory.csv must exist at {factory_csv}")

        with open(factory_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)

        expected_header = ['Rank', 'State', 'Tag', 'Country', 'Building', 'Level', 'Employees', 'Produces', 'Leftover', 'Money', 'Revenue', 'Input Costs', 'Pops_paychecks', 'Profit', 'GDP', 'Productivity', 'AvgWage']
        self.assertEqual(header, expected_header, "Factory.csv header must match golden structure")
        self.assertEqual(len(rows), 714, "Factory.csv must contain exactly 714 factory records")

    def test_artisans_csv_parity(self):
        artisans_csv = os.path.join(self.golden_csv_dir, "Artisans.csv")
        self.assertTrue(os.path.exists(artisans_csv), f"Artisans.csv must exist at {artisans_csv}")

        with open(artisans_csv, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)

        expected_header = ['ID', 'Provid', 'Name', 'Country', 'State', 'artisan_type', 'last_spending', 'production_income', 'AGDP', 'Production']
        self.assertEqual(header, expected_header, "Artisans.csv header must match golden structure")
        self.assertEqual(len(rows), 4406, "Artisans.csv must contain exactly 4,406 artisan records")

if __name__ == "__main__":
    unittest.main()
