public with sharing class StateSummaryDTO {
    @AuraEnabled public Id stateEconomyId { get; set; }
    @AuraEnabled public String stateCode { get; set; }
    @AuraEnabled public String stateName { get; set; }
    @AuraEnabled public String countryTag { get; set; }
    @AuraEnabled public Long population { get; set; }
    @AuraEnabled public Decimal gdp { get; set; }
    @AuraEnabled public Decimal gdpPerCapita { get; set; }
    @AuraEnabled public Integer gdpRank { get; set; }
    @AuraEnabled public Decimal rgoIncome { get; set; }
    @AuraEnabled public Decimal pgdp { get; set; }
    @AuraEnabled public Decimal agdp { get; set; }
    @AuraEnabled public Decimal fgdp { get; set; }
    @AuraEnabled public Long factoryEmployees { get; set; }
    @AuraEnabled public Decimal factoryRevenue { get; set; }
    @AuraEnabled public Decimal factoryProfit { get; set; }

    public StateSummaryDTO() {
        this.population = 0;
        this.gdp = 0.0;
        this.gdpPerCapita = 0.0;
        this.gdpRank = 0;
        this.rgoIncome = 0.0;
        this.pgdp = 0.0;
        this.agdp = 0.0;
        this.fgdp = 0.0;
        this.factoryEmployees = 0;
        this.factoryRevenue = 0.0;
        this.factoryProfit = 0.0;
    }

    public StateSummaryDTO(State_Economy__c se) {
        if (se != null) {
            this.stateEconomyId = se.Id;
            if (se.State__r != null) {
                this.stateCode = se.State__r.State_Code__c;
                this.stateName = String.isNotBlank(se.State__r.Name) ? se.State__r.Name : se.State__r.State_Code__c;
            } else {
                this.stateCode = se.Unique_Snapshot_Key__c;
                this.stateName = se.Unique_Snapshot_Key__c;
            }
            if (se.Country_Economy__r != null) {
                this.countryTag = se.Country_Economy__r.Country_Tag__c;
            }
            this.population = (se.Population__c != null) ? se.Population__c.longValue() : 0;
            this.gdp = (se.GDP__c != null) ? se.GDP__c : 0.0;
            this.gdpPerCapita = (se.GDP_Per_Capita__c != null) ? se.GDP_Per_Capita__c : 0.0;
            this.gdpRank = (se.GDP_Rank__c != null) ? se.GDP_Rank__c.intValue() : 0;
            this.rgoIncome = (se.RGO_Income__c != null) ? se.RGO_Income__c : 0.0;
            this.pgdp = (se.PGDP__c != null) ? se.PGDP__c : 0.0;
            this.agdp = (se.AGDP__c != null) ? se.AGDP__c : 0.0;
            this.fgdp = (se.FGDP__c != null) ? se.FGDP__c : 0.0;
            this.factoryEmployees = (se.Factory_Employees__c != null) ? se.Factory_Employees__c.longValue() : 0;
            this.factoryRevenue = (se.Factory_Revenue__c != null) ? se.Factory_Revenue__c : 0.0;
            this.factoryProfit = (se.Factory_Profit__c != null) ? se.Factory_Profit__c : 0.0;
        }
    }
}
