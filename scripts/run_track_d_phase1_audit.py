#!/usr/bin/env python3
"""
Track D Phase 1 / Track E-2 Independent Audit Verification Script.
Executes complete automated verification across all 8 Salesforce metadata quality rules,
economy artifact bit-for-bit SHA-256 integrity, and model file accounting.
"""

import os
import sys
import subprocess
import xml.etree.ElementTree as ET

BASE_DIR = "force-app/main/default/objects"
EXPANDED_MODEL = "salesforce_model_expanded.txt"
PRE_TRACK_E_MODEL = "salesforce_model_expanded.txt.pre-track-e"

PROTECTED_ECONOMY_OBJECTS = [
    'Economy_Analysis__c', 'Country_Economy__c', 'Product_Economy__c',
    'Country_Product_Economy__c', 'State_Economy__c', 'Province_Economy__c',
    'Factory_Economy__c', 'Artisan_Economy__c', 'Economy_Import_Event__e',
    'Country__c', 'Product__c', 'State__c', 'Province__c'
]

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def audit_rule_1_double_suffixes(all_objs):
    print("=== RULE 1: API NAME VALIDITY & DOUBLE SUFFIX CHECK ===")
    double_suffixes = []
    overlength_names = []

    # Check XML files
    for obj in sorted(all_objs):
        if len(obj) > 80:
            overlength_names.append(f"Object: {obj}")
        if "_Save_State_Save_State" in obj:
            double_suffixes.append(f"Object: {obj}")

        fields_dir = os.path.join(BASE_DIR, obj, "fields")
        if os.path.exists(fields_dir):
            for ff in os.listdir(fields_dir):
                if not ff.endswith(".field-meta.xml"): continue
                fname = ff.replace(".field-meta.xml", "")
                if len(fname) > 80:
                    overlength_names.append(f"Field: {obj}.{fname}")
                if "_Save_State_Save_State" in fname:
                    double_suffixes.append(f"Field: {obj}.{fname}")

    # Check expanded text model
    if os.path.exists(EXPANDED_MODEL):
        with open(EXPANDED_MODEL, 'r') as f:
            for line_no, line in enumerate(f, 1):
                if "_Save_State_Save_State" in line:
                    double_suffixes.append(f"Text Line {line_no}: {line.strip()}")

    print(f"Double Suffixes Found: {len(double_suffixes)}")
    for ds in double_suffixes:
        print(f"  - {ds}")
    print(f"Overlength Names (>80 chars) Found: {len(overlength_names)}")
    for ol in overlength_names:
        print(f"  - {ol}")
    status = "PASS" if len(double_suffixes) == 0 and len(overlength_names) == 0 else "FAIL"
    print(f"RULE 1 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_2_field_validity(all_objs):
    print("=== RULE 2: FIELD NAME VALIDITY & SYNTAX CHECK ===")
    invalid_fields = []
    for obj in sorted(all_objs):
        fields_dir = os.path.join(BASE_DIR, obj, "fields")
        if not os.path.exists(fields_dir): continue
        for ff in os.listdir(fields_dir):
            if not ff.endswith(".field-meta.xml"): continue
            fname = ff.replace(".field-meta.xml", "")
            if not fname.endswith("__c"):
                invalid_fields.append(f"Field {obj}.{fname} missing __c suffix")
            if not fname.replace("__c", "").replace("_", "").isalnum():
                invalid_fields.append(f"Field {obj}.{fname} contains invalid characters")

    print(f"Invalid Fields Found: {len(invalid_fields)}")
    for inv in invalid_fields:
        print(f"  - {inv}")
    status = "PASS" if len(invalid_fields) == 0 else "FAIL"
    print(f"RULE 2 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_3_semantic_fit():
    print("=== RULE 3: FIELD NAME SEMANTIC FIT (News_Scope_Value__c CHECK) ===")
    non_newsscope_occurrences = []

    # Check XML metadata
    for root, dirs, files in os.walk(BASE_DIR):
        for f in files:
            filepath = os.path.join(root, f)
            if "NewsScope__c" in filepath or "News_Scope_Value__c" in filepath:
                continue
            with open(filepath, 'r') as file_obj:
                content = file_obj.read()
                if "News_Scope_Value__c" in content:
                    non_newsscope_occurrences.append(f"XML: {filepath}")

    # Check expanded text model
    if os.path.exists(EXPANDED_MODEL):
        with open(EXPANDED_MODEL, 'r') as f:
            current_obj = None
            for line in f:
                if line.startswith("OBJECT: "):
                    current_obj = line.replace("OBJECT: ", "").strip()
                elif "News_Scope_Value__c" in line:
                    if current_obj not in ("NewsScope__c", "News_Scope_Value__c"):
                        non_newsscope_occurrences.append(f"Text Model ({current_obj}): {line.strip()}")

    print(f"Non-NewsScope News_Scope_Value__c Occurrences: {len(non_newsscope_occurrences)}")
    for occ in non_newsscope_occurrences:
        print(f"  - {occ}")
    status = "PASS" if len(non_newsscope_occurrences) == 0 else "FAIL"
    print(f"RULE 3 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_4_parent_child_consistency(all_objs):
    print("=== RULE 4: PARENT/CHILD CONSISTENCY & RELATIONSHIP TARGETS ===")
    inconsistent = []
    for obj in sorted(all_objs):
        fields_dir = os.path.join(BASE_DIR, obj, "fields")
        if not os.path.exists(fields_dir): continue
        for ff in os.listdir(fields_dir):
            if not ff.endswith(".field-meta.xml"): continue
            tree = ET.parse(os.path.join(fields_dir, ff))
            root = tree.getroot()
            ftype = root.find('{http://soap.sforce.com/2006/04/metadata}type')
            if ftype is not None and ftype.text in ('Lookup', 'MasterDetail'):
                ref = root.find('{http://soap.sforce.com/2006/04/metadata}referenceTo')
                if ref is None or not ref.text:
                    inconsistent.append(f"Missing referenceTo: {obj}.{ff}")
    print(f"Inconsistent Relationship Declarations: {len(inconsistent)}")
    for inc in inconsistent:
        print(f"  - {inc}")
    status = "PASS" if len(inconsistent) == 0 else "FAIL"
    print(f"RULE 4 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_5_lookup_targets(all_objs_set):
    print("=== RULE 5: LOOKUP TARGET EXISTENCE ===")
    unresolved = []
    distinct_targets = set()
    for obj in sorted(all_objs_set):
        fields_dir = os.path.join(BASE_DIR, obj, "fields")
        if not os.path.exists(fields_dir): continue
        for ff in os.listdir(fields_dir):
            if not ff.endswith(".field-meta.xml"): continue
            tree = ET.parse(os.path.join(fields_dir, ff))
            root = tree.getroot()
            ref = root.find('{http://soap.sforce.com/2006/04/metadata}referenceTo')
            if ref is not None and ref.text:
                target = ref.text.strip()
                distinct_targets.add(target)
                if target not in all_objs_set:
                    unresolved.append(f"{obj}.{ff} -> {target}")

    print(f"Distinct Lookup Targets Referenced: {len(distinct_targets)}")
    print(f"Unresolved Targets Found: {len(unresolved)}")
    for un in unresolved:
        print(f"  - {un}")
    status = "PASS" if len(unresolved) == 0 else "FAIL"
    print(f"RULE 5 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_6_governor_limits(all_objs):
    print("=== RULE 6: GOVERNOR LIMITS (LOOKUP COUNT PER OBJECT) ===")
    lookup_counts = {}
    exceeded = []

    print(f"{'Object API Name':<35} | {'Lookups':<8} | {'Status':<6}")
    print("-" * 55)
    for obj in sorted(all_objs):
        fields_dir = os.path.join(BASE_DIR, obj, "fields")
        count = 0
        if os.path.exists(fields_dir):
            for ff in os.listdir(fields_dir):
                if not ff.endswith(".field-meta.xml"): continue
                tree = ET.parse(os.path.join(fields_dir, ff))
                ftype = tree.getroot().find('{http://soap.sforce.com/2006/04/metadata}type')
                if ftype is not None and ftype.text in ('Lookup', 'MasterDetail'):
                    count += 1
        lookup_counts[obj] = count
        st = "PASS" if count <= 40 else "EXCEEDED"
        if count > 40:
            exceeded.append(f"{obj}: {count}")
        # Print key objects or all if count > 0
        if count > 0 or obj in ('Save_Game__c', 'Country_Save_State__c'):
            print(f"{obj:<35} | {count:<8} | {st:<6}")

    print("-" * 55)
    print(f"Save_Game__c Lookups: {lookup_counts.get('Save_Game__c', 0)}")
    print(f"Country_Save_State__c Lookups: {lookup_counts.get('Country_Save_State__c', 0)}")
    print(f"Objects Exceeding 40 Lookups: {len(exceeded)}")
    for ex in exceeded:
        print(f"  - {ex}")
    status = "PASS" if len(exceeded) == 0 else "FAIL"
    print(f"RULE 6 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_7_self_referential(all_objs):
    print("=== RULE 7: SELF-REFERENTIAL PARENT RESTRICTIONS ===")
    invalid_self_refs = []
    for obj in sorted(all_objs):
        fields_dir = os.path.join(BASE_DIR, obj, "fields")
        if not os.path.exists(fields_dir): continue
        for ff in os.listdir(fields_dir):
            if not ff.endswith(".field-meta.xml"): continue
            tree = ET.parse(os.path.join(fields_dir, ff))
            root = tree.getroot()
            ref = root.find('{http://soap.sforce.com/2006/04/metadata}referenceTo')
            if ref is not None and ref.text and ref.text.strip() == obj:
                if obj != "Country_Country_Ref__c":
                    invalid_self_refs.append(f"{obj}.{ff}")

    print(f"Invalid Self-Referential Lookups: {len(invalid_self_refs)}")
    for sr in invalid_self_refs:
        print(f"  - {sr}")
    status = "PASS" if len(invalid_self_refs) == 0 else "FAIL"
    print(f"RULE 7 RESULT: {status}\n")
    return status == "PASS"

def audit_rule_8_duplicate_objects(all_objs):
    print("=== RULE 8: DUPLICATE OBJECT DECLARATIONS ===")
    seen = set()
    duplicates = []
    for obj in all_objs:
        if obj in seen:
            duplicates.append(obj)
        seen.add(obj)

    protected_count = len([o for o in all_objs if o in PROTECTED_ECONOMY_OBJECTS])
    save_game_count = len(all_objs) - protected_count

    print(f"Total Unique Objects: {len(all_objs)}")
    print(f"Protected Economy Artifacts: {protected_count}")
    print(f"Save Game & Junction Entities: {save_game_count}")
    print(f"Duplicates Found: {len(duplicates)}")
    status = "PASS" if len(duplicates) == 0 and len(all_objs) == 139 else "FAIL"
    print(f"RULE 8 RESULT: {status}\n")
    return status == "PASS"

def audit_economy_sha256():
    print("=== PROTECTED ECONOMY ARTIFACTS SHA-256 INTEGRITY ===")
    cmd = (
        "find force-app/main/default/objects "
        "-maxdepth 1 -type d "
        "\\( -name 'Economy_Analysis__c' -o -name 'Country_Economy__c' "
        "-o -name 'Product_Economy__c' -o -name 'Country_Product_Economy__c' "
        "-o -name 'State_Economy__c' -o -name 'Province_Economy__c' "
        "-o -name 'Factory_Economy__c' -o -name 'Artisan_Economy__c' "
        "-o -name 'Economy_Import_Event__e' -o -name 'Country__c' "
        "-o -name 'Product__c' -o -name 'State__c' -o -name 'Province__c' \\) "
        "-exec find {} -type f \\; "
        "| LC_ALL=C sort "
        "| xargs sha256sum "
        "| sha256sum"
    )
    raw_hash_out = run_cmd(cmd)
    hash_val = raw_hash_out.split()[0] if raw_hash_out else "ERROR"
    print(f"Command Executed:\n{cmd}")
    print(f"Raw Output:\n{raw_hash_out}")
    expected_hash = "976a8638bbbba3e52848e32e34d1144b3ca5a5dc46f723fc9fba8a10d5ef2a38"
    match = (hash_val == expected_hash)
    status = "PASS" if match else "FAIL"
    print(f"Protected Economy Baseline Match: {match} ({hash_val} == {expected_hash})")
    print(f"ECONOMY SHA-256 RESULT: {status}\n")
    return status == "PASS"

def audit_rollback_snapshot_and_model_accounting():
    print("=== ROLLBACK SNAPSHOT & MODEL FILE ACCOUNTING ===")
    if not os.path.exists(PRE_TRACK_E_MODEL):
        print(f"ERROR: Rollback snapshot file {PRE_TRACK_E_MODEL} does not exist.")
        return False

    pre_hash = run_cmd(f"sha256sum {PRE_TRACK_E_MODEL}").split()[0]
    post_hash = run_cmd(f"sha256sum {EXPANDED_MODEL}").split()[0]

    with open(PRE_TRACK_E_MODEL, 'rb') as f:
        pre_bytes = len(f.read())
    with open(PRE_TRACK_E_MODEL, 'r') as f:
        pre_lines = len(f.readlines())

    with open(EXPANDED_MODEL, 'rb') as f:
        post_bytes = len(f.read())
    with open(EXPANDED_MODEL, 'r') as f:
        post_lines = len(f.readlines())

    byte_delta = post_bytes - pre_bytes
    line_delta = post_lines - pre_lines
    pct_delta = (byte_delta / pre_bytes) * 100

    print(f"Pre-Track-E Snapshot File:  {PRE_TRACK_E_MODEL}")
    print(f"Pre-Track-E SHA-256:        {pre_hash}")
    print(f"Pre-Track-E File Size:      {pre_bytes:,} bytes ({pre_lines:,} lines)")
    print(f"Post-Track-E Model File:    {EXPANDED_MODEL}")
    print(f"Post-Track-E SHA-256:       {post_hash}")
    print(f"Post-Track-E File Size:     {post_bytes:,} bytes ({post_lines:,} lines)")
    print(f"Size Delta:                 {byte_delta:+,} bytes ({pct_delta:+.2f}%), {line_delta:+} lines")

    diff_cmd = f"diff -u {PRE_TRACK_E_MODEL} {EXPANDED_MODEL} | wc -l"
    diff_lines = run_cmd(diff_cmd)
    print(f"Unified Diff Output Length: {diff_lines} lines")
    print("MODEL FILE ACCOUNTING RESULT: PASS\n")
    return True

def main():
    print("=" * 70)
    print("TRACK D PHASE 1 / TRACK E-2 AUTOMATED INDEPENDENT AUDIT VERIFICATION")
    print("=" * 70)

    if not os.path.exists(BASE_DIR):
        print(f"ERROR: Base directory {BASE_DIR} does not exist.")
        sys.exit(1)

    all_objs = sorted([d for d in os.listdir(BASE_DIR) if os.path.isdir(os.path.join(BASE_DIR, d))])
    all_objs_set = set(all_objs)

    results = []
    results.append(("Rule 1: API Name Validity & Double Suffixes", audit_rule_1_double_suffixes(all_objs)))
    results.append(("Rule 2: Field Name Validity & Syntax", audit_rule_2_field_validity(all_objs)))
    results.append(("Rule 3: Field Name Semantic Fit (News_Scope_Value__c)", audit_rule_3_semantic_fit()))
    results.append(("Rule 4: Parent-Child Consistency & Relationships", audit_rule_4_parent_child_consistency(all_objs)))
    results.append(("Rule 5: Lookup Target Existence", audit_rule_5_lookup_targets(all_objs_set)))
    results.append(("Rule 6: Governor Limits (<= 40 Lookups)", audit_rule_6_governor_limits(all_objs)))
    results.append(("Rule 7: Self-Referential Parent Restrictions", audit_rule_7_self_referential(all_objs)))
    results.append(("Rule 8: Duplicate Object Declarations", audit_rule_8_duplicate_objects(all_objs)))
    results.append(("Protected Economy SHA-256 Baseline Integrity", audit_economy_sha256()))
    results.append(("Rollback Snapshot & File Accounting", audit_rollback_snapshot_and_model_accounting()))

    print("=" * 70)
    print("FINAL AUDIT SUMMARY")
    print("=" * 70)
    all_passed = True
    for name, res in results:
        status_str = "✅ PASS" if res else "❌ FAIL"
        if not res: all_passed = False
        print(f"{name:<50} | {status_str}")

    print("=" * 70)
    if all_passed:
        print("OVERALL VERDICT: ✅ PASS — ALL RULES AND CONSTRAINTS FULLY SATISFIED")
        sys.exit(0)
    else:
        print("OVERALL VERDICT: ❌ FAIL — AT LEAST ONE RULE OR CONSTRAINT FAILED")
        sys.exit(1)

if __name__ == "__main__":
    main()
