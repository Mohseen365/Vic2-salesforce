public with sharing class FactorySummaryDTO {
    @AuraEnabled public Id factoryEconomyId { get; set; }
    @AuraEnabled public String uniqueSnapshotKey { get; set; }
    @AuraEnabled public String buildingType { get; set; }
    @AuraEnabled public Integer occurrenceIndex { get; set; }
    @AuraEnabled public Integer level { get; set; }
    @AuraEnabled public Long employees { get; set; }
    @AuraEnabled public Decimal outputQuantity { get; set; }
    @AuraEnabled public Decimal unsoldQuantity { get; set; }
    @AuraEnabled public Decimal capitalReserves { get; set; }
    @AuraEnabled public Decimal revenue { get; set; }
    @AuraEnabled public Decimal inputCost { get; set; }
    @AuraEnabled public Decimal wagesPaid { get; set; }
    @AuraEnabled public Decimal profit { get; set; }
    @AuraEnabled public Decimal factoryGdp { get; set; }
    @AuraEnabled public Decimal productivity { get; set; }
    @AuraEnabled public Decimal averageWage { get; set; }
    @AuraEnabled public Integer profitRank { get; set; }

    public FactorySummaryDTO() {
        this.occurrenceIndex = 1;
        this.level = 1;
        this.employees = 0;
        this.outputQuantity = 0.0;
        this.unsoldQuantity = 0.0;
        this.capitalReserves = 0.0;
        this.revenue = 0.0;
        this.inputCost = 0.0;
        this.wagesPaid = 0.0;
        this.profit = 0.0;
        this.factoryGdp = 0.0;
        this.productivity = 0.0;
        this.averageWage = 0.0;
        this.profitRank = 0;
    }

    public FactorySummaryDTO(Factory_Economy__c fe) {
        if (fe != null) {
            this.factoryEconomyId = fe.Id;
            this.uniqueSnapshotKey = fe.Unique_Snapshot_Key__c;
            this.buildingType = fe.Building_Type__c;
            this.occurrenceIndex = (fe.Occurrence_Index__c != null) ? fe.Occurrence_Index__c.intValue() : 1;
            this.level = (fe.Level__c != null) ? fe.Level__c.intValue() : 1;
            this.employees = (fe.Employees__c != null) ? fe.Employees__c.longValue() : 0;
            this.outputQuantity = (fe.Output_Quantity__c != null) ? fe.Output_Quantity__c : 0.0;
            this.unsoldQuantity = (fe.Unsold_Quantity__c != null) ? fe.Unsold_Quantity__c : 0.0;
            this.capitalReserves = (fe.Capital_Reserves__c != null) ? fe.Capital_Reserves__c : 0.0;
            this.revenue = (fe.Revenue__c != null) ? fe.Revenue__c : 0.0;
            this.inputCost = (fe.Input_Cost__c != null) ? fe.Input_Cost__c : 0.0;
            this.wagesPaid = (fe.Wages_Paid__c != null) ? fe.Wages_Paid__c : 0.0;
            this.profit = (fe.Profit__c != null) ? fe.Profit__c : 0.0;
            this.factoryGdp = (fe.Factory_GDP__c != null) ? fe.Factory_GDP__c : 0.0;
            this.productivity = (fe.Productivity__c != null) ? fe.Productivity__c : 0.0;
            this.averageWage = (fe.Average_Wage__c != null) ? fe.Average_Wage__c : 0.0;
            this.profitRank = (fe.Profit_Rank__c != null) ? fe.Profit_Rank__c.intValue() : 0;
        }
    }
}
