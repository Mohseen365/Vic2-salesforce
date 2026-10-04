@isTest
private class EconomyImportBatchTest {

    @isTest
    static void testBatchExecution() {
        Country__c masterCountry = new Country__c(Tag__c = 'PRU', Name = 'Prussia');
        insert masterCountry;

        Product__c masterProduct = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert masterProduct;

        State__c masterState = new State__c(State_Code__c = 'PRU_Silesia', Name = 'Silesia', Country__c = masterCountry.Id);
        insert masterState;

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

        State_Economy__c stateEcon = new State_Economy__c(
            Economy_Analysis__c = header.Id,
            Country_Economy__c = countryEcon.Id,
            State__c = masterState.Id,
            Population__c = 500000,
            Unique_Snapshot_Key__c = 'Batch_Test_Save_PRU_Silesia'
        );
        insert stateEcon;

        Province_Economy__c provEcon = new Province_Economy__c(
            Country_Economy__c = countryEcon.Id,
            Province__c = masterProvince.Id,
            Population__c = 50000,
            Unique_Snapshot_Key__c = 'Batch_Test_Save_42'
        );
        insert provEcon;

        List<Factory_Economy__c> factories = new List<Factory_Economy__c>{
            new Factory_Economy__c(
                Economy_Analysis__c = header.Id,
                Country_Economy__c = countryEcon.Id,
                State_Economy__c = stateEcon.Id,
                Product__c = masterProduct.Id,
                Building_Type__c = 'glass_factory',
                Occurrence_Index__c = 1,
                Level__c = 1,
                Employees__c = 1000,
                Revenue__c = 500.0,
                Input_Cost__c = 200.0,
                Wages_Paid__c = 100.0,
                Unique_Snapshot_Key__c = 'Batch_Test_Save_PRU_Silesia_glass_factory_1'
            )
        };

        List<Artisan_Economy__c> artisans = new List<Artisan_Economy__c>{
            new Artisan_Economy__c(
                Economy_Analysis__c = header.Id,
                Country_Economy__c = countryEcon.Id,
                Province_Economy__c = provEcon.Id,
                State_Economy__c = stateEcon.Id,
                Product__c = masterProduct.Id,
                Artisan_Type__c = 'fabric',
                Spending__c = 10.0,
                Income__c = 25.0,
                AGDP__c = 15.0,
                Production_Quantity__c = 2.976,
                Unique_Snapshot_Key__c = 'Batch_Test_Save_42_grain'
            )
        };

        Test.startTest();
        EconomyImportBatch batchJob = new EconomyImportBatch(header.Id, factories, artisans);
        Database.executeBatch(batchJob, 200);
        Test.stopTest();

        Economy_Analysis__c updatedHeader = [SELECT Id, Import_Status__c FROM Economy_Analysis__c WHERE Id = :header.Id];
        System.assertEquals('COMPLETED', updatedHeader.Import_Status__c);

        List<Factory_Economy__c> insertedFactories = [SELECT Id FROM Factory_Economy__c WHERE Economy_Analysis__c = :header.Id];
        System.assertEquals(1, insertedFactories.size());

        List<Artisan_Economy__c> insertedArtisans = [SELECT Id FROM Artisan_Economy__c WHERE Economy_Analysis__c = :header.Id];
        System.assertEquals(1, insertedArtisans.size());
    }
}
