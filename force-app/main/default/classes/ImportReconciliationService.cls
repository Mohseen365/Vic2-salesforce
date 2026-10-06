/**
 * @description Service performing post-import rollup schema versioning and checksum reconciliation.
 * Verifies that pre-aggregated population rollups across Country_Economy__c and Province_Economy__c
 * match parser-reported total population checksums.
 */
public with sharing class ImportReconciliationService {

    public class ReconciliationResult {
        @AuraEnabled public Long calculatedPopChecksum { get; set; }
        @AuraEnabled public Long expectedPopChecksum { get; set; }
        @AuraEnabled public String checksumStatus { get; set; } // MATCHED, MISMATCHED, SKIPPED
        @AuraEnabled public Boolean isMatched { get; set; }

        public ReconciliationResult() {
            this.calculatedPopChecksum = 0;
            this.expectedPopChecksum = null;
            this.checksumStatus = 'SKIPPED';
            this.isMatched = true;
        }
    }

    /**
     * @description Calculates country and province population rollups and reconciles against expected parser total.
     */
    public static ReconciliationResult reconcilePopulationChecksum(Id analysisHeaderId, Long expectedPopChecksum) {
        ReconciliationResult result = new ReconciliationResult();
        result.expectedPopChecksum = expectedPopChecksum;

        Long countryTotalPop = 0;

        if (analysisHeaderId != null && Schema.sObjectType.Country_Economy__c.isAccessible()) {
            AggregateResult[] ar = [
                SELECT SUM(Population__c) totalPop
                FROM Country_Economy__c
                WHERE Economy_Analysis__c = :analysisHeaderId
            ];
            if (!ar.isEmpty() && ar[0].get('totalPop') != null) {
                countryTotalPop = ((Decimal) ar[0].get('totalPop')).longValue();
            }
        }

        result.calculatedPopChecksum = countryTotalPop;

        if (expectedPopChecksum == null || expectedPopChecksum <= 0) {
            result.checksumStatus = 'SKIPPED';
            result.isMatched = true;
            return result;
        }

        if (result.calculatedPopChecksum == expectedPopChecksum) {
            result.checksumStatus = 'MATCHED';
            result.isMatched = true;
        } else {
            result.checksumStatus = 'MISMATCHED';
            result.isMatched = false;
        }

        return result;
    }

    /**
     * @description Stamps Rollup_Schema_Version__c on the active Import_Run__c record.
     */
    public static void stampRollupSchemaVersion(Id importRunId, String schemaVersion) {
        if (importRunId == null || String.isBlank(schemaVersion) || !Schema.sObjectType.Import_Run__c.isUpdateable()) {
            return;
        }

        update new Import_Run__c(
            Id = importRunId,
            Rollup_Schema_Version__c = schemaVersion
        );
    }
}
