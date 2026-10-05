@isTest
private class EconomyTrendServiceTest {

    @isTest
    static void testTrendMethodsWithNullAndEmptyInputs() {
        Test.startTest();
        WorldTrendDTO worldNull = EconomyAnalysisService.getWorldTrend(null);
        WorldTrendDTO worldEmpty = EconomyAnalysisService.getWorldTrend(new List<Id>());

        CountryTrendDTO countryNull = EconomyAnalysisService.getCountryTrend(null, null);
        CountryTrendDTO countryEmpty = EconomyAnalysisService.getCountryTrend(new Set<String>{'ENG'}, new List<Id>());

        ProductTrendDTO productNull = EconomyAnalysisService.getProductTrend(null, null);
        ProductTrendDTO productEmpty = EconomyAnalysisService.getProductTrend(new Set<String>{'grain'}, new List<Id>());

        WorldTrendDTO ctrlWorldNull = EconomyAnalysisController.getWorldTrend(null);
        CountryTrendDTO ctrlCountryNull = EconomyAnalysisController.getCountryTrend(null, null);
        ProductTrendDTO ctrlProductNull = EconomyAnalysisController.getProductTrend(null, null);
        Test.stopTest();

        System.assertNotEquals(null, worldNull, 'WorldTrendDTO should not be null');
        System.assertEquals(0, worldNull.points.size(), 'WorldTrendDTO points should be empty');
        System.assertEquals(0, worldEmpty.points.size(), 'WorldTrendDTO points should be empty');

        System.assertNotEquals(null, countryNull, 'CountryTrendDTO should not be null');
        System.assertEquals(0, countryNull.series.size(), 'CountryTrendDTO series should be empty');
        System.assertEquals(0, countryEmpty.series.size(), 'CountryTrendDTO series should be empty');

        System.assertNotEquals(null, productNull, 'ProductTrendDTO should not be null');
        System.assertEquals(0, productNull.series.size(), 'ProductTrendDTO series should be empty');
        System.assertEquals(0, productEmpty.series.size(), 'ProductTrendDTO series should be empty');

        System.assertNotEquals(null, ctrlWorldNull, 'Controller WorldTrendDTO should not be null');
        System.assertNotEquals(null, ctrlCountryNull, 'Controller CountryTrendDTO should not be null');
        System.assertNotEquals(null, ctrlProductNull, 'Controller ProductTrendDTO should not be null');
    }

    @isTest
    static void testTrendMethodsWithPopulatedMultiSaveData() {
        // Insert Master Records
        Country__c masterCountry = new Country__c(Tag__c = 'ENG', Name = 'United Kingdom');
        insert masterCountry;

        Product__c masterProduct = new Product__c(Code__c = 'grain', Base_Price__c = 10.0);
        insert masterProduct;

        // Insert 3 Analyses Snapshots (1840, 1845, 1850)
        List<Economy_Analysis__c> analyses = new List<Economy_Analysis__c>();
        for (Integer i = 0; i < 3; i++) {
            analyses.add(new Economy_Analysis__c(
                Save_File_Name__c = 'england_snap_' + i + '.v2',
                Ingame_Date__c = Date.newInstance(1840 + (i * 5), 1, 1),
                Total_World_Imports__c = 1000.0 * (i + 1),
                Total_World_Exports__c = 1100.0 * (i + 1),
                Import_Status__c = 'COMPLETED'
            ));
        }
        insert analyses;

        List<Id> analysisIds = new List<Id>();
        for (Economy_Analysis__c ea : analyses) {
            analysisIds.add(ea.Id);
        }

        // Insert Country Economies for each snapshot
        List<Country_Economy__c> countries = new List<Country_Economy__c>();
        for (Integer i = 0; i < 3; i++) {
            countries.add(new Country_Economy__c(
                Economy_Analysis__c = analyses[i].Id,
                Country__c = masterCountry.Id,
                Country_Tag__c = 'ENG',
                GDP__c = 500.0 * (i + 1),
                Population__c = 1000000,
                Total_Imports_Value__c = 200.0 * (i + 1),
                Total_Exports_Value__c = 250.0 * (i + 1),
                Unique_Snapshot_Key__c = 'england_snap_' + i + '.v2_ENG'
            ));
        }
        insert countries;

        // Insert Product Economies for each snapshot
        List<Product_Economy__c> products = new List<Product_Economy__c>();
        for (Integer i = 0; i < 3; i++) {
            products.add(new Product_Economy__c(
                Economy_Analysis__c = analyses[i].Id,
                Product__c = masterProduct.Id,
                Product_Code__c = 'grain',
                Price__c = 10.0 + i,
                Base_Price__c = 10.0,
                Total_World_Supply__c = 500.0 + (i * 50),
                Real_Demand__c = 450.0 + (i * 40),
                Unique_Snapshot_Key__c = 'england_snap_' + i + '.v2_grain'
            ));
        }
        insert products;

        Test.startTest();
        WorldTrendDTO worldTrend = EconomyAnalysisService.getWorldTrend(analysisIds);
        CountryTrendDTO countryTrend = EconomyAnalysisService.getCountryTrend(new Set<String>{'ENG'}, analysisIds);
        CountryTrendDTO countryTrendAll = EconomyAnalysisService.getCountryTrend(null, analysisIds);
        ProductTrendDTO productTrend = EconomyAnalysisService.getProductTrend(new Set<String>{'grain'}, analysisIds);
        ProductTrendDTO productTrendAll = EconomyAnalysisService.getProductTrend(null, analysisIds);

        WorldTrendDTO ctrlWorld = EconomyAnalysisController.getWorldTrend(analysisIds);
        CountryTrendDTO ctrlCountry = EconomyAnalysisController.getCountryTrend(new List<String>{'ENG'}, analysisIds);
        ProductTrendDTO ctrlProduct = EconomyAnalysisController.getProductTrend(new List<String>{'grain'}, analysisIds);
        Test.stopTest();

        // Assert World Trend
        System.assertEquals(3, worldTrend.points.size(), 'Should return 3 world trend points');
        System.assertEquals(Date.newInstance(1840, 1, 1), worldTrend.points[0].ingameDate, 'First point should be 1840');

        // Assert Country Trend
        System.assertEquals(1, countryTrend.series.size(), 'Should return 1 country series');
        System.assertEquals('ENG', countryTrend.series[0].countryTag, 'Tag should be ENG');
        System.assertEquals(3, countryTrend.series[0].points.size(), 'ENG series should have 3 points');
        System.assertEquals(500.0, countryTrend.series[0].points[0].gdp, '1840 GDP should be 500');

        System.assertEquals(1, countryTrendAll.series.size(), 'Unfiltered country trend should return 1 series');

        // Assert Product Trend
        System.assertEquals(1, productTrend.series.size(), 'Should return 1 product series');
        System.assertEquals('grain', productTrend.series[0].productCode, 'Product code should be grain');
        System.assertEquals(3, productTrend.series[0].points.size(), 'grain series should have 3 points');
        System.assertEquals(10.0, productTrend.series[0].points[0].price, '1840 price should be 10');

        System.assertEquals(1, productTrendAll.series.size(), 'Unfiltered product trend should return 1 series');

        // Assert Controller calls
        System.assertEquals(3, ctrlWorld.points.size(), 'Controller world trend points count should match');
        System.assertEquals(1, ctrlCountry.series.size(), 'Controller country trend series count should match');
        System.assertEquals(1, ctrlProduct.series.size(), 'Controller product trend series count should match');
    }

    @isTest
    static void testAnalysisCappingLogicWithMoreThan12Ids() {
        List<Id> fakeIds = new List<Id>();
        for (Integer i = 0; i < 15; i++) {
            // Dummy valid 18-char SObject Id format
            fakeIds.add('a00000000000' + String.valueOf(100000 + i));
        }

        Test.startTest();
        List<Economy_Analysis__c> worldResult = EconomyAnalysisSelector.selectWorldTrend(fakeIds);
        List<Country_Economy__c> countryResult = EconomyAnalysisSelector.selectCountryTrend(new Set<String>{'ENG'}, fakeIds);
        List<Product_Economy__c> productResult = EconomyAnalysisSelector.selectProductTrend(new Set<String>{'grain'}, fakeIds);
        Test.stopTest();

        System.assertEquals(0, worldResult.size(), 'Selector with non-existent capped IDs should return empty list without error');
        System.assertEquals(0, countryResult.size(), 'Selector with non-existent capped IDs should return empty list without error');
        System.assertEquals(0, productResult.size(), 'Selector with non-existent capped IDs should return empty list without error');
    }
}
