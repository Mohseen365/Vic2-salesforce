@IsTest
private class EconomyLdvValidationTest {

    @TestSetup
    static void setupMasterData() {
        Country__c countryMaster = new Country__c(Tag__c = 'TST', Name = 'Testland');
        insert countryMaster;

        Product__c productMaster = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert productMaster;
    }

    private static Economy_Analysis__c createTestAnalysis(String nameKey) {
        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Name = nameKey,
            Save_File_Name__c = nameKey,
            Unique_Snapshot_Key__c = nameKey,
            Import_Status__c = 'RECEIVED',
            Ingame_Date__c = Date.newInstance(1836, 1, 1)
        );
        insert analysis;
        return analysis;
    }

    private static void populateDataSet(Economy_Analysis__c analysis, Integer countryCount, Integer productCount) {
        Country__c countryMaster = [SELECT Id FROM Country__c WHERE Tag__c = 'TST' LIMIT 1];
        Product__c productMaster = [SELECT Id FROM Product__c WHERE Code__c = 'grain' LIMIT 1];

        List<Country_Economy__c> countries = new List<Country_Economy__c>();
        for (Integer i = 0; i < countryCount; i++) {
            String tag = 'C' + String.valueOf(i).padStart(3, '0');
            countries.add(new Country_Economy__c(
                Economy_Analysis__c = analysis.Id,
                Country__c = countryMaster.Id,
                Country_Tag__c = tag,
                Population__c = 1000000 + (i * 10000),
                Workforce__c = 250000 + (i * 2500),
                Employment__c = 240000 + (i * 2400),
                Gold_Income__c = 10.0,
                Unique_Snapshot_Key__c = analysis.Save_File_Name__c + '_' + tag
            ));
        }
        insert countries;

        List<Product_Economy__c> products = new List<Product_Economy__c>();
        for (Integer j = 0; j < productCount; j++) {
            String code = 'P' + String.valueOf(j).padStart(3, '0');
            products.add(new Product_Economy__c(
                Economy_Analysis__c = analysis.Id,
                Product__c = productMaster.Id,
                Product_Code__c = code,
                Price__c = 2.0 + (j * 0.1),
                Base_Price__c = 2.0,
                Total_World_Supply__c = 10000.0,
                Real_Demand__c = 8000.0,
                Max_Demand__c = 12000.0,
                Unique_Snapshot_Key__c = analysis.Save_File_Name__c + '_' + code
            ));
        }
        insert products;

        // Chunk DML insertions to respect Apex 10,000 DML row limit per operation
        List<Country_Product_Economy__c> chunk = new List<Country_Product_Economy__c>();
        for (Country_Economy__c c : countries) {
            for (Product_Economy__c p : products) {
                chunk.add(new Country_Product_Economy__c(
                    Country_Economy__c = c.Id,
                    Product_Economy__c = p.Id,
                    Product__c = productMaster.Id,
                    Product_Code__c = p.Product_Code__c,
                    Sold_Domestic__c = 50.0,
                    Bought_Quantity__c = 10.0,
                    Thrown_To_Market__c = 100.0,
                    Actual_Sold_World__c = 80.0,
                    Worldmarket_Pool__c = 5000.0,
                    Intermediate_Consumption__c = 5.0,
                    Unique_Snapshot_Key__c = c.Unique_Snapshot_Key__c + '_' + p.Product_Code__c
                ));

                if (chunk.size() == 5000) {
                    insert chunk;
                    chunk.clear();
                }
            }
        }
        if (!chunk.isEmpty()) {
            insert chunk;
        }
    }

    @IsTest
    static void testSmallTierLdvValidation() {
        // Small Tier: 5 countries x 5 products = 25 junctions
        Economy_Analysis__c analysis = createTestAnalysis('LDV_Small_Tier');
        populateDataSet(analysis, 5, 5);

        Test.startTest();
        EconomyAnalysisService.recalculateAnalysis(analysis.Id);
        Test.stopTest();

        System.assert(Limits.getDmlStatements() <= 150, 'Small Tier DML limit breached');
        System.assert(Limits.getQueries() <= 100, 'Small Tier SOQL limit breached');

        Economy_Analysis__c reloaded = [SELECT Id, Import_Status__c, Total_World_GDP__c FROM Economy_Analysis__c WHERE Id = :analysis.Id];
        System.assertEquals('COMPLETED', reloaded.Import_Status__c, 'Small Tier Analysis status should be COMPLETED');
        System.assert(reloaded.Total_World_GDP__c > 0, 'World GDP should be non-zero');
    }

    @IsTest
    static void testMediumTierLdvValidation() {
        // Medium Tier: 50 countries x 30 products = 1,500 junctions
        Economy_Analysis__c analysis = createTestAnalysis('LDV_Medium_Tier');
        populateDataSet(analysis, 50, 30);

        Test.startTest();
        EconomyAnalysisService.recalculateAnalysis(analysis.Id);
        Test.stopTest();

        System.assert(Limits.getDmlStatements() <= 150, 'Medium Tier DML limit breached');
        System.assert(Limits.getQueries() <= 100, 'Medium Tier SOQL limit breached');

        Economy_Analysis__c reloaded = [SELECT Id, Import_Status__c, Total_World_GDP__c FROM Economy_Analysis__c WHERE Id = :analysis.Id];
        System.assertEquals('COMPLETED', reloaded.Import_Status__c, 'Medium Tier Analysis status should be COMPLETED');
        System.assert(reloaded.Total_World_GDP__c > 0, 'World GDP should be non-zero');
    }

    @IsTest
    static void testLargeTierLdvValidation() {
        // Large Tier: 150 countries x 50 products = 7,500 junctions (chunked DML inserts)
        Economy_Analysis__c analysis = createTestAnalysis('LDV_Large_Tier');
        populateDataSet(analysis, 150, 50);

        Test.startTest();
        EconomyAnalysisService.recalculateAnalysis(analysis.Id);
        Test.stopTest();

        System.assert(Limits.getDmlStatements() <= 150, 'Large Tier DML limit breached: ' + Limits.getDmlStatements());
        System.assert(Limits.getQueries() <= 100, 'Large Tier SOQL limit breached: ' + Limits.getQueries());

        Economy_Analysis__c reloaded = [SELECT Id, Import_Status__c, Total_World_GDP__c FROM Economy_Analysis__c WHERE Id = :analysis.Id];
        System.assertEquals('COMPLETED', reloaded.Import_Status__c, 'Large Tier Analysis status should be COMPLETED');
        System.assert(reloaded.Total_World_GDP__c > 0, 'World GDP should be non-zero');
    }

    @IsTest
    static void testBatchImportLdvValidation() {
        // Test Batch Import execution path on LDV data
        Economy_Analysis__c analysis = createTestAnalysis('LDV_Batch_Tier');

        Test.startTest();
        EconomyImportBatch batch = new EconomyImportBatch(analysis.Id);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        Economy_Analysis__c reloaded = [SELECT Id, Import_Status__c FROM Economy_Analysis__c WHERE Id = :analysis.Id];
        System.assertEquals('COMPLETED', reloaded.Import_Status__c, 'Batch Analysis status should be COMPLETED');
    }
}
