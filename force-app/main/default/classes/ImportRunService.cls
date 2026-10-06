/**
 * @description Service managing the lifecycle and state machine transitions of Import_Run__c sessions.
 * Implements provenance tracking, valid state transitions (RECEIVED -> PROCESSING -> VALIDATING -> PUBLISHED / FAILED),
 * and rollback/purge capabilities for failed or partial save-game ingestion sessions.
 */
public with sharing class ImportRunService {

    public static final String STATUS_RECEIVED = 'RECEIVED';
    public static final String STATUS_PROCESSING = 'PROCESSING';
    public static final String STATUS_VALIDATING = 'VALIDATING';
    public static final String STATUS_PUBLISHED = 'PUBLISHED';
    public static final String STATUS_FAILED = 'FAILED';

    private static final Set<String> VALID_STATES = new Set<String>{
        STATUS_RECEIVED,
        STATUS_PROCESSING,
        STATUS_VALIDATING,
        STATUS_PUBLISHED,
        STATUS_FAILED
    };

    /**
     * @description Gets or creates an Import_Run__c record keyed by (saveId, entityType, chunkSeq).
     */
    public static Import_Run__c getOrCreateImportRun(
        EconomyImportRequestDTO.AnalysisDTO analysisDTO,
        String analysisKey,
        Id analysisHeaderId
    ) {
        String entityType = (analysisDTO != null && String.isNotBlank(analysisDTO.entityType)) ? analysisDTO.entityType : 'FULL';
        Integer chunkSeq = (analysisDTO != null && analysisDTO.chunkSeq != null) ? analysisDTO.chunkSeq : 1;
        Integer totalChunks = (analysisDTO != null && analysisDTO.totalChunks != null) ? analysisDTO.totalChunks : 1;
        String rollupVer = (analysisDTO != null && String.isNotBlank(analysisDTO.rollupSchemaVersion)) ? analysisDTO.rollupSchemaVersion : '1.0.0';
        Long expectedChecksum = (analysisDTO != null) ? analysisDTO.expectedPopChecksum : null;

        String runIdentifier = analysisKey + '_' + entityType + '_chunk_' + chunkSeq;
        Import_Run__c runRecord = null;

        if (Schema.sObjectType.Import_Run__c.isAccessible()) {
            List<Import_Run__c> existing = [
                SELECT Id, Name, Save_Identifier__c, Status__c, Calculated_Pop_Checksum__c, Checksum_Status__c,
                       Economy_Analysis__c, Rollup_Schema_Version__c
                FROM Import_Run__c
                WHERE Save_Identifier__c = :runIdentifier
                LIMIT 1
            ];
            if (!existing.isEmpty()) {
                runRecord = existing[0];
            }
        }

        if (runRecord == null) {
            runRecord = new Import_Run__c(
                Name = 'Run-' + runIdentifier.left(70),
                Save_Identifier__c = runIdentifier,
                Entity_Type__c = entityType,
                Chunk_Sequence__c = chunkSeq,
                Total_Chunks__c = totalChunks,
                Total_Pop_Checksum__c = expectedChecksum,
                Rollup_Schema_Version__c = rollupVer,
                Economy_Analysis__c = analysisHeaderId,
                Status__c = STATUS_RECEIVED,
                Checksum_Status__c = 'PENDING'
            );
            if (Schema.sObjectType.Import_Run__c.isCreateable()) {
                insert runRecord;
            }
        } else {
            runRecord.Status__c = STATUS_RECEIVED;
            runRecord.Total_Pop_Checksum__c = expectedChecksum;
            runRecord.Rollup_Schema_Version__c = rollupVer;
            runRecord.Economy_Analysis__c = analysisHeaderId;
            if (Schema.sObjectType.Import_Run__c.isUpdateable()) {
                update runRecord;
            }
        }

        return runRecord;
    }

    /**
     * @description Transitions the status of an Import_Run__c record with validation and diagnostic updates.
     */
    public static void transitionStatus(
        Id importRunId,
        String newStatus,
        String diagnosticMessage,
        Long calculatedChecksum,
        String checksumStatus
    ) {
        if (importRunId == null || String.isBlank(newStatus) || !VALID_STATES.contains(newStatus)) {
            return;
        }

        if (!Schema.sObjectType.Import_Run__c.isUpdateable()) {
            return;
        }

        Import_Run__c recordToUpdate = new Import_Run__c(
            Id = importRunId,
            Status__c = newStatus
        );

        if (diagnosticMessage != null) {
            recordToUpdate.Diagnostic_Message__c = diagnosticMessage.left(255);
        }
        if (calculatedChecksum != null) {
            recordToUpdate.Calculated_Pop_Checksum__c = calculatedChecksum;
        }
        if (checksumStatus != null) {
            recordToUpdate.Checksum_Status__c = checksumStatus;
        }

        update recordToUpdate;
    }

    /**
     * @description Rolls back a failed import session by updating the Import_Run__c and Economy_Analysis__c status to FAILED.
     */
    public static void rollbackFailedImport(Id importRunId, Id analysisHeaderId, String diagnosticMessage) {
        if (importRunId != null) {
            transitionStatus(importRunId, STATUS_FAILED, diagnosticMessage, null, 'FAILED');
        }

        if (analysisHeaderId != null && Schema.sObjectType.Economy_Analysis__c.isUpdateable()) {
            update new Economy_Analysis__c(
                Id = analysisHeaderId,
                Import_Status__c = STATUS_FAILED,
                Import_Diagnostic_Message__c = (diagnosticMessage != null) ? diagnosticMessage.left(255) : 'Import Failed'
            );
        }
    }

    /**
     * @description Purges all child snapshot records associated with an Economy_Analysis__c header upon rollback/failure.
     */
    public static void purgeAnalysisRecords(Id analysisHeaderId) {
        if (analysisHeaderId == null) {
            return;
        }

        if (Schema.sObjectType.Artisan_Economy__c.isDeletable()) {
            List<Artisan_Economy__c> artisans = [SELECT Id FROM Artisan_Economy__c WHERE Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!artisans.isEmpty()) { delete artisans; }
        }

        if (Schema.sObjectType.Factory_Economy__c.isDeletable()) {
            List<Factory_Economy__c> factories = [SELECT Id FROM Factory_Economy__c WHERE Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!factories.isEmpty()) { delete factories; }
        }

        if (Schema.sObjectType.Province_Economy__c.isDeletable()) {
            List<Province_Economy__c> provs = [SELECT Id FROM Province_Economy__c WHERE Country_Economy__r.Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!provs.isEmpty()) { delete provs; }
        }

        if (Schema.sObjectType.Country_Product_Economy__c.isDeletable()) {
            List<Country_Product_Economy__c> cpList = [SELECT Id FROM Country_Product_Economy__c WHERE Country_Economy__r.Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!cpList.isEmpty()) { delete cpList; }
        }

        if (Schema.sObjectType.State_Economy__c.isDeletable()) {
            List<State_Economy__c> states = [SELECT Id FROM State_Economy__c WHERE Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!states.isEmpty()) { delete states; }
        }

        if (Schema.sObjectType.Product_Economy__c.isDeletable()) {
            List<Product_Economy__c> prods = [SELECT Id FROM Product_Economy__c WHERE Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!prods.isEmpty()) { delete prods; }
        }

        if (Schema.sObjectType.Country_Economy__c.isDeletable()) {
            List<Country_Economy__c> countries = [SELECT Id FROM Country_Economy__c WHERE Economy_Analysis__c = :analysisHeaderId LIMIT 5000];
            if (!countries.isEmpty()) { delete countries; }
        }
    }
}
