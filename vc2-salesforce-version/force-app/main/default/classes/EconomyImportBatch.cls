/**
 * @description Batch Apex framework for chunked processing of large Factory and Artisan snapshots (GATE-3).
 * Prevents DML and heap limit exceptions for Large Data Volumes (LDV) and completes by transitioning analysis status to COMPLETED.
 */
public with sharing class EconomyImportBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id analysisId;
    private List<Factory_Economy__c> factoryRecords;
    private List<Artisan_Economy__c> artisanRecords;
    private String errorMessage;

    public EconomyImportBatch(
        Id analysisId,
        List<Factory_Economy__c> factoryRecords,
        List<Artisan_Economy__c> artisanRecords
    ) {
        this.analysisId = analysisId;
        this.factoryRecords = (factoryRecords != null) ? factoryRecords : new List<Factory_Economy__c>();
        this.artisanRecords = (artisanRecords != null) ? artisanRecords : new List<Artisan_Economy__c>();
    }

    public List<sObject> start(Database.BatchableContext BC) {
        List<sObject> allRecords = new List<sObject>();
        allRecords.addAll((List<sObject>) this.factoryRecords);
        allRecords.addAll((List<sObject>) this.artisanRecords);
        return allRecords;
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        try {
            List<Factory_Economy__c> factoriesToUpsert = new List<Factory_Economy__c>();
            List<Artisan_Economy__c> artisansToUpsert = new List<Artisan_Economy__c>();

            for (sObject record : scope) {
                if (record instanceof Factory_Economy__c) {
                    factoriesToUpsert.add((Factory_Economy__c) record);
                } else if (record instanceof Artisan_Economy__c) {
                    artisansToUpsert.add((Artisan_Economy__c) record);
                }
            }

            if (!factoriesToUpsert.isEmpty() && Schema.sObjectType.Factory_Economy__c.isCreateable()) {
                upsert factoriesToUpsert Unique_Snapshot_Key__c;
            }

            if (!artisansToUpsert.isEmpty() && Schema.sObjectType.Artisan_Economy__c.isCreateable()) {
                upsert artisansToUpsert Unique_Snapshot_Key__c;
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
                if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                    update new Economy_Analysis__c(
                        Id = this.analysisId,
                        Import_Status__c = 'COMPLETED'
                    );
                }
                EconomyImportService.publishImportEvent(this.analysisId, 'COMPLETED', null, null);
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
