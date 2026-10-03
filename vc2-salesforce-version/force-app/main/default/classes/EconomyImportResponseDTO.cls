/**
 * @description Response DTO returned by EconomyImportService and EconomyImportRestResource.
 */
public with sharing class EconomyImportResponseDTO {
    @AuraEnabled public String analysisId { get; set; }
    @AuraEnabled public String importStatus { get; set; }
    @AuraEnabled public Map<String, Integer> recordCounts { get; set; }
    @AuraEnabled public String errorMessage { get; set; }
    @AuraEnabled public Boolean success { get; set; }

    public EconomyImportResponseDTO() {
        this.recordCounts = new Map<String, Integer>{
            'countries' => 0,
            'products' => 0,
            'countryProducts' => 0,
            'provinces' => 0
        };
        this.success = true;
    }
}
