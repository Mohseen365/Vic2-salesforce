#!/usr/bin/env python3
import os
import json
import hashlib
import sys

def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    print(f"Validating Golden Dataset in: {base_dir}")

    manifest_path = os.path.join(base_dir, "manifest.json")
    if not os.path.exists(manifest_path):
        print("FAIL: manifest.json does not exist")
        sys.exit(1)

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    source_path = manifest.get("source_path")
    if not source_path or not os.path.exists(source_path):
        print(f"FAIL: Source save file not found at {source_path}")
        sys.exit(1)

    # Verify SHA-256
    sha256_hash = hashlib.sha256()
    with open(source_path, "rb") as f:
        for byte_block in iter(lambda: f.read(65536), b""):
            sha256_hash.update(byte_block)

    calc_sha256 = sha256_hash.hexdigest()
    if calc_sha256 != manifest.get("source_sha256"):
        print(f"FAIL: SHA-256 mismatch. Calculated: {calc_sha256}, Manifest: {manifest.get('source_sha256')}")
        sys.exit(1)

    print(f"PASS: Source save file verified ({manifest.get('source_file')}, SHA-256: {calc_sha256})")

    # Verify required JSON files exist and are non-empty
    required_json_files = [
        "raw/save-metadata.json",
        "raw/countries.json",
        "raw/provinces.json",
        "raw/products.json",
        "raw/product-storage.json",
        "raw/economy-subjects.json",
        "derived/country-calculations.json",
        "derived/product-calculations.json",
        "derived/product-storage-calculations.json",
        "derived/report-calculations.json",
        "expected/apex-golden-results.json"
    ]

    for rel_path in required_json_files:
        full_path = os.path.join(base_dir, rel_path)
        if not os.path.exists(full_path):
            print(f"FAIL: Missing required file {rel_path}")
            sys.exit(1)

        with open(full_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        content_str = json.dumps(data)
        if "TODO" in content_str or "TBD" in content_str or "placeholder" in content_str.lower():
            print(f"FAIL: Found placeholder text in {rel_path}")
            sys.exit(1)

    print("PASS: All required JSON files present, valid, and placeholder-free.")

    # Verify CSV files
    required_csv_files = [
        "csv/countries.csv",
        "csv/provinces.csv",
        "csv/products.csv",
        "csv/product-storage.csv",
        "csv/calculations.csv"
    ]

    for rel_path in required_csv_files:
        full_path = os.path.join(base_dir, rel_path)
        if not os.path.exists(full_path):
            print(f"FAIL: Missing required CSV file {rel_path}")
            sys.exit(1)

    print("PASS: All required CSV files present.")
    print("ALL GOLDEN DATASET VALIDATIONS PASSED CLEANLY!")

if __name__ == "__main__":
    main()
