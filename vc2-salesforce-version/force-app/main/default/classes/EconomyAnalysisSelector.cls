/**
 * @description Centralized, secure SOQL data selector for Economy_Analysis__c and related snapshot SObjects.
 * Enforces `with sharing` and applies `Security.stripInaccessible` for FLS compliance.
 */
public with sharing class EconomyAnalysisSelector {

    /**
     * @description Selects a single Economy_Analysis__c record by Id.
     * @param analysisId Id of the analysis record.
     * @return Economy_Analysis__c or null.
     */
    public static Economy_Analysis__c selectById(Id analysisId) {
        if (analysisId == null || !Schema.sObjectType.Economy_Analysis__c.isAccessible()) {
            return null;
        }

        List<Economy_Analysis__c> records = [
            SELECT Id, Name, Save_File_Name__c, Source_Save_File_Name__c, Ingame_Date__c,
                   Analysis_Timestamp__c, Player_Country_Tag__c, Total_World_GDP__c,
                   Total_World_Population__c, Total_World_Imports__c, Total_World_Exports__c,
                   Import_Status__c, Import_Diagnostic_Message__c
            FROM Economy_Analysis__c
            WHERE Id = :analysisId
            LIMIT 1
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        List<Economy_Analysis__c> cleanList = (List<Economy_Analysis__c>) decision.getRecords();
        return cleanList.isEmpty() ? null : cleanList[0];
    }

    /**
     * @description Selects recent Economy_Analysis__c records up to limitCount.
     * @param limitCount Maximum records to return.
     * @return List of Economy_Analysis__c records.
     */
    public static List<Economy_Analysis__c> selectAllRecent(Integer limitCount) {
        if (!Schema.sObjectType.Economy_Analysis__c.isAccessible()) {
            return new List<Economy_Analysis__c>();
        }

        Integer effectiveLimit = (limitCount != null && limitCount > 0) ? limitCount : 50;

        List<Economy_Analysis__c> records = [
            SELECT Id, Name, Save_File_Name__c, Source_Save_File_Name__c, Ingame_Date__c,
                   Analysis_Timestamp__c, Player_Country_Tag__c, Total_World_GDP__c,
                   Total_World_Population__c, Total_World_Imports__c, Total_World_Exports__c,
                   Import_Status__c, Import_Diagnostic_Message__c
            FROM Economy_Analysis__c
            ORDER BY Analysis_Timestamp__c DESC, CreatedDate DESC
            LIMIT :effectiveLimit
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Economy_Analysis__c>) decision.getRecords();
    }

    /**
     * @description Selects Country_Economy__c records for a given analysis Id.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of Country_Economy__c records.
     */
    public static List<Country_Economy__c> selectCountryEconomies(Id analysisId) {
        if (analysisId == null || !Schema.sObjectType.Country_Economy__c.isAccessible()) {
            return new List<Country_Economy__c>();
        }

        List<Country_Economy__c> records = [
            SELECT Id, Name, Economy_Analysis__c, Country__c, Country_Tag__c, Population__c,
                   Workforce__c, Employment__c, Workforce_RGO__c, Employment_RGO__c,
                   Workforce_Factory__c, Employment_Factory__c, GDP__c, GDP_Rank__c,
                   GDP_Per_Capita__c, GDP_Share_Percent__c, Unemployment_Rate__c,
                   Unemployment_Rate_RGO__c, Unemployment_Rate_Factory__c,
                   Total_Imports_Value__c, Total_Exports_Value__c, Gold_Income__c,
                   Unique_Snapshot_Key__c, Country__r.Tag__c, Country__r.Flag_URL__c, Country__r.Name
            FROM Country_Economy__c
            WHERE Economy_Analysis__c = :analysisId
            ORDER BY GDP__c DESC, Country_Tag__c ASC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Product_Economy__c records for a given analysis Id.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of Product_Economy__c records.
     */
    public static List<Product_Economy__c> selectProductEconomies(Id analysisId) {
        if (analysisId == null || !Schema.sObjectType.Product_Economy__c.isAccessible()) {
            return new List<Product_Economy__c>();
        }

        List<Product_Economy__c> records = [
            SELECT Id, Name, Economy_Analysis__c, Product__c, Product_Code__c, Price__c,
                   Base_Price__c, Inflation_Percent__c, Total_World_Supply__c, Real_Demand__c,
                   Max_Demand__c, Overproduction_Percent__c, Unique_Snapshot_Key__c,
                   Product__r.Code__c
            FROM Product_Economy__c
            WHERE Economy_Analysis__c = :analysisId
            ORDER BY Product_Code__c ASC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Product_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Country_Product_Economy__c records for a given Country_Economy__c Id.
     * @param countryEconomyId Parent Country_Economy__c Id.
     * @return List of Country_Product_Economy__c records.
     */
    public static List<Country_Product_Economy__c> selectCountryProductEconomies(Id countryEconomyId) {
        if (countryEconomyId == null || !Schema.sObjectType.Country_Product_Economy__c.isAccessible()) {
            return new List<Country_Product_Economy__c>();
        }

        List<Country_Product_Economy__c> records = [
            SELECT Id, Name, Country_Economy__c, Product_Economy__c, Product__c, Product_Code__c,
                   Sold_Domestic__c, Bought_Quantity__c, Thrown_To_Market__c, Actual_Sold_World__c,
                   Worldmarket_Pool__c, Intermediate_Consumption__c, Total_Supply_Pounds__c,
                   Actual_Supply_Pounds__c, Actual_Demand_Pounds__c, Import_Value__c,
                   Export_Value__c, Domestic_Sales_Value__c, GDP_Contribution__c,
                   Unique_Snapshot_Key__c, Product_Economy__r.Product_Code__c, Product_Economy__r.Price__c
            FROM Country_Product_Economy__c
            WHERE Country_Economy__c = :countryEconomyId
            ORDER BY Product_Code__c ASC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country_Product_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Country_Product_Economy__c records for a specific Product_Economy__c Id.
     * @param productEconomyId Parent Product_Economy__c Id.
     * @return List of Country_Product_Economy__c records.
     */
    public static List<Country_Product_Economy__c> selectCountryProductEconomiesByProduct(Id productEconomyId) {
        if (productEconomyId == null || !Schema.sObjectType.Country_Product_Economy__c.isAccessible()) {
            return new List<Country_Product_Economy__c>();
        }

        List<Country_Product_Economy__c> records = [
            SELECT Id, Name, Country_Economy__c, Product_Economy__c, Product__c, Product_Code__c,
                   Sold_Domestic__c, Bought_Quantity__c, Thrown_To_Market__c, Actual_Sold_World__c,
                   Worldmarket_Pool__c, Intermediate_Consumption__c, Total_Supply_Pounds__c,
                   Actual_Supply_Pounds__c, Actual_Demand_Pounds__c, Import_Value__c,
                   Export_Value__c, Domestic_Sales_Value__c, GDP_Contribution__c,
                   Unique_Snapshot_Key__c, Country_Economy__r.Country_Tag__c,
                   Country_Economy__r.Country__r.Name, Country_Economy__r.Country__r.Flag_URL__c
            FROM Country_Product_Economy__c
            WHERE Product_Economy__c = :productEconomyId
            ORDER BY GDP_Contribution__c DESC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country_Product_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects all Country_Product_Economy__c records for an entire Economy_Analysis__c.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of Country_Product_Economy__c records.
     */
    public static List<Country_Product_Economy__c> selectCountryProductEconomiesByAnalysis(Id analysisId) {
        if (analysisId == null || !Schema.sObjectType.Country_Product_Economy__c.isAccessible()) {
            return new List<Country_Product_Economy__c>();
        }

        List<Country_Product_Economy__c> records = [
            SELECT Id, Name, Country_Economy__c, Product_Economy__c, Product__c, Product_Code__c,
                   Sold_Domestic__c, Bought_Quantity__c, Thrown_To_Market__c, Actual_Sold_World__c,
                   Worldmarket_Pool__c, Intermediate_Consumption__c, Total_Supply_Pounds__c,
                   Actual_Supply_Pounds__c, Actual_Demand_Pounds__c, Import_Value__c,
                   Export_Value__c, Domestic_Sales_Value__c, GDP_Contribution__c,
                   Unique_Snapshot_Key__c, Product_Economy__r.Product_Code__c, Product_Economy__r.Price__c
            FROM Country_Product_Economy__c
            WHERE Country_Economy__r.Economy_Analysis__c = :analysisId
            LIMIT 50000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country_Product_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Province_Economy__c records for a given Country_Economy__c Id.
     * @param countryEconomyId Parent Country_Economy__c Id.
     * @return List of Province_Economy__c records.
     */
    public static List<Province_Economy__c> selectProvinceEconomies(Id countryEconomyId) {
        if (countryEconomyId == null || !Schema.sObjectType.Province_Economy__c.isAccessible()) {
            return new List<Province_Economy__c>();
        }

        List<Province_Economy__c> records = [
            SELECT Id, Name, Country_Economy__c, Province__c, Population__c, RGO_Production__c,
                   Unique_Snapshot_Key__c, Province__r.External_Province_Id__c
            FROM Province_Economy__c
            WHERE Country_Economy__c = :countryEconomyId
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Province_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Product_Economy__c records by a set of Product_Economy__c Ids into a Map.
     * @param productEconomyIds Set of Product_Economy__c Ids.
     * @return Map of Id -> Product_Economy__c.
     */
    public static Map<Id, Product_Economy__c> selectProductEconomyById(Set<Id> productEconomyIds) {
        if (productEconomyIds == null || productEconomyIds.isEmpty() || !Schema.sObjectType.Product_Economy__c.isAccessible()) {
            return new Map<Id, Product_Economy__c>();
        }

        List<Product_Economy__c> records = [
            SELECT Id, Name, Economy_Analysis__c, Product__c, Product_Code__c, Price__c,
                   Base_Price__c, Inflation_Percent__c, Total_World_Supply__c, Real_Demand__c,
                   Max_Demand__c, Overproduction_Percent__c, Unique_Snapshot_Key__c
            FROM Product_Economy__c
            WHERE Id IN :productEconomyIds
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return new Map<Id, Product_Economy__c>((List<Product_Economy__c>) decision.getRecords());
    }
}
