/**
 * @description Data Transfer Object for narrow, long-format time series metric datasets.
 * Capped by RSK-03 (12-snapshot hard cap) for governor limit safety and fast client rendering.
 */
public with sharing class NarrowMetricDTO {

    @AuraEnabled public String metricKey { get; set; }
    @AuraEnabled public Id snapshotId { get; set; }
    @AuraEnabled public Date ingameDate { get; set; }
    @AuraEnabled public String entityKey { get; set; }
    @AuraEnabled public Decimal value { get; set; }

    public NarrowMetricDTO() {
        this.value = 0.0;
    }

    public NarrowMetricDTO(String metricKey, Id snapshotId, Date ingameDate, String entityKey, Decimal value) {
        this.metricKey = metricKey;
        this.snapshotId = snapshotId;
        this.ingameDate = ingameDate;
        this.entityKey = entityKey;
        this.value = (value != null) ? value : 0.0;
    }

    public class EventTickDTO {
        @AuraEnabled public Id snapshotId { get; set; }
        @AuraEnabled public Date ingameDate { get; set; }
        @AuraEnabled public String eventType { get; set; } // 'WAR', 'REFORM', 'CRISIS', 'EVENT'
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }

        public EventTickDTO() {
        }

        public EventTickDTO(Id snapshotId, Date ingameDate, String eventType, String title, String description) {
            this.snapshotId = snapshotId;
            this.ingameDate = ingameDate;
            this.eventType = eventType;
            this.title = title;
            this.description = description;
        }
    }
}
