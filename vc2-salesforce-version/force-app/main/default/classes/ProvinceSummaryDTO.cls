public with sharing class ProvinceSummaryDTO {
    @AuraEnabled public Id provinceEconomyId { get; set; }
    @AuraEnabled public String externalProvinceId { get; set; }
    @AuraEnabled public Decimal population { get; set; }
    @AuraEnabled public Decimal rgoProduction { get; set; }

    public ProvinceSummaryDTO() {
        this.population = 0;
        this.rgoProduction = 0.0;
    }

    public ProvinceSummaryDTO(Province_Economy__c pe) {
        if (pe != null) {
            this.provinceEconomyId = pe.Id;
            if (pe.Province__r != null) {
                this.externalProvinceId = pe.Province__r.External_Province_Id__c;
            }
            this.population = pe.Population__c;
            this.rgoProduction = pe.RGO_Production__c;
        }
    }
}
