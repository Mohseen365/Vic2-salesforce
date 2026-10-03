public class AnalysisSummaryDTO {
    @AuraEnabled public Id analysisId { get; set; }
    @AuraEnabled public String saveFileName { get; set; }
    @AuraEnabled public String sourceSaveFileName { get; set; }
    @AuraEnabled public Date ingameDate { get; set; }
    @AuraEnabled public Datetime analysisTimestamp { get; set; }
    @AuraEnabled public String playerCountryTag { get; set; }
    @AuraEnabled public Decimal totalWorldGdp { get; set; }
    @AuraEnabled public Decimal totalWorldPopulation { get; set; }
    @AuraEnabled public Decimal totalWorldImports { get; set; }
    @AuraEnabled public Decimal totalWorldExports { get; set; }
    @AuraEnabled public String importStatus { get; set; }

    public AnalysisSummaryDTO() {
        this.totalWorldGdp = 0.0;
        this.totalWorldPopulation = 0;
        this.totalWorldImports = 0.0;
        this.totalWorldExports = 0.0;
    }

    public AnalysisSummaryDTO(Economy_Analysis__c ea) {
        if (ea != null) {
            this.analysisId = ea.Id;
            this.saveFileName = ea.Save_File_Name__c;
            this.sourceSaveFileName = ea.Source_Save_File_Name__c;
            this.ingameDate = ea.Ingame_Date__c;
            this.analysisTimestamp = ea.Analysis_Timestamp__c;
            this.playerCountryTag = ea.Player_Country_Tag__c;
            this.totalWorldGdp = ea.Total_World_GDP__c;
            this.totalWorldPopulation = ea.Total_World_Population__c;
            this.totalWorldImports = ea.Total_World_Imports__c;
            this.totalWorldExports = ea.Total_World_Exports__c;
            this.importStatus = ea.Import_Status__c;
        }
    }
}
