/**
 * @description Facade Controller providing cacheable @AuraEnabled methods for Cross-Domain
 * Intelligence Engine analytics (`FEAT-17-lite`).
 */
public with sharing class CrossDomainAnalysisController {

    /**
     * @description Returns all 5 Phase 2 cross-domain lenses for a given save/snapshot, optional base comparison save,
     * and optional country tag.
     * @param snapshotId Current snapshot Economy_Analysis__c Id.
     * @param baseSnapshotId Optional baseline Economy_Analysis__c Id for comparison.
     * @param countryTag Optional target country tag filter (e.g. 'TUR', 'ENG').
     * @return List of CrossDomainLensDTO objects.
     */
    @AuraEnabled(cacheable=true)
    public static List<CrossDomainLensDTO> getLensGalleryData(Id snapshotId, Id baseSnapshotId, String countryTag) {
        try {
            if (snapshotId == null) {
                List<Economy_Analysis__c> recent = EconomyAnalysisSelector.selectAllRecent(1);
                if (!recent.isEmpty()) {
                    snapshotId = recent[0].Id;
                }
            }

            if (snapshotId == null) {
                return new List<CrossDomainLensDTO>();
            }

            return CrossDomainIntelligenceEngine.computeAllLenses(snapshotId, baseSnapshotId, countryTag);
        } catch (Exception ex) {
            throw new AuraHandledException('Error executing cross-domain analysis: ' + ex.getMessage());
        }
    }

    /**
     * @description Returns a single CrossDomainLensDTO capability payload by capability Id.
     * @param capabilityId Capability ID (e.g. 'CAP-D-001').
     * @param snapshotId Current snapshot Economy_Analysis__c Id.
     * @param baseSnapshotId Optional baseline Economy_Analysis__c Id.
     * @param countryTag Target country tag.
     * @return CrossDomainLensDTO object.
     */
    @AuraEnabled(cacheable=true)
    public static CrossDomainLensDTO getLensData(String capabilityId, Id snapshotId, Id baseSnapshotId, String countryTag) {
        try {
            if (snapshotId == null) {
                List<Economy_Analysis__c> recent = EconomyAnalysisSelector.selectAllRecent(1);
                if (!recent.isEmpty()) {
                    snapshotId = recent[0].Id;
                }
            }

            if (snapshotId == null || String.isBlank(capabilityId)) {
                return new CrossDomainLensDTO();
            }

            switch on capabilityId {
                when 'CAP-D-001' {
                    return CrossDomainIntelligenceEngine.computeTaxVsGdpGrowth(snapshotId, baseSnapshotId, countryTag);
                }
                when 'CAP-D-006' {
                    return CrossDomainIntelligenceEngine.computeMilitaryBudgetRatio(snapshotId, countryTag);
                }
                when 'CAP-D-011' {
                    return CrossDomainIntelligenceEngine.computeLiteracyProductivity(snapshotId, countryTag);
                }
                when 'CAP-D-016' {
                    return CrossDomainIntelligenceEngine.computeWarGdpDecline(snapshotId, baseSnapshotId, countryTag);
                }
                when 'CAP-D-021' {
                    return CrossDomainIntelligenceEngine.computeSphereMarketCapture(snapshotId, countryTag);
                }
                when else {
                    return new CrossDomainLensDTO();
                }
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error fetching capability lens data: ' + ex.getMessage());
        }
    }
}
