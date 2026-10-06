/**
 * @description Data Transfer Object encapsulating Layer 3 derived metric scorecards,
 * formula provenance details, component breakdowns, and score deltas.
 */
public with sharing class DerivedMetricDTO {

    @AuraEnabled public String metricId { get; set; }
    @AuraEnabled public String metricName { get; set; }
    @AuraEnabled public Decimal score { get; set; }
    @AuraEnabled public String formattedScore { get; set; }
    @AuraEnabled public Decimal delta { get; set; }
    @AuraEnabled public String deltaFormatted { get; set; }
    @AuraEnabled public String category { get; set; }
    @AuraEnabled public String status { get; set; } // 'Optimal', 'Warning', 'Critical', 'Informational'
    @AuraEnabled public String countryTag { get; set; }
    @AuraEnabled public String countryName { get; set; }
    @AuraEnabled public String formulaVersion { get; set; }
    @AuraEnabled public String formulaDescription { get; set; }
    @AuraEnabled public List<String> sourceFields { get; set; }
    @AuraEnabled public List<ComponentBreakdown> components { get; set; }

    public DerivedMetricDTO() {
        this.score = 0.0;
        this.delta = 0.0;
        this.status = 'Informational';
        this.formulaVersion = 'v1.0.0';
        this.sourceFields = new List<String>();
        this.components = new List<ComponentBreakdown>();
    }

    public class ComponentBreakdown {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal rawValue { get; set; }
        @AuraEnabled public Decimal weight { get; set; }
        @AuraEnabled public Decimal contribution { get; set; }
        @AuraEnabled public String formattedValue { get; set; }

        public ComponentBreakdown() {}

        public ComponentBreakdown(String name, Decimal rawValue, Decimal weight, Decimal contribution, String formattedValue) {
            this.name = name;
            this.rawValue = rawValue;
            this.weight = weight;
            this.contribution = contribution;
            this.formattedValue = formattedValue;
        }
    }
}
