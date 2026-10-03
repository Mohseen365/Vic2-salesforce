@isTest
private class CountrySelectorTest {

    @isTest
    static void testSelectByTag_NullAndEmpty() {
        Test.startTest();
        List<Country__c> res1 = CountrySelector.selectByTag(null);
        List<Country__c> res2 = CountrySelector.selectByTag(new Set<String>());
        List<Country__c> res3 = CountrySelector.selectByTag(new Set<String>{ 'NONEXISTENT' });
        Test.stopTest();

        System.assertEquals(0, res1.size(), 'Null tag set should return empty list');
        System.assertEquals(0, res2.size(), 'Empty tag set should return empty list');
        System.assertEquals(0, res3.size(), 'Nonexistent tag set should return empty list');
    }

    @isTest
    static void testSelectById_NullAndEmpty() {
        Test.startTest();
        List<Country__c> res1 = CountrySelector.selectById(null);
        List<Country__c> res2 = CountrySelector.selectById(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, res1.size(), 'Null Id set should return empty list');
        System.assertEquals(0, res2.size(), 'Empty Id set should return empty list');
    }

    @isTest
    static void testSelectAll() {
        Test.startTest();
        List<Country__c> res = CountrySelector.selectAll();
        Test.stopTest();

        System.assertNotEquals(null, res, 'Result should not be null');
    }
}
