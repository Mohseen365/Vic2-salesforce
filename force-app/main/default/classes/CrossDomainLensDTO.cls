/**
 * @description Data Transfer Object encapsulating cross-domain lens analytics, headline insights,
 * chart visualization data points, and provenance evidence for Phase 2 FEAT-17-lite capabilities.
 */
public with sharing class CrossDomainLensDTO {

    @AuraEnabled public String capabilityId { get; set; }
    @AuraEnabled public String title { get; set; }
    @AuraEnabled public String category { get; set; }
    @AuraEnabled public String headline { get; set; }
    @AuraEnabled public String countryTag { get; set; }
    @AuraEnabled public String countryName { get; set; }
    @AuraEnabled public Decimal primaryMetricValue { get; set; }
    @AuraEnabled public String primaryMetricFormatted { get; set; }
    @AuraEnabled public Decimal secondaryMetricValue { get; set; }
    @AuraEnabled public String secondaryMetricFormatted { get; set; }
    @AuraEnabled public String status { get; set; } // 'Optimal', 'Warning', 'Critical', 'Informational'
    @AuraEnabled public String chartType { get; set; } // 'scatter', 'bar_line', 'gauge', 'trail'
    @AuraEnabled public List<DataPoint> dataPoints { get; set; }
    @AuraEnabled public EvidenceDetail evidence { get; set; }

    public CrossDomainLensDTO() {
        this.dataPoints = new List<DataPoint>();
        this.evidence = new EvidenceDetail();
        this.status = 'Informational';
        this.primaryMetricValue = 0.0;
        this.secondaryMetricValue = 0.0;
    }

    public class DataPoint {
        @AuraEnabled public Decimal x { get; set; }
        @AuraEnabled public Decimal y { get; set; }
        @AuraEnabled public Decimal size { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String meta { get; set; }

        public DataPoint() {}

        public DataPoint(Decimal x, Decimal y, Decimal size, String label, String category, String meta) {
            this.x = (x != null) ? x : 0.0;
            this.y = (y != null) ? y : 0.0;
            this.size = (size != null) ? size : 1.0;
            this.label = label;
            this.category = category;
            this.meta = meta;
        }
    }

    public class EvidenceDetail {
        @AuraEnabled public List<String> sourceObjects { get; set; }
        @AuraEnabled public String formulaDetails { get; set; }
        @AuraEnabled public List<String> provenanceBadges { get; set; }
        @AuraEnabled public String notes { get; set; }

        public EvidenceDetail() {
            this.sourceObjects = new List<String>();
            this.provenanceBadges = new List<String>();
        }
    }
}
