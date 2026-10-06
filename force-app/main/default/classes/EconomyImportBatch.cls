/**
 * @description Batch Apex framework for chunked processing of large Country x Product x Province snapshots
 * and large Factory and Artisan snapshots (GATE-3).
 * Prevents DML and heap limit exceptions for Large Data Volumes (LDV) and orders records by parent ID
 * to prevent UNABLE_TO_LOCK_ROW master-detail row locking contention.
 */
public with sharing class EconomyImportBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id analysisId;
    private Id importRunId;

    private List<Factory_Economy__c> factoryRecords;
    private List<Artisan_Economy__c> artisanRecords;
    private List<Country_Product_Economy__c> junctionRecords;
    private List<Province_Economy__c> provinceRecords;

    private String errorMessage;

    public EconomyImportBatch(
        Id analysisId,
        List<Factory_Economy__c> factoryRecords,
        List<Artisan_Economy__c> artisanRecords
    ) {
        this(analysisId, null, factoryRecords, artisanRecords);
    }

    public EconomyImportBatch(
        Id analysisId,
        Id importRunId,
        List<Factory_Economy__c> factoryRecords,
        List<Artisan_Economy__c> artisanRecords
    ) {
        this.analysisId = analysisId;
        this.importRunId = importRunId;
        this.factoryRecords = (factoryRecords != null) ? factoryRecords : new List<Factory_Economy__c>();
        this.artisanRecords = (artisanRecords != null) ? artisanRecords : new List<Artisan_Economy__c>();
        this.junctionRecords = new List<Country_Product_Economy__c>();
        this.provinceRecords = new List<Province_Economy__c>();
    }

    public EconomyImportBatch(
        Id analysisId,
        List<Country_Product_Economy__c> junctionRecords,
        List<Province_Economy__c> provinceRecords
    ) {
        this.analysisId = analysisId;
        this.junctionRecords = (junctionRecords != null) ? junctionRecords : new List<Country_Product_Economy__c>();
        this.provinceRecords = (provinceRecords != null) ? provinceRecords : new List<Province_Economy__c>();
        this.factoryRecords = new List<Factory_Economy__c>();
        this.artisanRecords = new List<Artisan_Economy__c>();
    }

    public EconomyImportBatch(
        Id analysisId,
        List<Country_Product_Economy__c> junctionRecords,
        List<Province_Economy__c> provinceRecords,
        List<Factory_Economy__c> factoryRecords,
        List<Artisan_Economy__c> artisanRecords
    ) {
        this.analysisId = analysisId;
        this.junctionRecords = (junctionRecords != null) ? junctionRecords : new List<Country_Product_Economy__c>();
        this.provinceRecords = (provinceRecords != null) ? provinceRecords : new List<Province_Economy__c>();
        this.factoryRecords = (factoryRecords != null) ? factoryRecords : new List<Factory_Economy__c>();
        this.artisanRecords = (artisanRecords != null) ? artisanRecords : new List<Artisan_Economy__c>();
    }

    public List<sObject> start(Database.BatchableContext BC) {
        List<sObject> allRecords = new List<sObject>();
        allRecords.addAll((List<sObject>) this.junctionRecords);
        allRecords.addAll((List<sObject>) this.provinceRecords);
        allRecords.addAll((List<sObject>) this.factoryRecords);
        allRecords.addAll((List<sObject>) this.artisanRecords);
        return allRecords;
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        try {
            List<Country_Product_Economy__c> junctionsToUpsert = new List<Country_Product_Economy__c>();
            List<Province_Economy__c> provincesToUpsert = new List<Province_Economy__c>();
            List<Factory_Economy__c> factoriesToUpsert = new List<Factory_Economy__c>();
            List<Artisan_Economy__c> artisansToUpsert = new List<Artisan_Economy__c>();

            for (sObject record : scope) {
                if (record instanceof Country_Product_Economy__c) {
                    junctionsToUpsert.add((Country_Product_Economy__c) record);
                } else if (record instanceof Province_Economy__c) {
                    provincesToUpsert.add((Province_Economy__c) record);
                } else if (record instanceof Factory_Economy__c) {
                    factoriesToUpsert.add((Factory_Economy__c) record);
                } else if (record instanceof Artisan_Economy__c) {
                    artisansToUpsert.add((Artisan_Economy__c) record);
                }
            }

            // Grouping / Serialization by Parent Id to prevent UNABLE_TO_LOCK_ROW on master records
            if (!junctionsToUpsert.isEmpty() && Schema.sObjectType.Country_Product_Economy__c.isCreateable()) {
                junctionsToUpsert.sort();
                upsert junctionsToUpsert Unique_Snapshot_Key__c;
            }

            if (!provincesToUpsert.isEmpty() && Schema.sObjectType.Province_Economy__c.isCreateable()) {
                provincesToUpsert.sort();
                upsert provincesToUpsert Unique_Snapshot_Key__c;
            }

            if (!factoriesToUpsert.isEmpty() && Schema.sObjectType.Factory_Economy__c.isCreateable()) {
                factoriesToUpsert.sort();
                upsert factoriesToUpsert Unique_Snapshot_Key__c;
            }

            if (!artisansToUpsert.isEmpty() && Schema.sObjectType.Artisan_Economy__c.isCreateable()) {
                artisansToUpsert.sort();
                upsert artisansToUpsert Unique_Snapshot_Key__c;
            }
        } catch (Exception ex) {
            this.errorMessage = ex.getMessage() + '\n' + ex.getStackTraceString();
            ImportRunService.rollbackFailedImport(this.importRunId, this.analysisId, this.errorMessage);
            EconomyImportService.publishImportEvent(this.analysisId, ImportRunService.STATUS_FAILED, this.errorMessage, null);
        }
    }

    public void finish(Database.BatchableContext BC) {
        if (this.analysisId != null && String.isBlank(this.errorMessage)) {
            try {
                if (!this.junctionRecords.isEmpty() || !this.provinceRecords.isEmpty()) {
                    EconomyAnalysisService.recalculateAnalysis(this.analysisId);
                }

                if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                    update new Economy_Analysis__c(
                        Id = this.analysisId,
                        Import_Status__c = 'COMPLETED'
                    );
                }

                if (this.importRunId != null) {
                    ImportRunService.transitionStatus(
                        this.importRunId,
                        ImportRunService.STATUS_PUBLISHED,
                        null,
                        null,
                        'MATCHED'
                    );
                }

                EconomyImportService.publishImportEvent(this.analysisId, 'COMPLETED', null, null);
            } catch (Exception ex) {
                String diag = ex.getMessage() + '\n' + ex.getStackTraceString();
                ImportRunService.rollbackFailedImport(this.importRunId, this.analysisId, diag);
                EconomyImportService.publishImportEvent(this.analysisId, ImportRunService.STATUS_FAILED, diag, null);
            }
        }
    }
}
