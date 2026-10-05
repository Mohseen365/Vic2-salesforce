@isTest
private class ProductSelectorTest {

    @isTest
    static void testSelectByCode_NullAndEmpty() {
        Test.startTest();
        List<Product__c> res1 = ProductSelector.selectByCode(null);
        List<Product__c> res2 = ProductSelector.selectByCode(new Set<String>());
        List<Product__c> res3 = ProductSelector.selectByCode(new Set<String>{ 'NONEXISTENT' });
        Test.stopTest();

        System.assertEquals(0, res1.size(), 'Null code set should return empty list');
        System.assertEquals(0, res2.size(), 'Empty code set should return empty list');
        System.assertEquals(0, res3.size(), 'Nonexistent code set should return empty list');
    }

    @isTest
    static void testSelectById_NullAndEmpty() {
        Test.startTest();
        List<Product__c> res1 = ProductSelector.selectById(null);
        List<Product__c> res2 = ProductSelector.selectById(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, res1.size(), 'Null Id set should return empty list');
        System.assertEquals(0, res2.size(), 'Empty Id set should return empty list');
    }

    @isTest
    static void testSelectAll() {
        Test.startTest();
        List<Product__c> res = ProductSelector.selectAll();
        Test.stopTest();

        System.assertNotEquals(null, res, 'Result should not be null');
    }
}
