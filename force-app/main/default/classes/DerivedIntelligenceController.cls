/**
 * @description Facade controller exposing Layer 3 derived metric scorecards and Layer 4 real-time anomaly alerts to LWC.
 */
public with sharing class DerivedIntelligenceController {

    /**
     * @description Fetches all core Layer 3 derived metric scorecards for a given snapshot, optional base comparison snapshot,
     * and optional country tag.
     */
    @AuraEnabled(cacheable=true)
    public static List<DerivedMetricDTO> getDerivedMetrics(Id snapshotId, Id baseSnapshotId, String countryTag) {
        if (snapshotId == null) {
            return new List<DerivedMetricDTO>();
        }
        return DerivedIntelligenceEngine.computeMetrics(snapshotId, baseSnapshotId, countryTag);
    }

    /**
     * @description Evaluates and triggers real-time anomaly alert publishing for a snapshot, returning the list of events generated.
     */
    @AuraEnabled
    public static List<Economy_Anomaly_Event__e> evaluateAnomalies(Id snapshotId, Id baseSnapshotId) {
        if (snapshotId == null) {
            return new List<Economy_Anomaly_Event__e>();
        }
        return DerivedIntelligenceEngine.evaluateAndPublishAnomalies(snapshotId, baseSnapshotId);
    }
}
