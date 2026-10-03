public with sharing class AnalysisComparisonDTO {

    public class CountryDelta {
        @AuraEnabled public String countryTag { get; set; }
        @AuraEnabled public Decimal baseGdp { get; set; }
        @AuraEnabled public Decimal compareGdp { get; set; }
        @AuraEnabled public Decimal gdpDelta { get; set; }
        @AuraEnabled public Decimal gdpGrowthPercent { get; set; }

        public CountryDelta() {
            this.baseGdp = 0.0;
            this.compareGdp = 0.0;
            this.gdpDelta = 0.0;
            this.gdpGrowthPercent = 0.0;
        }
    }

    public class ProductDelta {
        @AuraEnabled public String productCode { get; set; }
        @AuraEnabled public Decimal basePrice { get; set; }
        @AuraEnabled public Decimal comparePrice { get; set; }
        @AuraEnabled public Decimal priceDelta { get; set; }
        @AuraEnabled public Decimal priceGrowthPercent { get; set; }

        public ProductDelta() {
            this.basePrice = 0.0;
            this.comparePrice = 0.0;
            this.priceDelta = 0.0;
            this.priceGrowthPercent = 0.0;
        }
    }

    @AuraEnabled public Id baseAnalysisId { get; set; }
    @AuraEnabled public Id compareAnalysisId { get; set; }
    @AuraEnabled public Decimal baseGdp { get; set; }
    @AuraEnabled public Decimal compareGdp { get; set; }
    @AuraEnabled public Decimal gdpGrowthPercent { get; set; }
    @AuraEnabled public List<CountryDelta> countryDeltas { get; set; }
    @AuraEnabled public List<ProductDelta> productDeltas { get; set; }

    public AnalysisComparisonDTO() {
        this.baseGdp = 0.0;
        this.compareGdp = 0.0;
        this.gdpGrowthPercent = 0.0;
        this.countryDeltas = new List<CountryDelta>();
        this.productDeltas = new List<ProductDelta>();
    }
}
