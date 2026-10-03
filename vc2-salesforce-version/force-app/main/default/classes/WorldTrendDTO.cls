/**
 * @description Data Transfer Object for multi-save world trend time series analysis.
 * Out of Original Audit Scope — Enhancement Track A.
 * LDV Budget: Analysis IDs capped at 12 per request.
 */
public with sharing class WorldTrendDTO {

    public class TrendPointDTO {
        @AuraEnabled public Id analysisId { get; set; }
        @AuraEnabled public String saveFileName { get; set; }
        @AuraEnabled public Date ingameDate { get; set; }
        @AuraEnabled public Decimal totalWorldGdp { get; set; }
        @AuraEnabled public Decimal totalWorldPopulation { get; set; }
        @AuraEnabled public Decimal totalWorldImports { get; set; }
        @AuraEnabled public Decimal totalWorldExports { get; set; }

        public TrendPointDTO() {
            this.totalWorldGdp = 0.0;
            this.totalWorldPopulation = 0;
            this.totalWorldImports = 0.0;
            this.totalWorldExports = 0.0;
        }
    }

    @AuraEnabled public List<TrendPointDTO> points { get; set; }

    public WorldTrendDTO() {
        this.points = new List<TrendPointDTO>();
    }
}
