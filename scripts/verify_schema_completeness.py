import os
import xml.etree.ElementTree as ET

BASE_DIR = "vc2-salesforce-version/force-app/main/default/objects"
NS = "{http://soap.sforce.com/2006/04/metadata}"

errors = []
field_count = 0

for obj in os.listdir(BASE_DIR):
    obj_path = os.path.join(BASE_DIR, obj)
    if not os.path.isdir(obj_path):
        continue

    obj_xml = os.path.join(obj_path, f"{obj}.object-meta.xml")
    try:
        ET.parse(obj_xml)
    except Exception as e:
        errors.append(f"Invalid XML in object definition {obj_xml}: {e}")

    fields_dir = os.path.join(obj_path, "fields")
    if not os.path.exists(fields_dir):
        errors.append(f"Missing fields directory for {obj}")
        continue

    for f in os.listdir(fields_dir):
        if not f.endswith(".field-meta.xml"):
            continue
        field_count += 1
        f_path = os.path.join(fields_dir, f)
        try:
            tree = ET.parse(f_path)
            root = tree.getroot()

            # Common checks
            full_name = root.find(f"{NS}fullName")
            label = root.find(f"{NS}label")
            ftype = root.find(f"{NS}type")

            if full_name is None or not full_name.text:
                errors.append(f"{f_path}: missing or empty fullName")
            if label is None or not label.text:
                errors.append(f"{f_path}: missing or empty label")
            if ftype is None or not ftype.text:
                errors.append(f"{f_path}: missing or empty type")
                continue

            type_str = ftype.text
            if type_str in ["Number", "Currency", "Percent"]:
                prec = root.find(f"{NS}precision")
                scale = root.find(f"{NS}scale")
                if prec is None or scale is None:
                    errors.append(f"{f_path}: {type_str} field missing precision or scale")
            elif type_str in ["Lookup", "MasterDetail"]:
                ref = root.find(f"{NS}referenceTo")
                rel = root.find(f"{NS}relationshipName")
                if ref is None or rel is None:
                    errors.append(f"{f_path}: {type_str} field missing referenceTo or relationshipName")
            elif type_str == "Summary":
                op = root.find(f"{NS}summaryOperation")
                sf = root.find(f"{NS}summarizedField")
                fk = root.find(f"{NS}summaryForeignKey")
                if op is None or sf is None or fk is None:
                    errors.append(f"{f_path}: Summary field missing summaryOperation, summarizedField, or summaryForeignKey")
        except Exception as e:
            errors.append(f"Invalid XML in field file {f_path}: {e}")

if errors:
    print("Verification FAILED with errors:")
    for err in errors:
        print(f"  - {err}")
    exit(1)
else:
    print(f"Verification PASSED: {field_count} field XML files verified with zero errors.")
