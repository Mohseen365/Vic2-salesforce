@isTest
private class EconomyImportBatchTest {

    @isTest
    static void testBatchExecution() {
        // Setup Analysis Header and Master Data
        Country__c masterCountry = new Country__c(Tag__c = 'PRU', Name = 'Prussia');
        insert masterCountry;

        Product__c masterProduct = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert masterProduct;

        Province__c masterProvince = new Province__c(External_Province_Id__c = '42', Country__c = masterCountry.Id);
        insert masterProvince;

        Economy_Analysis__c header = new Economy_Analysis__c(
            Name = 'Batch_Test_Save',
            Save_File_Name__c = 'Batch_Test_Save',
            Unique_Snapshot_Key__c = 'Batch_Test_Save',
            Ingame_Date__c = Date.today(),
            Import_Status__c = 'PROCESSING'
        );
        insert header;

        Country_Economy__c countryEcon = new Country_Economy__c(
            Economy_Analysis__c = header.Id,
            Country__c = masterCountry.Id,
            Country_Tag__c = 'PRU',
            Population__c = 1000000,
            Unique_Snapshot_Key__c = 'Batch_Test_Save_PRU'
        );
        insert countryEcon;

        Product_Economy__c prodEcon = new Product_Economy__c(
            Economy_Analysis__c = header.Id,
            Product__c = masterProduct.Id,
            Product_Code__c = 'grain',
            Price__c = 2.0,
            Unique_Snapshot_Key__c = 'Batch_Test_Save_grain'
        );
        insert prodEcon;

        List<Country_Product_Economy__c> junctions = new List<Country_Product_Economy__c>{
            new Country_Product_Economy__c(
                Country_Economy__c = countryEcon.Id,
                Product_Economy__c = prodEcon.Id,
                Product__c = masterProduct.Id,
                Product_Code__c = 'grain',
                Sold_Domestic__c = 100,
                Bought_Quantity__c = 10,
                Thrown_To_Market__c = 20,
                Actual_Sold_World__c = 15,
                Worldmarket_Pool__c = 100,
                Intermediate_Consumption__c = 0,
                Unique_Snapshot_Key__c = 'Batch_Test_Save_PRU_grain'
            )
        };

        List<Province_Economy__c> provinces = new List<Province_Economy__c>{
            new Province_Economy__c(
                Country_Economy__c = countryEcon.Id,
                Province__c = masterProvince.Id,
                Population__c = 50000,
                RGO_Production__c = 10.0,
                Unique_Snapshot_Key__c = 'Batch_Test_Save_42'
            )
        };

        Test.startTest();
        EconomyImportBatch batchJob = new EconomyImportBatch(header.Id, junctions, provinces);
        Database.executeBatch(batchJob, 200);
        Test.stopTest();

        // Verify Batch completion
        Economy_Analysis__c updatedHeader = [SELECT Id, Import_Status__c FROM Economy_Analysis__c WHERE Id = :header.Id];
        System.assertEquals('COMPLETED', updatedHeader.Import_Status__c, 'Batch execution should complete and transition status to COMPLETED.');

        List<Country_Product_Economy__c> insertedJunctions = [SELECT Id FROM Country_Product_Economy__c WHERE Country_Economy__c = :countryEcon.Id];
        System.assertEquals(1, insertedJunctions.size());

        List<Province_Economy__c> insertedProvinces = [SELECT Id FROM Province_Economy__c WHERE Country_Economy__c = :countryEcon.Id];
        System.assertEquals(1, insertedProvinces.size());
    }
}
