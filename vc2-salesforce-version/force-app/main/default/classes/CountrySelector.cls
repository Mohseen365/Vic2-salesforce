/**
 * @description Centralized, secure SOQL data selector for master Country__c records.
 * Enforces `with sharing` and applies `Security.stripInaccessible` for FLS compliance.
 */
public with sharing class CountrySelector {

    /**
     * @description Selects Country__c master records by a set of tags (e.g., 'ENG', 'USA').
     * @param tags Set of country tags.
     * @return List of Country__c records.
     */
    public static List<Country__c> selectByTag(Set<String> tags) {
        if (tags == null || tags.isEmpty() || !Schema.sObjectType.Country__c.isAccessible()) {
            return new List<Country__c>();
        }

        List<Country__c> records = [
            SELECT Id, Tag__c, Flag_URL__c
            FROM Country__c
            WHERE Tag__c IN :tags
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country__c>) decision.getRecords();
    }

    /**
     * @description Selects Country__c master records by a set of Record Ids.
     * @param ids Set of Country__c Ids.
     * @return List of Country__c records.
     */
    public static List<Country__c> selectById(Set<Id> ids) {
        if (ids == null || ids.isEmpty() || !Schema.sObjectType.Country__c.isAccessible()) {
            return new List<Country__c>();
        }

        List<Country__c> records = [
            SELECT Id, Tag__c, Flag_URL__c
            FROM Country__c
            WHERE Id IN :ids
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country__c>) decision.getRecords();
    }

    /**
     * @description Selects all master Country__c records.
     * @return List of Country__c records.
     */
    public static List<Country__c> selectAll() {
        if (!Schema.sObjectType.Country__c.isAccessible()) {
            return new List<Country__c>();
        }

        List<Country__c> records = [
            SELECT Id, Tag__c, Flag_URL__c
            FROM Country__c
            ORDER BY Tag__c ASC
            LIMIT 5000
        ];

        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
        return (List<Country__c>) decision.getRecords();
    }
}
