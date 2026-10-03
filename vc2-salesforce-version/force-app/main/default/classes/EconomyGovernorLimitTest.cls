@IsTest
private class EconomyGovernorLimitTest {

    @IsTest
    static void testRecalculateAnalysisGovernorLimitsSyntheticLdv() {
        // Create master records
        Country__c countryMaster = new Country__c(Tag__c = 'TST', Name = 'Testland');
        insert countryMaster;

        Product__c productMaster = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert productMaster;

        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Name = 'LDV Test Analysis',
            Save_File_Name__c = 'LDV_Test_Save',
            Unique_Snapshot_Key__c = 'LDV_Test_Save',
            Import_Status__c = 'RECEIVED'
        );
        insert analysis;

        // Construct synthetic LDV data: 50 countries x 10 products = 500 country-product records
        List<Country_Economy__c> countryList = new List<Country_Economy__c>();
        for (Integer i = 0; i < 50; i++) {
            String tag = 'C' + String.valueOf(i).padStart(3, '0');
            countryList.add(new Country_Economy__c(
                Economy_Analysis__c = analysis.Id,
                Country__c = countryMaster.Id,
                Country_Tag__c = tag,
                Population__c = 1000000 + (i * 10000),
                Workforce__c = 250000 + (i * 2500),
                Employment__c = 240000 + (i * 2400),
                Gold_Income__c = 50.0,
                Unique_Snapshot_Key__c = 'LDV_Test_Save_' + tag
            ));
        }
        insert countryList;

        List<Product_Economy__c> productList = new List<Product_Economy__c>();
        for (Integer j = 0; j < 10; j++) {
            String code = 'P' + String.valueOf(j).padStart(2, '0');
            productList.add(new Product_Economy__c(
                Economy_Analysis__c = analysis.Id,
                Product__c = productMaster.Id,
                Product_Code__c = code,
                Price__c = 2.5 + j,
                Base_Price__c = 2.0,
                Total_World_Supply__c = 10000.0,
                Real_Demand__c = 8000.0,
                Max_Demand__c = 12000.0,
                Unique_Snapshot_Key__c = 'LDV_Test_Save_' + code
            ));
        }
        insert productList;

        List<Country_Product_Economy__c> junctionList = new List<Country_Product_Economy__c>();
        for (Country_Economy__c c : countryList) {
            for (Product_Economy__c p : productList) {
                junctionList.add(new Country_Product_Economy__c(
                    Country_Economy__c = c.Id,
                    Product_Economy__c = p.Id,
                    Product__c = productMaster.Id,
                    Product_Code__c = p.Product_Code__c,
                    Sold_Domestic__c = 100.0,
                    Bought_Quantity__c = 20.0,
                    Thrown_To_Market__c = 150.0,
                    Actual_Sold_World__c = 120.0,
                    Worldmarket_Pool__c = 5000.0,
                    Intermediate_Consumption__c = 10.0,
                    Unique_Snapshot_Key__c = c.Unique_Snapshot_Key__c + '_' + p.Product_Code__c
                ));
            }
        }
        insert junctionList;

        // Measure limit budget during recalculateAnalysis
        Test.startTest();
        EconomyAnalysisService.recalculateAnalysis(analysis.Id);
        Test.stopTest();

        // Assert Limits
        System.assert(Limits.getDmlStatements() <= 150, 'DML Statements limit exceeded: ' + Limits.getDmlStatements());
        System.assert(Limits.getQueries() <= 100, 'SOQL Queries limit exceeded: ' + Limits.getQueries());

        // Verify analysis completed successfully
        Economy_Analysis__c reloaded = [SELECT Id, Import_Status__c, Total_World_GDP__c FROM Economy_Analysis__c WHERE Id = :analysis.Id];
        System.assertEquals('COMPLETED', reloaded.Import_Status__c, 'Analysis status should be COMPLETED after recalculation');
        System.assert(reloaded.Total_World_GDP__c > 0, 'Total World GDP should be calculated and greater than zero');
    }
}
