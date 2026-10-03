/**
 * @description Data Transfer Object for multi-save product trend time series analysis.
 * Out of Original Audit Scope — Enhancement Track A.
 * LDV Budget: Analysis IDs capped at 12 per request.
 */
public with sharing class ProductTrendDTO {

    public class TrendPointDTO {
        @AuraEnabled public Id analysisId { get; set; }
        @AuraEnabled public Date ingameDate { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public Decimal totalWorldSupply { get; set; }
        @AuraEnabled public Decimal realDemand { get; set; }
        @AuraEnabled public Decimal inflationPercent { get; set; }
        @AuraEnabled public Decimal overproductionPercent { get; set; }

        public TrendPointDTO() {
            this.price = 0.0;
            this.totalWorldSupply = 0.0;
            this.realDemand = 0.0;
            this.inflationPercent = 0.0;
            this.overproductionPercent = 0.0;
        }
    }

    public class ProductTrendSeriesDTO {
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public List<TrendPointDTO> points { get; set; }

        public ProductTrendSeriesDTO() {
            this.points = new List<TrendPointDTO>();
        }
    }

    @AuraEnabled public List<ProductTrendSeriesDTO> series { get; set; }

    public ProductTrendDTO() {
        this.series = new List<ProductTrendSeriesDTO>();
    }
}
