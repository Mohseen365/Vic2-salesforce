/**
 * @description Centralized, secure SOQL data selector for Economy_Analysis__c and related snapshot SObjects.
 * Enforces `with sharing` and applies `Security.stripInaccessible` for FLS compliance.
 */
public with sharing class EconomyAnalysisSelector {

    private static List<Id> capAnalysisIds(List<Id> analysisIds) {
        if (analysisIds == null || analysisIds.isEmpty()) {
            return new List<Id>();
        }
        List<Id> capped = new List<Id>();
        for (Integer i = 0; i < Math.min(analysisIds.size(), 12); i++) {
            if (analysisIds[i] != null) {
                capped.add(analysisIds[i]);
            }
        }
        return capped;
    }

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
                   Core_Population__c, Colony_Population__c,
                   Workforce__c, Employment__c, Workforce_RGO__c, Employment_RGO__c,
                   Workforce_Factory__c, Employment_Factory__c, GDP__c, GDP_Rank__c,
                   GDP_Per_Capita__c, GDP_Share_Percent__c, Unemployment_Rate__c,
                   Unemployment_Rate_RGO__c, Unemployment_Rate_Factory__c,
                   Total_Imports_Value__c, Total_Exports_Value__c, Gold_Income__c,
                   Factory_GDP__c, Province_GDP__c, Artisan_GDP__c,
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
                   Unique_Snapshot_Key__c, Product_Economy__r.Product_Code__c, Product_Economy__r.Price__c,
                   Country_Economy__r.Country_Tag__c, Country_Economy__r.Country__r.Name
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
                   Unique_Snapshot_Key__c, Product_Economy__r.Product_Code__c, Product_Economy__r.Price__c,
                   Country_Economy__r.Country_Tag__c, Country_Economy__r.Country__r.Name
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
                   Colony__c, RGO_Income__c, RGO_GDP__c, Artisan_Spending__c, Artisan_Income__c, Artisan_GDP__c,
                   Unique_Snapshot_Key__c, Province__r.External_Province_Id__c, Province__r.Name
            FROM Province_Economy__c
            WHERE Country_Economy__c = :countryEconomyId
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Province_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects State_Economy__c records for a given Economy_Analysis__c Id.
     * @param analysisId Parent Economy_Analysis__c Id.
     * @return List of State_Economy__c records.
     */
    public static List<State_Economy__c> selectStateEconomies(Id analysisId) {
        if (analysisId == null || !Schema.sObjectType.State_Economy__c.isAccessible()) {
            return new List<State_Economy__c>();
        }

        List<State_Economy__c> records = [
            SELECT Id, Name, Economy_Analysis__c, Country_Economy__c, State__c, Population__c,
                   GDP__c, GDP_Per_Capita__c, GDP_Rank__c, RGO_Income__c, PGDP__c, AGDP__c, FGDP__c,
                   Factory_Employees__c, Factory_Revenue__c, Factory_Profit__c, Unique_Snapshot_Key__c,
                   State__r.State_Code__c, State__r.Name, Country_Economy__r.Country_Tag__c
            FROM State_Economy__c
            WHERE Economy_Analysis__c = :analysisId
            ORDER BY GDP__c DESC, State__r.State_Code__c ASC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<State_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Factory_Economy__c records for a given State_Economy__c Id.
     * @param stateEconomyId Parent State_Economy__c Id.
     * @return List of Factory_Economy__c records.
     */
    public static List<Factory_Economy__c> selectFactoryEconomies(Id stateEconomyId) {
        if (stateEconomyId == null || !Schema.sObjectType.Factory_Economy__c.isAccessible()) {
            return new List<Factory_Economy__c>();
        }

        List<Factory_Economy__c> records = [
            SELECT Id, Name, Economy_Analysis__c, Country_Economy__c, State_Economy__c, Product__c,
                   Building_Type__c, Occurrence_Index__c, Level__c, Employees__c, Output_Quantity__c,
                   Unsold_Quantity__c, Capital_Reserves__c, Revenue__c, Input_Cost__c, Wages_Paid__c,
                   Profit__c, Factory_GDP__c, Productivity__c, Average_Wage__c, Profit_Rank__c,
                   Unique_Snapshot_Key__c
            FROM Factory_Economy__c
            WHERE State_Economy__c = :stateEconomyId
            ORDER BY Profit__c DESC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Factory_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Artisan_Economy__c records for a given Province_Economy__c Id.
     * @param provinceEconomyId Parent Province_Economy__c Id.
     * @return List of Artisan_Economy__c records.
     */
    public static List<Artisan_Economy__c> selectArtisanEconomies(Id provinceEconomyId) {
        if (provinceEconomyId == null || !Schema.sObjectType.Artisan_Economy__c.isAccessible()) {
            return new List<Artisan_Economy__c>();
        }

        List<Artisan_Economy__c> records = [
            SELECT Id, Name, Economy_Analysis__c, Country_Economy__c, Province_Economy__c, State_Economy__c,
                   Product__c, Artisan_Type__c, Spending__c, Income__c, AGDP__c, Production_Quantity__c,
                   Unique_Snapshot_Key__c, Province_Economy__r.Province__r.External_Province_Id__c,
                   Province_Economy__r.Province__r.Name, Country_Economy__r.Country_Tag__c,
                   State_Economy__r.State__r.State_Code__c
            FROM Artisan_Economy__c
            WHERE Province_Economy__c = :provinceEconomyId
            ORDER BY AGDP__c DESC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Artisan_Economy__c>) decision.getRecords();
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

    /**
     * @description Selects Economy_Analysis__c world trends across multiple snapshot Ids.
     * LDV Budget: Capped at 12 analysis Ids per request.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param analysisIds List of Economy_Analysis__c Ids.
     * @return List of Economy_Analysis__c records.
     */
    public static List<Economy_Analysis__c> selectWorldTrend(List<Id> analysisIds) {
        if (!Schema.sObjectType.Economy_Analysis__c.isAccessible()) {
            return new List<Economy_Analysis__c>();
        }
        List<Id> cappedIds = capAnalysisIds(analysisIds);
        if (cappedIds.isEmpty()) {
            return new List<Economy_Analysis__c>();
        }

        List<Economy_Analysis__c> records = [
            SELECT Id, Name, Save_File_Name__c, Source_Save_File_Name__c, Ingame_Date__c,
                   Analysis_Timestamp__c, Total_World_GDP__c, Total_World_Population__c,
                   Total_World_Imports__c, Total_World_Exports__c
            FROM Economy_Analysis__c
            WHERE Id IN :cappedIds
            ORDER BY Ingame_Date__c ASC, Analysis_Timestamp__c ASC
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Economy_Analysis__c>) decision.getRecords();
    }

    /**
     * @description Selects Country_Economy__c trends across multiple snapshot Ids.
     * LDV Budget: Capped at 12 analysis Ids per request.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param countryTags Set of country tags to filter by (optional).
     * @param analysisIds List of Economy_Analysis__c Ids.
     * @return List of Country_Economy__c records.
     */
    public static List<Country_Economy__c> selectCountryTrend(Set<String> countryTags, List<Id> analysisIds) {
        if (!Schema.sObjectType.Country_Economy__c.isAccessible()) {
            return new List<Country_Economy__c>();
        }
        List<Id> cappedIds = capAnalysisIds(analysisIds);
        if (cappedIds.isEmpty()) {
            return new List<Country_Economy__c>();
        }

        List<Country_Economy__c> records;
        if (countryTags != null && !countryTags.isEmpty()) {
            records = [
                SELECT Id, Name, Economy_Analysis__c, Country_Tag__c, GDP__c, GDP_Per_Capita__c,
                       GDP_Rank__c, Total_Imports_Value__c, Total_Exports_Value__c,
                       Economy_Analysis__r.Ingame_Date__c, Country__r.Tag__c, Country__r.Name
                FROM Country_Economy__c
                WHERE Economy_Analysis__c IN :cappedIds AND Country_Tag__c IN :countryTags
                ORDER BY Economy_Analysis__r.Ingame_Date__c ASC, Country_Tag__c ASC
                LIMIT 5000
            ];
        } else {
            records = [
                SELECT Id, Name, Economy_Analysis__c, Country_Tag__c, GDP__c, GDP_Per_Capita__c,
                       GDP_Rank__c, Total_Imports_Value__c, Total_Exports_Value__c,
                       Economy_Analysis__r.Ingame_Date__c, Country__r.Tag__c, Country__r.Name
                FROM Country_Economy__c
                WHERE Economy_Analysis__c IN :cappedIds
                ORDER BY Economy_Analysis__r.Ingame_Date__c ASC, Country_Tag__c ASC
                LIMIT 5000
            ];
        }

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country_Economy__c>) decision.getRecords();
    }

    /**
     * @description Selects Product_Economy__c trends across multiple snapshot Ids.
     * LDV Budget: Capped at 12 analysis Ids per request.
     * Out of Original Audit Scope — Enhancement Track A.
     * @param productCodes Set of product codes to filter by (optional).
     * @param analysisIds List of Economy_Analysis__c Ids.
     * @return List of Product_Economy__c records.
     */
    public static List<Product_Economy__c> selectProductTrend(Set<String> productCodes, List<Id> analysisIds) {
        if (!Schema.sObjectType.Product_Economy__c.isAccessible()) {
            return new List<Product_Economy__c>();
        }
        List<Id> cappedIds = capAnalysisIds(analysisIds);
        if (cappedIds.isEmpty()) {
            return new List<Product_Economy__c>();
        }

        List<Product_Economy__c> records;
        if (productCodes != null && !productCodes.isEmpty()) {
            records = [
                SELECT Id, Name, Economy_Analysis__c, Product_Code__c, Price__c, Base_Price__c,
                       Total_World_Supply__c, Real_Demand__c, Max_Demand__c, Inflation_Percent__c,
                       Overproduction_Percent__c, Economy_Analysis__r.Ingame_Date__c, Product__r.Code__c
                FROM Product_Economy__c
                WHERE Economy_Analysis__c IN :cappedIds AND Product_Code__c IN :productCodes
                ORDER BY Economy_Analysis__r.Ingame_Date__c ASC, Product_Code__c ASC
                LIMIT 5000
            ];
        } else {
            records = [
                SELECT Id, Name, Economy_Analysis__c, Product_Code__c, Price__c, Base_Price__c,
                       Total_World_Supply__c, Real_Demand__c, Max_Demand__c, Inflation_Percent__c,
                       Overproduction_Percent__c, Economy_Analysis__r.Ingame_Date__c, Product__r.Code__c
                FROM Product_Economy__c
                WHERE Economy_Analysis__c IN :cappedIds
                ORDER BY Economy_Analysis__r.Ingame_Date__c ASC, Product_Code__c ASC
                LIMIT 5000
            ];
        }

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Product_Economy__c>) decision.getRecords();
    }
}
