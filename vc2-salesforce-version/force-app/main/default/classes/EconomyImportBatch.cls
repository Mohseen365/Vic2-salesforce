/**
 * @description Batch Apex framework for chunked processing of large Country x Product x Province snapshots.
 * Prevents DML and heap limit exceptions for Large Data Volumes (LDV) and completes by invoking EconomyAnalysisService.recalculateAnalysis.
 */
public with sharing class EconomyImportBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id analysisId;
    private List<Country_Product_Economy__c> junctionRecords;
    private List<Province_Economy__c> provinceRecords;
    private String errorMessage;

    public EconomyImportBatch(
        Id analysisId,
        List<Country_Product_Economy__c> junctionRecords,
        List<Province_Economy__c> provinceRecords
    ) {
        this.analysisId = analysisId;
        this.junctionRecords = (junctionRecords != null) ? junctionRecords : new List<Country_Product_Economy__c>();
        this.provinceRecords = (provinceRecords != null) ? provinceRecords : new List<Province_Economy__c>();
    }

    public List<sObject> start(Database.BatchableContext BC) {
        List<sObject> allRecords = new List<sObject>();
        allRecords.addAll((List<sObject>) this.junctionRecords);
        allRecords.addAll((List<sObject>) this.provinceRecords);
        return allRecords;
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        try {
            List<Country_Product_Economy__c> junctionsToUpsert = new List<Country_Product_Economy__c>();
            List<Province_Economy__c> provincesToUpsert = new List<Province_Economy__c>();

            for (sObject record : scope) {
                if (record instanceof Country_Product_Economy__c) {
                    junctionsToUpsert.add((Country_Product_Economy__c) record);
                } else if (record instanceof Province_Economy__c) {
                    provincesToUpsert.add((Province_Economy__c) record);
                }
            }

            if (!junctionsToUpsert.isEmpty() && Schema.sObjectType.Country_Product_Economy__c.isCreateable()) {
                upsert junctionsToUpsert Unique_Snapshot_Key__c;
            }

            if (!provincesToUpsert.isEmpty() && Schema.sObjectType.Province_Economy__c.isCreateable()) {
                upsert provincesToUpsert Unique_Snapshot_Key__c;
            }
        } catch (Exception ex) {
            this.errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
            if (this.analysisId != null && Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                update new Economy_Analysis__c(
                    Id = this.analysisId,
                    Import_Status__c = 'FAILED',
                    Import_Diagnostic_Message__c = this.errorMessage
                );
                EconomyImportService.publishImportEvent(this.analysisId, 'FAILED', this.errorMessage, null);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (this.analysisId != null && String.isBlank(this.errorMessage)) {
            try {
                // Hand off to recalculation engine
                EconomyAnalysisService.recalculateAnalysis(this.analysisId);
            } catch (Exception ex) {
                if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                    String diag = ex.getMessage() + '\n' + ex.getStackTraceString();
                    update new Economy_Analysis__c(
                        Id = this.analysisId,
                        Import_Status__c = 'FAILED',
                        Import_Diagnostic_Message__c = diag
                    );
                    EconomyImportService.publishImportEvent(this.analysisId, 'FAILED', diag, null);
                }
            }
        }
    }
}
