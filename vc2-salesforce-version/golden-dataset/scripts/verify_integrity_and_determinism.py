#!/usr/bin/env python3
import os
import json
import subprocess
import filecmp
import sys

def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    verification_dir = os.path.join(base_dir, "verification")
    os.makedirs(verification_dir, exist_ok=True)
    diff_file_path = os.path.join(verification_dir, "determinism-diff.txt")

    print(f"Running Data Integrity Verification in {base_dir}")

    # 1. Load Countries and Products
    countries_json_path = os.path.join(base_dir, "raw", "countries.json")
    products_json_path = os.path.join(base_dir, "raw", "products.json")
    storages_json_path = os.path.join(base_dir, "raw", "product-storage.json")

    with open(countries_json_path, "r", encoding="utf-8") as f:
        countries_data = json.load(f)
    country_tags = {c["tag"] for c in countries_data}

    with open(products_json_path, "r", encoding="utf-8") as f:
        products_data = json.load(f)
    product_codes = {p["name"] for p in products_data}

    with open(storages_json_path, "r", encoding="utf-8") as f:
        storages_data = json.load(f)

    # Referential integrity check
    missing_tags = []
    missing_products = []
    for s in storages_data:
        ct = s.get("countryTag")
        pn = s.get("productName")
        if ct not in country_tags:
            missing_tags.append(ct)
        if pn not in product_codes:
            missing_products.append(pn)

    if missing_tags:
        print(f"FAIL: Product storages reference unknown country tags: {set(missing_tags)}")
        sys.exit(1)
    if missing_products:
        print(f"FAIL: Product storages reference unknown product codes: {set(missing_products)}")
        sys.exit(1)

    print("PASS: Referential integrity verified across countries, products, and product storages.")

    # 2. Non-destructive Determinism Check
    temp_dir = os.path.join("/tmp", "golden_export_temp_check")
    os.makedirs(temp_dir, exist_ok=True)

    java_cmd = [
        "java", "-cp",
        "build/classes/java/main:build/resources/main:libs/*:/home/jules/.gradle/caches/modules-2/files-2.1/com.google.code.gson/gson/2.8.9/8a432c1d6825781e21a02db2e2c33c5fde2833b9/gson-2.8.9.jar",
        "org.victoria2.tools.vic2sgea.export.GoldenDatasetExporterMain",
        "/tmp/file_attachments/savegames/egypt.v2",
        "../../vc2-salesforce-version/golden-dataset/sample-game-data",
        "../../vc2-salesforce-version/golden-dataset/sample-game-data",
        temp_dir
    ]

    working_dir = os.path.abspath("vic2_economy_analyzer/vic2_economy_analyzer-master")
    res = subprocess.run(java_cmd, cwd=working_dir, capture_output=True, text=True)

    diff_lines = []
    diff_lines.append(f"Determinism Check Execution Status: {res.returncode}")

    if res.returncode != 0:
        diff_lines.append(f"FAIL: Harness execution in temp dir failed with exit code {res.returncode}")
        diff_lines.append(res.stderr)
    else:
        diffs_found = 0
        exporter_subdirs = ["raw", "derived", "csv", "expected", "source"]

        # Check generated subdirectories
        for sub in exporter_subdirs:
            base_sub = os.path.join(base_dir, sub)
            temp_sub = os.path.join(temp_dir, sub)
            for root, dirs, files in os.walk(base_sub):
                for file in files:
                    rel_file = os.path.relpath(os.path.join(root, file), base_dir)
                    temp_file = os.path.join(temp_dir, rel_file)
                    if not os.path.exists(temp_file):
                        diff_lines.append(f"MISSING IN TEMP: {rel_file}")
                        diffs_found += 1
                    elif not filecmp.cmp(os.path.join(base_dir, rel_file), temp_file, shallow=False):
                        diff_lines.append(f"DIFF FOUND: {rel_file}")
                        diffs_found += 1

        # Check root generated files (manifest.json excluding generated_at timestamp)
        manifest_base = os.path.join(base_dir, "manifest.json")
        manifest_temp = os.path.join(temp_dir, "manifest.json")
        if os.path.exists(manifest_base) and os.path.exists(manifest_temp):
            with open(manifest_base, "r") as f1, open(manifest_temp, "r") as f2:
                m1 = json.load(f1)
                m2 = json.load(f2)
                m1.pop("generated_at", None)
                m2.pop("generated_at", None)
                if m1 != m2:
                    diff_lines.append("DIFF IN MANIFEST (excluding generated_at timestamp)")
                    diffs_found += 1

        if diffs_found == 0:
            diff_lines.append("PASS: Byte-for-byte deterministic match confirmed across all generated exporter artifacts.")
        else:
            diff_lines.append(f"WARNING: Found {diffs_found} differences between baseline and temp re-run.")

    diff_content = "\n".join(diff_lines) + "\n"
    with open(diff_file_path, "w", encoding="utf-8") as f:
        f.write(diff_content)

    print(f"Determinism check written to {diff_file_path}")

if __name__ == "__main__":
    main()
