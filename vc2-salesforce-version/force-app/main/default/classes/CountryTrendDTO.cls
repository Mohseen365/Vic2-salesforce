/**
 * @description Data Transfer Object for multi-save country trend time series analysis.
 * Out of Original Audit Scope — Enhancement Track A.
 * LDV Budget: Analysis IDs capped at 12 per request.
 */
public with sharing class CountryTrendDTO {

    public class TrendPointDTO {
        @AuraEnabled public Id analysisId { get; set; }
        @AuraEnabled public Date ingameDate { get; set; }
        @AuraEnabled public Decimal gdp { get; set; }
        @AuraEnabled public Decimal gdpPerCapita { get; set; }
        @AuraEnabled public Integer gdpRank { get; set; }
        @AuraEnabled public Decimal imports { get; set; }
        @AuraEnabled public Decimal exports { get; set; }

        public TrendPointDTO() {
            this.gdp = 0.0;
            this.gdpPerCapita = 0.0;
            this.gdpRank = 0;
            this.imports = 0.0;
            this.exports = 0.0;
        }
    }

    public class CountryTrendSeriesDTO {
        @AuraEnabled public String countryTag { get; set; }
        @AuraEnabled public String countryName { get; set; }
        @AuraEnabled public List<TrendPointDTO> points { get; set; }

        public CountryTrendSeriesDTO() {
            this.points = new List<TrendPointDTO>();
        }
    }

    @AuraEnabled public List<CountryTrendSeriesDTO> series { get; set; }

    public CountryTrendDTO() {
        this.series = new List<CountryTrendSeriesDTO>();
    }
}
