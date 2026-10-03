public with sharing class ProductSummaryDTO {
    @AuraEnabled public Id productEconomyId { get; set; }
    @AuraEnabled public String productCode { get; set; }
    @AuraEnabled public String productName { get; set; }
    @AuraEnabled public Decimal price { get; set; }
    @AuraEnabled public Decimal basePrice { get; set; }
    @AuraEnabled public Decimal totalWorldSupply { get; set; }
    @AuraEnabled public Decimal realDemand { get; set; }
    @AuraEnabled public Decimal maxDemand { get; set; }
    @AuraEnabled public Decimal overproductionPercent { get; set; }
    @AuraEnabled public Decimal inflationPercent { get; set; }

    public ProductSummaryDTO() {
        this.price = 0.0;
        this.basePrice = 0.0;
        this.totalWorldSupply = 0.0;
        this.realDemand = 0.0;
        this.maxDemand = 0.0;
        this.overproductionPercent = 0.0;
        this.inflationPercent = 0.0;
    }

    public ProductSummaryDTO(Product_Economy__c pe) {
        if (pe != null) {
            this.productEconomyId = pe.Id;
            this.productCode = pe.Product_Code__c;
            this.productName = pe.Product_Code__c;
            this.price = pe.Price__c;
            this.basePrice = pe.Base_Price__c;
            this.totalWorldSupply = pe.Total_World_Supply__c;
            this.realDemand = pe.Real_Demand__c;
            this.maxDemand = pe.Max_Demand__c;
            this.overproductionPercent = pe.Overproduction_Percent__c;
            this.inflationPercent = pe.Inflation_Percent__c;
        }
    }
}
