public class CountrySummaryDTO {
    @AuraEnabled public Id countryEconomyId { get; set; }
    @AuraEnabled public String countryTag { get; set; }
    @AuraEnabled public String countryName { get; set; }
    @AuraEnabled public String flagUrl { get; set; }
    @AuraEnabled public Decimal population { get; set; }
    @AuraEnabled public Decimal workforce { get; set; }
    @AuraEnabled public Decimal employment { get; set; }
    @AuraEnabled public Decimal gdp { get; set; }
    @AuraEnabled public Decimal gdpPerCapita { get; set; }
    @AuraEnabled public Integer gdpRank { get; set; }
    @AuraEnabled public Decimal gdpShare { get; set; }
    @AuraEnabled public Decimal unemploymentRate { get; set; }
    @AuraEnabled public Decimal unemploymentRateRgo { get; set; }
    @AuraEnabled public Decimal unemploymentRateFactory { get; set; }
    @AuraEnabled public Decimal totalImports { get; set; }
    @AuraEnabled public Decimal totalExports { get; set; }
    @AuraEnabled public Decimal goldIncome { get; set; }

    public CountrySummaryDTO() {
        this.population = 0;
        this.workforce = 0;
        this.employment = 0;
        this.gdp = 0.0;
        this.gdpPerCapita = 0.0;
        this.gdpRank = 0;
        this.gdpShare = 0.0;
        this.unemploymentRate = 0.0;
        this.unemploymentRateRgo = 0.0;
        this.unemploymentRateFactory = 0.0;
        this.totalImports = 0.0;
        this.totalExports = 0.0;
        this.goldIncome = 0.0;
    }

    public CountrySummaryDTO(Country_Economy__c ce) {
        if (ce != null) {
            this.countryEconomyId = ce.Id;
            this.countryTag = ce.Country_Tag__c;
            this.countryName = ce.Country_Tag__c;
            if (ce.Country__r != null && String.isNotBlank(ce.Country__r.Flag_URL__c)) {
                this.flagUrl = ce.Country__r.Flag_URL__c;
            }
            this.population = ce.Population__c;
            this.workforce = ce.Workforce__c;
            this.employment = ce.Employment__c;
            this.gdp = ce.GDP__c;
            this.gdpPerCapita = ce.GDP_Per_Capita__c;
            this.gdpRank = (ce.GDP_Rank__c != null) ? Integer.valueOf(ce.GDP_Rank__c) : 0;
            this.gdpShare = ce.GDP_Share_Percent__c;
            this.unemploymentRate = ce.Unemployment_Rate__c;
            this.unemploymentRateRgo = ce.Unemployment_Rate_RGO__c;
            this.unemploymentRateFactory = ce.Unemployment_Rate_Factory__c;
            this.totalImports = ce.Total_Imports_Value__c;
            this.totalExports = ce.Total_Exports_Value__c;
            this.goldIncome = ce.Gold_Income__c;
        }
    }
}
