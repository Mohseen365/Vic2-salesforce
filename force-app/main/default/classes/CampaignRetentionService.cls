/**
 * @description Enterprise Data Storage & Retention Policy Manager (PLAT-D-008 / RSK-11).
 * Enforces the 5-campaign historical data retention limit per player/country tag.
 * Automatically prunes micro-level child snapshot records (provinces, country products, factories, artisans, states)
 * for campaigns beyond the 5 most recent per player, preserving top-level Economy_Analysis__c rollup history.
 */
public with sharing class CampaignRetentionService {

    public static final Integer MAX_RETAINED_CAMPAIGNS = 5;

    public class RetentionResult {
        public Integer playersProcessed = 0;
        public Integer campaignsEvaluated = 0;
        public Integer campaignsPruned = 0;
        public Integer recordsDeleted = 0;
    }

    /**
     * @description Bulkified evaluation of all Economy_Analysis__c records grouped by Player_Country_Tag__c.
     * Prunes child micro-level records for any campaign outside the top 5 most recent snapshots per player tag
     * in single bulkified SOQL/DML operations to ensure Apex governor limit compliance.
     * @return RetentionResult containing execution summary.
     */
    public static RetentionResult enforceRetentionPolicy() {
        RetentionResult result = new RetentionResult();

        if (!Schema.sObjectType.Economy_Analysis__c.isAccessible()) {
            return result;
        }

        List<Economy_Analysis__c> allAnalyses = [
            SELECT Id, Save_File_Name__c, Player_Country_Tag__c, Ingame_Date__c, CreatedDate
            FROM Economy_Analysis__c
            WHERE Player_Country_Tag__c != NULL
            ORDER BY Player_Country_Tag__c ASC, Ingame_Date__c DESC, CreatedDate DESC
        ];

        if (allAnalyses.isEmpty()) {
            return result;
        }

        Map<String, List<Economy_Analysis__c>> playerAnalysisMap = new Map<String, List<Economy_Analysis__c>>();
        for (Economy_Analysis__c a : allAnalyses) {
            String tag = a.Player_Country_Tag__c;
            if (!playerAnalysisMap.containsKey(tag)) {
                playerAnalysisMap.put(tag, new List<Economy_Analysis__c>());
            }
            playerAnalysisMap.get(tag).add(a);
        }

        Set<Id> staleAnalysisIds = new Set<Id>();
        result.playersProcessed = playerAnalysisMap.size();

        for (String tag : playerAnalysisMap.keySet()) {
            List<Economy_Analysis__c> playerList = playerAnalysisMap.get(tag);
            result.campaignsEvaluated += playerList.size();

            if (playerList.size() > MAX_RETAINED_CAMPAIGNS) {
                for (Integer i = MAX_RETAINED_CAMPAIGNS; i < playerList.size(); i++) {
                    staleAnalysisIds.add(playerList[i].Id);
                }
            }
        }

        result.campaignsPruned = staleAnalysisIds.size();

        if (!staleAnalysisIds.isEmpty()) {
            result.recordsDeleted = pruneMicroRecords(staleAnalysisIds);
        }

        return result;
    }

    /**
     * @description Enforces the 5-campaign retention policy for a specific player tag in a bulkified transaction.
     * @param playerTag Target Player_Country_Tag__c value.
     * @return RetentionResult for the target player tag.
     */
    public static RetentionResult enforceRetentionForPlayer(String playerTag) {
        RetentionResult result = new RetentionResult();
        if (String.isBlank(playerTag) || !Schema.sObjectType.Economy_Analysis__c.isAccessible()) {
            return result;
        }

        List<Economy_Analysis__c> analyses = [
            SELECT Id, Save_File_Name__c, Player_Country_Tag__c, Ingame_Date__c, CreatedDate
            FROM Economy_Analysis__c
            WHERE Player_Country_Tag__c = :playerTag
            ORDER BY Ingame_Date__c DESC, CreatedDate DESC
        ];

        result.playersProcessed = 1;
        result.campaignsEvaluated = analyses.size();

        if (analyses.size() <= MAX_RETAINED_CAMPAIGNS) {
            return result;
        }

        Set<Id> staleAnalysisIds = new Set<Id>();
        for (Integer i = MAX_RETAINED_CAMPAIGNS; i < analyses.size(); i++) {
            staleAnalysisIds.add(analyses[i].Id);
        }

        result.campaignsPruned = staleAnalysisIds.size();

        if (!staleAnalysisIds.isEmpty()) {
            result.recordsDeleted = pruneMicroRecords(staleAnalysisIds);
        }

        return result;
    }

    /**
     * @description Bulkified pruning of micro-level snapshot records across a set of stale analysis Ids.
     */
    private static Integer pruneMicroRecords(Set<Id> staleAnalysisIds) {
        Integer deletedCount = 0;

        if (Schema.sObjectType.Country_Product_Economy__c.isDeletable()) {
            List<Country_Product_Economy__c> cpList = [
                SELECT Id FROM Country_Product_Economy__c
                WHERE Country_Economy__r.Economy_Analysis__c IN :staleAnalysisIds
            ];
            if (!cpList.isEmpty()) {
                deletedCount += cpList.size();
                delete cpList;
            }
        }

        if (Schema.sObjectType.Province_Economy__c.isDeletable()) {
            List<Province_Economy__c> provList = [
                SELECT Id FROM Province_Economy__c
                WHERE Country_Economy__r.Economy_Analysis__c IN :staleAnalysisIds
            ];
            if (!provList.isEmpty()) {
                deletedCount += provList.size();
                delete provList;
            }
        }

        if (Schema.sObjectType.Factory_Economy__c.isDeletable()) {
            List<Factory_Economy__c> factList = [
                SELECT Id FROM Factory_Economy__c
                WHERE Economy_Analysis__c IN :staleAnalysisIds
            ];
            if (!factList.isEmpty()) {
                deletedCount += factList.size();
                delete factList;
            }
        }

        if (Schema.sObjectType.Artisan_Economy__c.isDeletable()) {
            List<Artisan_Economy__c> artList = [
                SELECT Id FROM Artisan_Economy__c
                WHERE Economy_Analysis__c IN :staleAnalysisIds
            ];
            if (!artList.isEmpty()) {
                deletedCount += artList.size();
                delete artList;
            }
        }

        if (Schema.sObjectType.State_Economy__c.isDeletable()) {
            List<State_Economy__c> stateList = [
                SELECT Id FROM State_Economy__c
                WHERE Economy_Analysis__c IN :staleAnalysisIds
            ];
            if (!stateList.isEmpty()) {
                deletedCount += stateList.size();
                delete stateList;
            }
        }

        return deletedCount;
    }
}
