import os
import xml.etree.ElementTree as ET

BASE_DIR = "vc2-salesforce-version/force-app/main/default/objects"
NS = "{http://soap.sforce.com/2006/04/metadata}"

# Compute counts dynamically
total_objects = 0
total_fields = 0
for obj in sorted(os.listdir(BASE_DIR)):
    obj_path = os.path.join(BASE_DIR, obj)
    if os.path.isdir(obj_path):
        total_objects += 1
        fields_dir = os.path.join(obj_path, "fields")
        if os.path.isdir(fields_dir):
            total_fields += len([f for f in os.listdir(fields_dir) if f.endswith(".field-meta.xml")])

md_lines = [
    "# Victoria 2 Economy Analyzer — Salesforce Field Inventory",
    "",
    "This document provides the authoritative inventory of all Custom Objects, Custom Fields, Data Types, Precisions, Formulas, External IDs, and Relationships created in the application.",
    "",
    "## Summary Metrics",
    f"- **Custom Objects:** {total_objects}",
    f"- **Custom Fields:** {total_fields}",
    "",
    "---",
    ""
]

for obj in sorted(os.listdir(BASE_DIR)):
    obj_path = os.path.join(BASE_DIR, obj)
    if not os.path.isdir(obj_path):
        continue

    obj_xml = os.path.join(obj_path, f"{obj}.object-meta.xml")
    tree = ET.parse(obj_xml)
    root = tree.getroot()
    label = root.find(f"{NS}label").text
    sharing_node = root.find(f"{NS}sharingModel")
    sharing = sharing_node.text if sharing_node is not None else "N/A (Custom Event)"

    md_lines.append(f"## Custom Object: `{obj}` ({label})")
    md_lines.append(f"- **Sharing Model:** `{sharing}`")
    md_lines.append("")
    md_lines.append("| Field API Name | Label | Type | Precision/Scale/Length | Formula / Relationship / Summary Details | Attributes |")
    md_lines.append("| :--- | :--- | :--- | :--- | :--- | :--- |")

    fields_dir = os.path.join(obj_path, "fields")
    field_files = sorted([f for f in os.listdir(fields_dir) if f.endswith(".field-meta.xml")])

    for ff in field_files:
        ftree = ET.parse(os.path.join(fields_dir, ff))
        froot = ftree.getroot()
        fname = froot.find(f"{NS}fullName").text
        flabel = froot.find(f"{NS}label").text
        ftype = froot.find(f"{NS}type").text

        psl = "-"
        details = "-"
        attrs = []

        if froot.find(f"{NS}precision") is not None and froot.find(f"{NS}scale") is not None:
            prec = froot.find(f"{NS}precision").text
            scale = froot.find(f"{NS}scale").text
            psl = f"{prec}, {scale}"
        elif froot.find(f"{NS}length") is not None:
            psl = froot.find(f"{NS}length").text

        if froot.find(f"{NS}formula") is not None:
            details = f"`{froot.find(f'{NS}formula').text}`"
        elif ftype in ["Lookup", "MasterDetail"]:
            ref = froot.find(f"{NS}referenceTo").text
            rel = froot.find(f"{NS}relationshipName").text
            details = f"Target: `{ref}`, Rel: `{rel}`"
        elif ftype == "Summary":
            op = froot.find(f"{NS}summaryOperation").text
            sf = froot.find(f"{NS}summarizedField").text
            details = f"SUM(`{sf}`)"

        if froot.find(f"{NS}externalId") is not None and froot.find(f"{NS}externalId").text == "true":
            attrs.append("External ID")
        if froot.find(f"{NS}unique") is not None and froot.find(f"{NS}unique").text == "true":
            attrs.append("Unique")
        if froot.find(f"{NS}required") is not None and froot.find(f"{NS}required").text == "true":
            attrs.append("Required")

        attr_str = ", ".join(attrs) if attrs else "None"

        md_lines.append(f"| `{fname}` | {flabel} | {ftype} | {psl} | {details} | {attr_str} |")

    md_lines.append("")
    md_lines.append("---")
    md_lines.append("")

with open("vc2-salesforce-version/field-inventory.md", "w") as f:
    f.write("\n".join(md_lines))

print("field-inventory.md generated successfully.")
