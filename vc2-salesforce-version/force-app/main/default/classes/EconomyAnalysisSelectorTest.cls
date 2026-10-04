@isTest
private class EconomyAnalysisSelectorTest {

    @testSetup
    static void setupData() {
        Economy_Analysis__c header = new Economy_Analysis__c(
            Name = 'Test Save',
            Save_File_Name__c = 'test_save.v2',
            Source_Save_File_Name__c = 'test_save.v2',
            Ingame_Date__c = Date.newInstance(1836, 1, 1),
            Analysis_Timestamp__c = System.now(),
            Player_Country_Tag__c = 'TUR',
            Import_Status__c = 'COMPLETED'
        );
        insert header;

        Country__c cTur = new Country__c(Tag__c = 'TUR', Name = 'Ottoman Empire');
        insert cTur;

        Country_Economy__c ce = new Country_Economy__c(
            Economy_Analysis__c = header.Id,
            Country__c = cTur.Id,
            Country_Tag__c = 'TUR',
            GDP__c = 100000.0
        );
        insert ce;

        Product__c pGrain = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert pGrain;

        Product_Economy__c pe = new Product_Economy__c(
            Economy_Analysis__c = header.Id,
            Product__c = pGrain.Id,
            Product_Code__c = 'grain',
            Price__c = 2.5
        );
        insert pe;

        State__c st = new State__c(State_Code__c = 'TUR_blank', Name = 'blank', Country__c = cTur.Id);
        insert st;

        State_Economy__c se = new State_Economy__c(
            Economy_Analysis__c = header.Id,
            Country_Economy__c = ce.Id,
            State__c = st.Id,
            Population__c = 100000,
            GDP__c = 50000.0,
            Unique_Snapshot_Key__c = 'test_save.v2_TUR_blank'
        );
        insert se;

        Province__c prov = new Province__c(External_Province_Id__c = '674', Country__c = cTur.Id);
        insert prov;

        Province_Economy__c prove = new Province_Economy__c(
            Country_Economy__c = ce.Id,
            Province__c = prov.Id,
            Population__c = 43319,
            RGO_Production__c = 7.43,
            Unique_Snapshot_Key__c = 'test_save.v2_674'
        );
        insert prove;

        Factory_Economy__c fe = new Factory_Economy__c(
            Economy_Analysis__c = header.Id,
            Country_Economy__c = ce.Id,
            State_Economy__c = se.Id,
            Product__c = pGrain.Id,
            Building_Type__c = 'ammunition_factory',
            Occurrence_Index__c = 1,
            Level__c = 1,
            Employees__c = 1000,
            Profit__c = 500.0,
            Unique_Snapshot_Key__c = 'test_save.v2_TUR_blank_ammunition_factory_1'
        );
        insert fe;

        Artisan_Economy__c ae = new Artisan_Economy__c(
            Economy_Analysis__c = header.Id,
            Country_Economy__c = ce.Id,
            Province_Economy__c = prove.Id,
            State_Economy__c = se.Id,
            Product__c = pGrain.Id,
            Artisan_Type__c = 'grain',
            AGDP__c = 100.0,
            Unique_Snapshot_Key__c = 'test_save.v2_674_grain'
        );
        insert ae;
    }

    @isTest
    static void testSelectById() {
        Economy_Analysis__c header = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Test.startTest();
        Economy_Analysis__c res = EconomyAnalysisSelector.selectById(header.Id);
        Economy_Analysis__c resNull = EconomyAnalysisSelector.selectById(null);
        Test.stopTest();

        System.assertNotEquals(null, res);
        System.assertEquals('test_save.v2', res.Save_File_Name__c);
        System.assertEquals(null, resNull);
    }

    @isTest
    static void testSelectAllRecent() {
        Test.startTest();
        List<Economy_Analysis__c> res1 = EconomyAnalysisSelector.selectAllRecent(5);
        List<Economy_Analysis__c> res2 = EconomyAnalysisSelector.selectAllRecent(0);
        List<Economy_Analysis__c> res3 = EconomyAnalysisSelector.selectAllRecent(null);
        Test.stopTest();

        System.assertEquals(1, res1.size());
        System.assertEquals(1, res2.size());
        System.assertEquals(1, res3.size());
    }

    @isTest
    static void testSelectStateEconomies() {
        Economy_Analysis__c header = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Test.startTest();
        List<State_Economy__c> states = EconomyAnalysisSelector.selectStateEconomies(header.Id);
        List<State_Economy__c> statesNull = EconomyAnalysisSelector.selectStateEconomies(null);
        Test.stopTest();

        System.assertEquals(1, states.size());
        System.assertEquals(0, statesNull.size());
    }

    @isTest
    static void testSelectFactoryEconomies() {
        State_Economy__c se = [SELECT Id FROM State_Economy__c LIMIT 1];
        Test.startTest();
        List<Factory_Economy__c> factories = EconomyAnalysisSelector.selectFactoryEconomies(se.Id);
        List<Factory_Economy__c> factoriesNull = EconomyAnalysisSelector.selectFactoryEconomies(null);
        Test.stopTest();

        System.assertEquals(1, factories.size());
        System.assertEquals(0, factoriesNull.size());
    }

    @isTest
    static void testSelectArtisanEconomies() {
        Province_Economy__c prove = [SELECT Id FROM Province_Economy__c LIMIT 1];
        Test.startTest();
        List<Artisan_Economy__c> artisans = EconomyAnalysisSelector.selectArtisanEconomies(prove.Id);
        List<Artisan_Economy__c> artisansNull = EconomyAnalysisSelector.selectArtisanEconomies(null);
        Test.stopTest();

        System.assertEquals(1, artisans.size());
        System.assertEquals(0, artisansNull.size());
    }

    @isTest
    static void testSelectCountryProductEconomiesByProduct() {
        Product_Economy__c pe = [SELECT Id FROM Product_Economy__c LIMIT 1];
        Test.startTest();
        List<Country_Product_Economy__c> cpesNull = EconomyAnalysisSelector.selectCountryProductEconomiesByProduct(null);
        List<Country_Product_Economy__c> cpes = EconomyAnalysisSelector.selectCountryProductEconomiesByProduct(pe.Id);
        Test.stopTest();

        System.assertEquals(0, cpesNull.size());
        System.assertEquals(0, cpes.size());
    }

    @isTest
    static void testSelectProductEconomyById() {
        Product_Economy__c pe = [SELECT Id FROM Product_Economy__c LIMIT 1];
        Test.startTest();
        Map<Id, Product_Economy__c> res1 = EconomyAnalysisSelector.selectProductEconomyById(null);
        Map<Id, Product_Economy__c> res2 = EconomyAnalysisSelector.selectProductEconomyById(new Set<Id>());
        Map<Id, Product_Economy__c> res3 = EconomyAnalysisSelector.selectProductEconomyById(new Set<Id>{ pe.Id });
        Test.stopTest();

        System.assertEquals(0, res1.size());
        System.assertEquals(0, res2.size());
        System.assertEquals(1, res3.size());
    }

    @isTest
    static void testSelectTrends() {
        Economy_Analysis__c header = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Test.startTest();
        List<Economy_Analysis__c> resWorld = EconomyAnalysisSelector.selectWorldTrend(new List<Id>{ header.Id });
        List<Country_Economy__c> resCountry = EconomyAnalysisSelector.selectCountryTrend(new Set<String>{ 'TUR' }, new List<Id>{ header.Id });
        List<Product_Economy__c> resProduct = EconomyAnalysisSelector.selectProductTrend(new Set<String>{ 'grain' }, new List<Id>{ header.Id });
        Test.stopTest();

        System.assertEquals(1, resWorld.size());
        System.assertEquals(1, resCountry.size());
        System.assertEquals(1, resProduct.size());
    }
}
