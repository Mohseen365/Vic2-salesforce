/**
 * @description Batch Apex framework for chunked processing of large Country x Product x Province snapshots
 * and large Factory and Artisan snapshots (GATE-3).
 * Prevents DML and heap limit exceptions for Large Data Volumes (LDV).
 * Completes by transitioning analysis status to COMPLETED and, for legacy junction/province batches,
 * invoking EconomyAnalysisService.recalculateAnalysis.
 */
public with sharing class EconomyImportBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id analysisId;
    private Id importRunId;

    // NEW (GATE-3): Factory and Artisan snapshot records
    private List<Factory_Economy__c> factoryRecords;
    private List<Artisan_Economy__c> artisanRecords;

    // LEGACY (Phase 5/6 Pre-commit): Country_Product and Province snapshot records
    private List<Country_Product_Economy__c> junctionRecords;
    private List<Province_Economy__c> provinceRecords;

    private String errorMessage;

    // NEW (GATE-3) Constructor — accepts Factory and Artisan records
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

    // LEGACY (Phase 5/6 Pre-commit) Constructor — accepts Junction and Province records
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

    // MERGED Constructor — accepts all four record types for full backward and forward compatibility
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

            if (!junctionsToUpsert.isEmpty() && Schema.sObjectType.Country_Product_Economy__c.isCreateable()) {
                upsert junctionsToUpsert Unique_Snapshot_Key__c;
            }

            if (!provincesToUpsert.isEmpty() && Schema.sObjectType.Province_Economy__c.isCreateable()) {
                upsert provincesToUpsert Unique_Snapshot_Key__c;
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
                // LEGACY (Phase 5/6 Pre-commit): Hand off to recalculation engine for junction/province batches
                if (!this.junctionRecords.isEmpty() || !this.provinceRecords.isEmpty()) {
                    EconomyAnalysisService.recalculateAnalysis(this.analysisId);
                }

                // NEW (GATE-3): Transition analysis status to COMPLETED and publish import event
                if (Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
                    update new Economy_Analysis__c(
                        Id = this.analysisId,
                        Import_Status__c = 'COMPLETED'
                    );
                }
                if (this.importRunId != null && Schema.sObjectType.Import_Run__c.isUpdateable()) {
                    update new Import_Run__c(
                        Id = this.importRunId,
                        Status__c = 'PUBLISHED',
                        Checksum_Status__c = 'MATCHED'
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
                    if (this.importRunId != null && Schema.sObjectType.Import_Run__c.isUpdateable()) {
                        update new Import_Run__c(
                            Id = this.importRunId,
                            Status__c = 'FAILED',
                            Diagnostic_Message__c = diag
                        );
                    }
                    EconomyImportService.publishImportEvent(this.analysisId, 'FAILED', diag, null);
                }
            }
        }
    }
}
