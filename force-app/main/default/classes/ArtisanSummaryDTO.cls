public with sharing class ArtisanSummaryDTO {
    @AuraEnabled public Id artisanEconomyId { get; set; }
    @AuraEnabled public String uniqueSnapshotKey { get; set; }
    @AuraEnabled public String artisanType { get; set; }
    @AuraEnabled public String externalProvinceId { get; set; }
    @AuraEnabled public String provinceName { get; set; }
    @AuraEnabled public String countryTag { get; set; }
    @AuraEnabled public String stateCode { get; set; }
    @AuraEnabled public Decimal spending { get; set; }
    @AuraEnabled public Decimal income { get; set; }
    @AuraEnabled public Decimal agdp { get; set; }
    @AuraEnabled public Decimal productionQuantity { get; set; }

    public ArtisanSummaryDTO() {
        this.spending = 0.0;
        this.income = 0.0;
        this.agdp = 0.0;
        this.productionQuantity = 0.0;
    }

    public ArtisanSummaryDTO(Artisan_Economy__c ae) {
        if (ae != null) {
            this.artisanEconomyId = ae.Id;
            this.uniqueSnapshotKey = ae.Unique_Snapshot_Key__c;
            this.artisanType = ae.Artisan_Type__c;
            if (ae.Province_Economy__r != null && ae.Province_Economy__r.Province__r != null) {
                this.externalProvinceId = ae.Province_Economy__r.Province__r.External_Province_Id__c;
                this.provinceName = ae.Province_Economy__r.Province__r.Name;
            }
            if (ae.Country_Economy__r != null) {
                this.countryTag = ae.Country_Economy__r.Country_Tag__c;
            }
            if (ae.State_Economy__r != null && ae.State_Economy__r.State__r != null) {
                this.stateCode = ae.State_Economy__r.State__r.State_Code__c;
            }
            this.spending = (ae.Spending__c != null) ? ae.Spending__c : 0.0;
            this.income = (ae.Income__c != null) ? ae.Income__c : 0.0;
            this.agdp = (ae.AGDP__c != null) ? ae.AGDP__c : 0.0;
            this.productionQuantity = (ae.Production_Quantity__c != null) ? ae.Production_Quantity__c : 0.0;
        }
    }
}
