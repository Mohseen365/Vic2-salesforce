#!/usr/bin/env python3
"""
Track C — Permission Set Generator
Generates Economy_Analyzer_User and Economy_Analyzer_Admin permission sets covering:
- All 139 custom objects
- All 997 custom fields
- Designated Apex classes
- Custom tabs (if any exist)
"""

import os
import glob
import xml.etree.ElementTree as ET
from xml.dom import minidom

OBJECTS_DIR = "force-app/main/default/objects"
PERMSETS_DIR = "force-app/main/default/permissionsets"

USER_APEX_CLASSES = sorted([
    "CountrySelector",
    "EconomyAnalysisController",
    "EconomyAnalysisSelector",
    "EconomyAnalysisService",
    "EconomyCalculationEngine",
    "ProductSelector"
])

ADMIN_APEX_CLASSES = sorted(USER_APEX_CLASSES + [
    "EconomyImportBatch",
    "EconomyImportRestResource",
    "EconomyImportService"
])

def get_all_objects_and_fields():
    """Enumerates all custom objects and their fields sorted alphabetically."""
    objects_data = {}

    obj_folders = sorted([
        d for d in os.listdir(OBJECTS_DIR)
        if os.path.isdir(os.path.join(OBJECTS_DIR, d))
    ])

    for obj_name in obj_folders:
        fields_dir = os.path.join(OBJECTS_DIR, obj_name, "fields")
        fields = []
        if os.path.isdir(fields_dir):
            field_files = sorted(glob.glob(os.path.join(fields_dir, "*.field-meta.xml")))
            for ff in field_files:
                field_xml_name = os.path.basename(ff).replace(".field-meta.xml", "")
                field_full_name = f"{obj_name}.{field_xml_name}"
                fields.append(field_full_name)
        objects_data[obj_name] = sorted(fields)

    return objects_data

def build_permission_set_xml(label, description, apex_classes, objects_data, is_admin=False):
    root = ET.Element("PermissionSet", xmlns="http://soap.sforce.com/2006/04/metadata")

    # Label & Description
    lbl_elem = ET.SubElement(root, "label")
    lbl_elem.text = label

    desc_elem = ET.SubElement(root, "description")
    desc_elem.text = description

    has_act = ET.SubElement(root, "hasActivationRequired")
    has_act.text = "false"

    # Class Accesses (sorted alphabetically)
    for cls in sorted(apex_classes):
        ca = ET.SubElement(root, "classAccesses")
        ac = ET.SubElement(ca, "apexClass")
        ac.text = cls
        en = ET.SubElement(ca, "enabled")
        en.text = "true"

    # Field Permissions (sorted alphabetically by field name across all objects)
    all_field_perms = []
    for obj_name in sorted(objects_data.keys()):
        is_platform_event = obj_name.endswith("__e")
        for field_name in objects_data[obj_name]:
            all_field_perms.append((field_name, is_platform_event))

    all_field_perms.sort(key=lambda x: x[0])

    for field_name, is_platform_event in all_field_perms:
        fp = ET.SubElement(root, "fieldPermissions")
        ed = ET.SubElement(fp, "editable")
        # Platform events or User permissions -> editable false
        ed.text = "true" if (is_admin and not is_platform_event) else "false"
        fl = ET.SubElement(fp, "field")
        fl.text = field_name
        rd = ET.SubElement(fp, "readable")
        rd.text = "true"

    # Object Permissions (sorted alphabetically by object)
    for obj_name in sorted(objects_data.keys()):
        is_platform_event = obj_name.endswith("__e")
        op = ET.SubElement(root, "objectPermissions")

        c = ET.SubElement(op, "allowCreate")
        d = ET.SubElement(op, "allowDelete")
        e = ET.SubElement(op, "allowEdit")
        r = ET.SubElement(op, "allowRead")
        m = ET.SubElement(op, "modifyAllRecords")
        o = ET.SubElement(op, "object")
        o.text = obj_name
        v = ET.SubElement(op, "viewAllRecords")

        if is_platform_event:
            # Platform event permissions
            c.text = "true"
            d.text = "false"
            e.text = "false"
            r.text = "true"
            m.text = "false"
            v.text = "false"
        elif is_admin:
            c.text = "true"
            d.text = "true"
            e.text = "true"
            r.text = "true"
            m.text = "true"
            v.text = "true"
        else:
            c.text = "false"
            d.text = "false"
            e.text = "false"
            r.text = "true"
            m.text = "false"
            v.text = "false"

    # Convert to pretty XML string with UTF-8 declaration
    raw_xml = ET.tostring(root, encoding="utf-8")
    reparsed = minidom.parseString(raw_xml)
    pretty_xml = reparsed.toprettyxml(indent="    ", encoding="UTF-8").decode("utf-8")

    # Fix empty line issue from minidom toprettyxml
    lines = [line for line in pretty_xml.splitlines() if line.strip()]
    return "\n".join(lines) + "\n"

def main():
    os.makedirs(PERMSETS_DIR, exist_ok=True)
    objects_data = get_all_objects_and_fields()

    total_objs = len(objects_data)
    total_fields = sum(len(f) for f in objects_data.values())
    print(f"Loaded {total_objs} objects and {total_fields} fields.")

    # User PermSet
    user_label = "Economy Analyzer User"
    user_desc = "Read-only access to the economy analyzer and full save-game data model. Does not grant import, edit, or delete privileges."
    user_xml = build_permission_set_xml(user_label, user_desc, USER_APEX_CLASSES, objects_data, is_admin=False)
    user_path = os.path.join(PERMSETS_DIR, "Economy_Analyzer_User.permissionset-meta.xml")
    with open(user_path, "w", encoding="utf-8") as f:
        f.write(user_xml)
    print(f"Wrote {user_path}")

    # Admin PermSet
    admin_label = "Economy Analyzer Admin"
    admin_desc = "Full read/write/delete access to the economy analyzer and full save-game data model. Includes import pipeline execution."
    admin_xml = build_permission_set_xml(admin_label, admin_desc, ADMIN_APEX_CLASSES, objects_data, is_admin=True)
    admin_path = os.path.join(PERMSETS_DIR, "Economy_Analyzer_Admin.permissionset-meta.xml")
    with open(admin_path, "w", encoding="utf-8") as f:
        f.write(admin_xml)
    print(f"Wrote {admin_path}")

if __name__ == "__main__":
    main()
