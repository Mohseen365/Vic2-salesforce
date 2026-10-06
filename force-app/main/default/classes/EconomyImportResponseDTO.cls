/**
 * @description Response DTO returned by EconomyImportService and EconomyImportRestResource.
 */
public with sharing class EconomyImportResponseDTO {
    @AuraEnabled public String analysisId { get; set; }
    @AuraEnabled public String importRunId { get; set; }
    @AuraEnabled public String importStatus { get; set; }
    @AuraEnabled public Integer chunkSeq { get; set; }
    @AuraEnabled public Integer totalChunks { get; set; }
    @AuraEnabled public String checksumStatus { get; set; }
    @AuraEnabled public Long calculatedPopChecksum { get; set; }
    @AuraEnabled public Long expectedPopChecksum { get; set; }
    @AuraEnabled public Map<String, Integer> recordCounts { get; set; }
    @AuraEnabled public String errorMessage { get; set; }
    @AuraEnabled public List<String> warnings { get; set; }
    @AuraEnabled public Boolean success { get; set; }

    public EconomyImportResponseDTO() {
        this.recordCounts = new Map<String, Integer>{
            'countries' => 0,
            'products' => 0,
            'countryProducts' => 0,
            'provinces' => 0,
            'states' => 0,
            'factories' => 0,
            'artisans' => 0
        };
        this.warnings = new List<String>();
        this.success = true;
    }
}
