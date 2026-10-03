import os
import xml.etree.ElementTree as ET

BASE_DIR = "vc2-salesforce-version/force-app/main/default/objects"

total_objects = 0
total_fields = 0

object_dirs = [d for d in os.listdir(BASE_DIR) if os.path.isdir(os.path.join(BASE_DIR, d))]

print(f"Found {len(object_dirs)} Custom Objects in {BASE_DIR}:")

for obj in sorted(object_dirs):
    obj_meta_file = os.path.join(BASE_DIR, obj, f"{obj}.object-meta.xml")
    assert os.path.exists(obj_meta_file), f"Missing object meta file for {obj}"

    # Parse object meta
    tree = ET.parse(obj_meta_file)
    root = tree.getroot()
    label = root.find("{http://soap.sforce.com/2006/04/metadata}label").text

    fields_dir = os.path.join(BASE_DIR, obj, "fields")
    field_files = [f for f in os.listdir(fields_dir) if f.endswith(".field-meta.xml")]

    print(f"\nObject: {obj} ('{label}') - {len(field_files)} custom fields")
    total_objects += 1

    for ff in sorted(field_files):
        total_fields += 1
        ff_path = os.path.join(fields_dir, ff)
        ftree = ET.parse(ff_path)
        froot = ftree.getroot()
        fname = froot.find("{http://soap.sforce.com/2006/04/metadata}fullName").text
        flabel = froot.find("{http://soap.sforce.com/2006/04/metadata}label").text
        ftype = froot.find("{http://soap.sforce.com/2006/04/metadata}type").text

        extra_info = []
        if froot.find("{http://soap.sforce.com/2006/04/metadata}externalId") is not None and froot.find("{http://soap.sforce.com/2006/04/metadata}externalId").text == 'true':
            extra_info.append("External ID")
        if froot.find("{http://soap.sforce.com/2006/04/metadata}unique") is not None and froot.find("{http://soap.sforce.com/2006/04/metadata}unique").text == 'true':
            extra_info.append("Unique")
        if froot.find("{http://soap.sforce.com/2006/04/metadata}formula") is not None:
            formula_text = froot.find("{http://soap.sforce.com/2006/04/metadata}formula").text
            extra_info.append(f"Formula: `{formula_text}`")
        if ftype == 'Summary':
            op = froot.find("{http://soap.sforce.com/2006/04/metadata}summaryOperation").text
            sum_f = froot.find("{http://soap.sforce.com/2006/04/metadata}summarizedField").text
            extra_info.append(f"Rollup ({op} {sum_f})")

        extra_str = f" [{', '.join(extra_info)}]" if extra_info else ""
        print(f"  - {fname} ({ftype}){extra_str}")

print(f"\nVALIDATION SUMMARY: {total_objects} Objects, {total_fields} Fields verified with 100% valid XML structure.")
