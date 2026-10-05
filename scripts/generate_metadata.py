import os

BASE_DIR = "vc2-salesforce-version/force-app/main/default/objects"

def make_obj(api_name, label, plural, name_type="Text", name_label="Name"):
    obj_dir = os.path.join(BASE_DIR, api_name)
    os.makedirs(os.path.join(obj_dir, "fields"), exist_ok=True)
    sharing = "ControlledByParent" if api_name in ["Country_Economy__c", "Product_Economy__c", "Country_Product_Economy__c", "Province_Economy__c"] else "ReadWrite"

    xml_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>{label}</label>
    <pluralLabel>{plural}</pluralLabel>
    <sharingModel>{sharing}</sharingModel>
    <deploymentStatus>Deployed</deploymentStatus>
    <nameField>
        <label>{name_label}</label>
        <type>{name_type}</type>
    </nameField>
</CustomObject>
"""
    with open(os.path.join(obj_dir, f"{api_name}.object-meta.xml"), "w") as f:
        f.write(xml_content)

def write_field(obj_api, field_api, content):
    field_dir = os.path.join(BASE_DIR, obj_api, "fields")
    os.makedirs(field_dir, exist_ok=True)
    full_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>{field_api}</fullName>
{content}
</CustomField>
"""
    with open(os.path.join(field_dir, f"{field_api}.field-meta.xml"), "w") as f:
        f.write(full_xml)

# 1. Country__c
make_obj("Country__c", "Country", "Countries", name_label="Country Name")
write_field("Country__c", "Tag__c", """    <label>Country Tag</label>
    <type>Text</type>
    <length>10</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")
write_field("Country__c", "Flag_URL__c", """    <label>Flag URL</label>
    <type>Url</type>""")

# 2. Product__c
make_obj("Product__c", "Product", "Products", name_label="Product Name")
write_field("Product__c", "Code__c", """    <label>Product Code</label>
    <type>Text</type>
    <length>50</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")
write_field("Product__c", "Base_Price__c", """    <label>Base Price</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>4</scale>""")

# 3. Province__c
make_obj("Province__c", "Province", "Provinces", name_label="Province Name")
write_field("Province__c", "External_Province_Id__c", """    <label>External Province ID</label>
    <type>Text</type>
    <length>50</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")
write_field("Province__c", "Country__c", """    <label>Country</label>
    <type>Lookup</type>
    <referenceTo>Country__c</referenceTo>
    <relationshipName>Provinces</relationshipName>
    <required>false</required>""")

# 4. Economy_Analysis__c
make_obj("Economy_Analysis__c", "Economy Analysis", "Economy Analyses", name_label="Analysis Name")
write_field("Economy_Analysis__c", "Save_File_Name__c", """    <label>Save File Name</label>
    <type>Text</type>
    <length>255</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")
write_field("Economy_Analysis__c", "Ingame_Date__c", """    <label>Ingame Date</label>
    <type>Date</type>
    <required>true</required>""")
write_field("Economy_Analysis__c", "Analysis_Timestamp__c", """    <label>Analysis Timestamp</label>
    <type>DateTime</type>""")
write_field("Economy_Analysis__c", "Source_Save_File_Name__c", """    <label>Source Save File Name</label>
    <type>Text</type>
    <length>255</length>""")
write_field("Economy_Analysis__c", "Player_Country_Tag__c", """    <label>Player Country Tag</label>
    <type>Text</type>
    <length>10</length>""")
write_field("Economy_Analysis__c", "Import_Status__c", """    <label>Import Status</label>
    <type>Picklist</type>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>RECEIVED</fullName>
                <default>true</default>
                <label>RECEIVED</label>
            </value>
            <value>
                <fullName>PROCESSING</fullName>
                <default>false</default>
                <label>PROCESSING</label>
            </value>
            <value>
                <fullName>CALCULATING</fullName>
                <default>false</default>
                <label>CALCULATING</label>
            </value>
            <value>
                <fullName>COMPLETED</fullName>
                <default>false</default>
                <label>COMPLETED</label>
            </value>
            <value>
                <fullName>FAILED</fullName>
                <default>false</default>
                <label>FAILED</label>
            </value>
        </valueSetDefinition>
    </valueSet>""")
write_field("Economy_Analysis__c", "Total_World_GDP__c", """    <label>Total World GDP</label>
    <type>Summary</type>
    <summaryOperation>sum</summaryOperation>
    <summarizedField>Country_Economy__c.GDP__c</summarizedField>
    <summaryForeignKey>Country_Economy__c.Economy_Analysis__c</summaryForeignKey>""")
write_field("Economy_Analysis__c", "Total_World_Population__c", """    <label>Total World Population</label>
    <type>Summary</type>
    <summaryOperation>sum</summaryOperation>
    <summarizedField>Country_Economy__c.Population__c</summarizedField>
    <summaryForeignKey>Country_Economy__c.Economy_Analysis__c</summaryForeignKey>""")
# Note: Total_World_Imports__c and Total_World_Exports__c are Currency(18,2) calculated/written by Apex Service
# because Country_Economy__c.Total_Imports_Value__c is already a Roll-Up Summary (Salesforce forbids Roll-Up on Roll-Up).
write_field("Economy_Analysis__c", "Total_World_Imports__c", """    <label>Total World Imports (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Economy_Analysis__c", "Total_World_Exports__c", """    <label>Total World Exports (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")

# 5. Country_Economy__c
make_obj("Country_Economy__c", "Country Economy", "Country Economies", name_label="Country Economy Key")
write_field("Country_Economy__c", "Economy_Analysis__c", """    <label>Economy Analysis</label>
    <type>MasterDetail</type>
    <referenceTo>Economy_Analysis__c</referenceTo>
    <relationshipName>Country_Economies</relationshipName>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>""")
write_field("Country_Economy__c", "Country__c", """    <label>Country</label>
    <type>Lookup</type>
    <referenceTo>Country__c</referenceTo>
    <relationshipName>Country_Economies</relationshipName>
    <required>true</required>""")
write_field("Country_Economy__c", "Country_Tag__c", """    <label>Country Tag</label>
    <type>Text</type>
    <length>10</length>""")
write_field("Country_Economy__c", "Population__c", """    <label>Population</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Workforce__c", """    <label>Workforce</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Workforce_RGO__c", """    <label>Workforce RGO</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Workforce_Factory__c", """    <label>Workforce Factory</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Employment__c", """    <label>Employment</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Employment_RGO__c", """    <label>Employment RGO</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Employment_Factory__c", """    <label>Employment Factory</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "Unemployment_Rate__c", """    <label>Unemployment Rate</label>
    <type>Percent</type>
    <precision>6</precision>
    <scale>2</scale>
    <formula>IF(Workforce__c > 0, (Workforce__c - Employment__c) / Workforce__c, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Country_Economy__c", "Unemployment_Rate_RGO__c", """    <label>Unemployment Rate RGO</label>
    <type>Percent</type>
    <precision>6</precision>
    <scale>2</scale>
    <formula>IF(Workforce_RGO__c > 0, (Workforce_RGO__c - Employment_RGO__c) / Workforce_RGO__c, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Country_Economy__c", "Unemployment_Rate_Factory__c", """    <label>Unemployment Rate Factory</label>
    <type>Percent</type>
    <precision>6</precision>
    <scale>2</scale>
    <formula>IF(Workforce_Factory__c > 0, (Workforce_Factory__c - Employment_Factory__c) / Workforce_Factory__c, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Country_Economy__c", "GDP__c", """    <label>GDP (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Economy__c", "GDP_Rank__c", """    <label>GDP Rank</label>
    <type>Number</type>
    <precision>6</precision>
    <scale>0</scale>""")
write_field("Country_Economy__c", "GDP_Share_Percent__c", """    <label>GDP Share %</label>
    <type>Percent</type>
    <precision>6</precision>
    <scale>4</scale>
    <formula>IF(Economy_Analysis__r.Total_World_GDP__c > 0, GDP__c / Economy_Analysis__r.Total_World_GDP__c, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Country_Economy__c", "GDP_Per_Capita__c", """    <label>GDP Per Capita (£/100k)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>
    <formula>IF(Population__c > 0, (GDP__c / Population__c) * 100000, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Country_Economy__c", "Total_Imports_Value__c", """    <label>Total Imports Value (£)</label>
    <type>Summary</type>
    <summaryOperation>sum</summaryOperation>
    <summarizedField>Country_Product_Economy__c.Import_Value__c</summarizedField>
    <summaryForeignKey>Country_Product_Economy__c.Country_Economy__c</summaryForeignKey>""")
write_field("Country_Economy__c", "Total_Exports_Value__c", """    <label>Total Exports Value (£)</label>
    <type>Summary</type>
    <summaryOperation>sum</summaryOperation>
    <summarizedField>Country_Product_Economy__c.Export_Value__c</summarizedField>
    <summaryForeignKey>Country_Product_Economy__c.Country_Economy__c</summaryForeignKey>""")
write_field("Country_Economy__c", "Gold_Income__c", """    <label>Gold Income (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Economy__c", "Unique_Snapshot_Key__c", """    <label>Unique Snapshot Key</label>
    <type>Text</type>
    <length>100</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")

# 6. Product_Economy__c
make_obj("Product_Economy__c", "Product Economy", "Product Economies", name_label="Product Economy Key")
write_field("Product_Economy__c", "Economy_Analysis__c", """    <label>Economy Analysis</label>
    <type>MasterDetail</type>
    <referenceTo>Economy_Analysis__c</referenceTo>
    <relationshipName>Product_Economies</relationshipName>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>""")
write_field("Product_Economy__c", "Product__c", """    <label>Product</label>
    <type>Lookup</type>
    <referenceTo>Product__c</referenceTo>
    <relationshipName>Product_Economies</relationshipName>
    <required>true</required>""")
write_field("Product_Economy__c", "Product_Code__c", """    <label>Product Code</label>
    <type>Text</type>
    <length>50</length>""")
write_field("Product_Economy__c", "Price__c", """    <label>Price</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Product_Economy__c", "Base_Price__c", """    <label>Base Price</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Product_Economy__c", "Inflation_Percent__c", """    <label>Inflation %</label>
    <type>Percent</type>
    <precision>6</precision>
    <scale>2</scale>
    <formula>IF(Base_Price__c > 0, (Price__c - Base_Price__c) / Base_Price__c, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Product_Economy__c", "Total_World_Supply__c", """    <label>Total World Supply</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Product_Economy__c", "Real_Demand__c", """    <label>Real Demand</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Product_Economy__c", "Max_Demand__c", """    <label>Max Demand</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Product_Economy__c", "Overproduction_Percent__c", """    <label>Overproduction %</label>
    <type>Percent</type>
    <precision>6</precision>
    <scale>2</scale>
    <formula>IF(Real_Demand__c > 0, (Total_World_Supply__c / Real_Demand__c) * 100, 0.0)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>""")
write_field("Product_Economy__c", "Unique_Snapshot_Key__c", """    <label>Unique Snapshot Key</label>
    <type>Text</type>
    <length>100</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")

# 7. Country_Product_Economy__c
make_obj("Country_Product_Economy__c", "Country Product Economy", "Country Product Economies", name_label="Country Product Key")
write_field("Country_Product_Economy__c", "Country_Economy__c", """    <label>Country Economy</label>
    <type>MasterDetail</type>
    <referenceTo>Country_Economy__c</referenceTo>
    <relationshipName>Country_Product_Economies</relationshipName>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>""")
write_field("Country_Product_Economy__c", "Product_Economy__c", """    <label>Product Economy</label>
    <type>Lookup</type>
    <referenceTo>Product_Economy__c</referenceTo>
    <relationshipName>Country_Product_Economies</relationshipName>
    <required>true</required>""")
write_field("Country_Product_Economy__c", "Product__c", """    <label>Product</label>
    <type>Lookup</type>
    <referenceTo>Product__c</referenceTo>
    <relationshipName>Country_Product_Economies</relationshipName>
    <required>true</required>""")
write_field("Country_Product_Economy__c", "Product_Code__c", """    <label>Product Code</label>
    <type>Text</type>
    <length>50</length>""")
write_field("Country_Product_Economy__c", "Sold_Domestic__c", """    <label>Sold Domestic</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Thrown_To_Market__c", """    <label>Thrown To Market</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Actual_Sold_World__c", """    <label>Actual Sold World</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Worldmarket_Pool__c", """    <label>Worldmarket Pool</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Bought_Quantity__c", """    <label>Bought Quantity</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Sold_Quantity__c", """    <label>Sold Quantity</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Intermediate_Consumption__c", """    <label>Intermediate Consumption</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Country_Product_Economy__c", "Total_Supply_Pounds__c", """    <label>Total Supply (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "Actual_Supply_Pounds__c", """    <label>Actual Supply (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "Actual_Demand_Pounds__c", """    <label>Actual Demand (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "Import_Value__c", """    <label>Import Value (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "Export_Value__c", """    <label>Export Value (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "Domestic_Sales_Value__c", """    <label>Domestic Sales Value (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "GDP_Contribution__c", """    <label>GDP Contribution (£)</label>
    <type>Currency</type>
    <precision>18</precision>
    <scale>2</scale>""")
write_field("Country_Product_Economy__c", "Unique_Snapshot_Key__c", """    <label>Unique Snapshot Key</label>
    <type>Text</type>
    <length>150</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")

# 8. Province_Economy__c
make_obj("Province_Economy__c", "Province Economy", "Province Economies", name_label="Province Economy Key")
write_field("Province_Economy__c", "Country_Economy__c", """    <label>Country Economy</label>
    <type>MasterDetail</type>
    <referenceTo>Country_Economy__c</referenceTo>
    <relationshipName>Province_Economies</relationshipName>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>""")
write_field("Province_Economy__c", "Province__c", """    <label>Province</label>
    <type>Lookup</type>
    <referenceTo>Province__c</referenceTo>
    <relationshipName>Province_Economies</relationshipName>
    <required>true</required>""")
write_field("Province_Economy__c", "Population__c", """    <label>Population</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>0</scale>""")
write_field("Province_Economy__c", "RGO_Production__c", """    <label>RGO Production</label>
    <type>Number</type>
    <precision>18</precision>
    <scale>4</scale>""")
write_field("Province_Economy__c", "Unique_Snapshot_Key__c", """    <label>Unique Snapshot Key</label>
    <type>Text</type>
    <length>150</length>
    <externalId>true</externalId>
    <unique>true</unique>
    <required>true</required>""")

print("Metadata script generated successfully.")
