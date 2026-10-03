/**
 * @description Centralized, secure SOQL data selector for master Product__c records.
 * Enforces `with sharing` and applies `Security.stripInaccessible` for FLS compliance.
 */
public with sharing class ProductSelector {

    /**
     * @description Selects Product__c master records by a set of commodity codes (e.g., 'grain', 'iron').
     * @param codes Set of product codes.
     * @return List of Product__c records.
     */
    public static List<Product__c> selectByCode(Set<String> codes) {
        if (codes == null || codes.isEmpty() || !Schema.sObjectType.Product__c.isAccessible()) {
            return new List<Product__c>();
        }

        List<Product__c> records = [
            SELECT Id, Code__c, Base_Price__c
            FROM Product__c
            WHERE Code__c IN :codes
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Product__c>) decision.getRecords();
    }

    /**
     * @description Selects Product__c master records by a set of Record Ids.
     * @param ids Set of Product__c Ids.
     * @return List of Product__c records.
     */
    public static List<Product__c> selectById(Set<Id> ids) {
        if (ids == null || ids.isEmpty() || !Schema.sObjectType.Product__c.isAccessible()) {
            return new List<Product__c>();
        }

        List<Product__c> records = [
            SELECT Id, Code__c, Base_Price__c
            FROM Product__c
            WHERE Id IN :ids
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Product__c>) decision.getRecords();
    }

    /**
     * @description Selects all master Product__c records.
     * @return List of Product__c records.
     */
    public static List<Product__c> selectAll() {
        if (!Schema.sObjectType.Product__c.isAccessible()) {
            return new List<Product__c>();
        }

        List<Product__c> records = [
            SELECT Id, Code__c, Base_Price__c
            FROM Product__c
            ORDER BY Code__c ASC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Product__c>) decision.getRecords();
    }
}
