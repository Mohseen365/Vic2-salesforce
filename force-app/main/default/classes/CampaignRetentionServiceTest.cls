@IsTest
private class CampaignRetentionServiceTest {

    @IsTest
    static void testRetentionPolicyEnforcement() {
        Country__c masterCountry = new Country__c(Tag__c = 'EGY', Name = 'Egypt');
        insert masterCountry;

        Product__c masterProduct = new Product__c(Code__c = 'grain', Name = 'Grain', Base_Price__c = 2.0);
        insert masterProduct;

        String playerTag = 'EGY';
        List<Economy_Analysis__c> analyses = new List<Economy_Analysis__c>();
        for (Integer i = 1; i <= 7; i++) {
            analyses.add(new Economy_Analysis__c(
                Name = 'EGY Campaign Snap ' + i,
                Save_File_Name__c = 'egypt_snap_' + i,
                Unique_Snapshot_Key__c = 'egypt_snap_' + i,
                Player_Country_Tag__c = playerTag,
                Import_Status__c = 'COMPLETED',
                Ingame_Date__c = Date.newInstance(1836 + i, 1, 1)
            ));
        }
        insert analyses;

        // Create country economies & factories for all 7 snapshots
        List<Country_Economy__c> countryEcons = new List<Country_Economy__c>();
        List<Factory_Economy__c> factories = new List<Factory_Economy__c>();
        for (Economy_Analysis__c a : analyses) {
            Country_Economy__c ce = new Country_Economy__c(
                Economy_Analysis__c = a.Id,
                Country__c = masterCountry.Id,
                Country_Tag__c = playerTag,
                Population__c = 100000,
                Unique_Snapshot_Key__c = a.Save_File_Name__c + '_' + playerTag
            );
            countryEcons.add(ce);

            factories.add(new Factory_Economy__c(
                Economy_Analysis__c = a.Id,
                Product__c = masterProduct.Id,
                Employees__c = 500,
                Profit__c = 10.0,
                Revenue__c = 20.0,
                Unique_Snapshot_Key__c = a.Save_File_Name__c + '_fact_1'
            ));
        }
        insert countryEcons;
        insert factories;

        Test.startTest();
        CampaignRetentionService.RetentionResult res = CampaignRetentionService.enforceRetentionPolicy();
        Test.stopTest();

        System.assertEquals(1, res.playersProcessed, 'Should process 1 player tag');
        System.assertEquals(7, res.campaignsEvaluated, 'Should evaluate 7 campaigns');
        System.assertEquals(2, res.campaignsPruned, 'Should prune micro-records for 2 oldest campaigns');
        System.assertEquals(2, res.recordsDeleted, 'Should delete 2 stale factory records');

        // Confirm 7 top-level Economy_Analysis__c records remain
        List<Economy_Analysis__c> remainingAnalyses = [SELECT Id FROM Economy_Analysis__c WHERE Player_Country_Tag__c = :playerTag];
        System.assertEquals(7, remainingAnalyses.size(), 'Top-level Economy_Analysis__c rollups must be preserved');

        // Confirm oldest 2 campaigns (1837 and 1838) lost factory records
        Set<Id> oldestIds = new Set<Id>{ analyses[0].Id, analyses[1].Id };
        List<Factory_Economy__c> prunedFactories = [SELECT Id FROM Factory_Economy__c WHERE Economy_Analysis__c IN :oldestIds];
        System.assertEquals(0, prunedFactories.size(), 'Oldest 2 campaigns micro-records should be pruned');

        // Confirm newest 5 campaigns retained factory records
        Set<Id> newestIds = new Set<Id>{ analyses[2].Id, analyses[3].Id, analyses[4].Id, analyses[5].Id, analyses[6].Id };
        List<Factory_Economy__c> retainedFactories = [SELECT Id FROM Factory_Economy__c WHERE Economy_Analysis__c IN :newestIds];
        System.assertEquals(5, retainedFactories.size(), 'Newest 5 campaigns micro-records should be retained');
    }
}
