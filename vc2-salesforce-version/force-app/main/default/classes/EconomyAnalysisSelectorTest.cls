@isTest
private class EconomyAnalysisSelectorTest {

    @isTest
    static void testSelectById_Null() {
        Test.startTest();
        Economy_Analysis__c res = EconomyAnalysisSelector.selectById(null);
        Test.stopTest();

        System.assertEquals(null, res, 'Null Id should return null');
    }

    @isTest
    static void testSelectAllRecent() {
        Test.startTest();
        List<Economy_Analysis__c> res1 = EconomyAnalysisSelector.selectAllRecent(5);
        List<Economy_Analysis__c> res2 = EconomyAnalysisSelector.selectAllRecent(0);
        List<Economy_Analysis__c> res3 = EconomyAnalysisSelector.selectAllRecent(null);
        Test.stopTest();

        System.assertNotEquals(null, res1, 'Result should not be null');
        System.assertNotEquals(null, res2, 'Result should not be null');
        System.assertNotEquals(null, res3, 'Result should not be null');
    }

    @isTest
    static void testSelectCountryEconomies_Null() {
        Test.startTest();
        List<Country_Economy__c> res = EconomyAnalysisSelector.selectCountryEconomies(null);
        Test.stopTest();

        System.assertEquals(0, res.size(), 'Null analysisId should return empty list');
    }

    @isTest
    static void testSelectProductEconomies_Null() {
        Test.startTest();
        List<Product_Economy__c> res = EconomyAnalysisSelector.selectProductEconomies(null);
        Test.stopTest();

        System.assertEquals(0, res.size(), 'Null analysisId should return empty list');
    }

    @isTest
    static void testSelectCountryProductEconomies_Null() {
        Test.startTest();
        List<Country_Product_Economy__c> res = EconomyAnalysisSelector.selectCountryProductEconomies(null);
        Test.stopTest();

        System.assertEquals(0, res.size(), 'Null countryEconomyId should return empty list');
    }

    @isTest
    static void testSelectCountryProductEconomiesByAnalysis_Null() {
        Test.startTest();
        List<Country_Product_Economy__c> res = EconomyAnalysisSelector.selectCountryProductEconomiesByAnalysis(null);
        Test.stopTest();

        System.assertEquals(0, res.size(), 'Null analysisId should return empty list');
    }

    @isTest
    static void testSelectProvinceEconomies_Null() {
        Test.startTest();
        List<Province_Economy__c> res = EconomyAnalysisSelector.selectProvinceEconomies(null);
        Test.stopTest();

        System.assertEquals(0, res.size(), 'Null countryEconomyId should return empty list');
    }

    @isTest
    static void testSelectProductEconomyById_NullAndEmpty() {
        Test.startTest();
        Map<Id, Product_Economy__c> res1 = EconomyAnalysisSelector.selectProductEconomyById(null);
        Map<Id, Product_Economy__c> res2 = EconomyAnalysisSelector.selectProductEconomyById(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, res1.size(), 'Null set should return empty map');
        System.assertEquals(0, res2.size(), 'Empty set should return empty map');
    }
}
