public class CountryProductSummaryDTO {
    @AuraEnabled public Id junctionId { get; set; }
    @AuraEnabled public String countryTag { get; set; }
    @AuraEnabled public String countryName { get; set; }
    @AuraEnabled public String productCode { get; set; }
    @AuraEnabled public String productName { get; set; }
    @AuraEnabled public Decimal soldDomestic { get; set; }
    @AuraEnabled public Decimal boughtQuantity { get; set; }
    @AuraEnabled public Decimal thrownToMarket { get; set; }
    @AuraEnabled public Decimal actualSoldWorld { get; set; }
    @AuraEnabled public Decimal worldmarketPool { get; set; }
    @AuraEnabled public Decimal intermediateConsumption { get; set; }
    @AuraEnabled public Decimal totalSupplyPounds { get; set; }
    @AuraEnabled public Decimal actualSupplyPounds { get; set; }
    @AuraEnabled public Decimal actualDemandPounds { get; set; }
    @AuraEnabled public Decimal domesticSalesValue { get; set; }
    @AuraEnabled public Decimal importValue { get; set; }
    @AuraEnabled public Decimal exportValue { get; set; }
    @AuraEnabled public Decimal gdpContribution { get; set; }

    public CountryProductSummaryDTO() {
        this.soldDomestic = 0.0;
        this.boughtQuantity = 0.0;
        this.thrownToMarket = 0.0;
        this.actualSoldWorld = 0.0;
        this.worldmarketPool = 0.0;
        this.intermediateConsumption = 0.0;
        this.totalSupplyPounds = 0.0;
        this.actualSupplyPounds = 0.0;
        this.actualDemandPounds = 0.0;
        this.domesticSalesValue = 0.0;
        this.importValue = 0.0;
        this.exportValue = 0.0;
        this.gdpContribution = 0.0;
    }

    public CountryProductSummaryDTO(Country_Product_Economy__c cpe) {
        if (cpe != null) {
            this.junctionId = cpe.Id;
            if (cpe.Country_Economy__r != null) {
                this.countryTag = cpe.Country_Economy__r.Country_Tag__c;
                if (cpe.Country_Economy__r.Country__r != null && String.isNotBlank(cpe.Country_Economy__r.Country__r.Name)) {
                    this.countryName = cpe.Country_Economy__r.Country__r.Name;
                } else {
                    this.countryName = cpe.Country_Economy__r.Country_Tag__c;
                }
            }
            this.productCode = cpe.Product_Code__c;
            this.productName = cpe.Product_Code__c;
            this.soldDomestic = cpe.Sold_Domestic__c;
            this.boughtQuantity = cpe.Bought_Quantity__c;
            this.thrownToMarket = cpe.Thrown_To_Market__c;
            this.actualSoldWorld = cpe.Actual_Sold_World__c;
            this.worldmarketPool = cpe.Worldmarket_Pool__c;
            this.intermediateConsumption = cpe.Intermediate_Consumption__c;
            this.totalSupplyPounds = cpe.Total_Supply_Pounds__c;
            this.actualSupplyPounds = cpe.Actual_Supply_Pounds__c;
            this.actualDemandPounds = cpe.Actual_Demand_Pounds__c;
            this.domesticSalesValue = cpe.Domestic_Sales_Value__c;
            this.importValue = cpe.Import_Value__c;
            this.exportValue = cpe.Export_Value__c;
            this.gdpContribution = cpe.GDP_Contribution__c;
        }
    }
}
