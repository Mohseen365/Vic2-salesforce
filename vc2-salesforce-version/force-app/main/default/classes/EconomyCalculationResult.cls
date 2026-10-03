/**
 * @description DTO wrapper encapsulating computed calculation results for
 * Country_Product_Economy__c, Country_Economy__c, and Economy_Analysis__c entities.
 * Kept pure and side-effect free before DML persistence.
 */
public class EconomyCalculationResult {

    /**
     * @description Calculation results for a single Country_Product_Economy__c junction.
     */
    public class JunctionResult {
        public Id junctionId { get; set; }
        public Decimal soldUnits { get; set; }
        public Decimal totalSupplyPounds { get; set; }
        public Decimal actualSupplyPounds { get; set; }
        public Decimal actualDemandPounds { get; set; }
        public Decimal importValue { get; set; }
        public Decimal exportValue { get; set; }
        public Decimal domesticSalesValue { get; set; }
        public Decimal gdpContribution { get; set; }

        public JunctionResult() {
            this.soldUnits = 0.0;
            this.totalSupplyPounds = 0.0;
            this.actualSupplyPounds = 0.0;
            this.actualDemandPounds = 0.0;
            this.importValue = 0.0;
            this.exportValue = 0.0;
            this.domesticSalesValue = 0.0;
            this.gdpContribution = 0.0;
        }
    }

    /**
     * @description Calculation results for a single Country_Economy__c snapshot.
     */
    public class CountryResult {
        public Id countryEconomyId { get; set; }
        public String countryTag { get; set; }
        public Decimal gdp { get; set; }
        public Integer gdpRank { get; set; }
        public Decimal totalImportsValue { get; set; }
        public Decimal totalExportsValue { get; set; }

        public CountryResult() {
            this.gdp = 0.0;
            this.gdpRank = 0;
            this.totalImportsValue = 0.0;
            this.totalExportsValue = 0.0;
        }
    }

    /**
     * @description Calculation results for the top-level Economy_Analysis__c header.
     */
    public class AnalysisResult {
        public Id analysisId { get; set; }
        public Decimal totalWorldImports { get; set; }
        public Decimal totalWorldExports { get; set; }

        public AnalysisResult() {
            this.totalWorldImports = 0.0;
            this.totalWorldExports = 0.0;
        }
    }

    public AnalysisResult analysisResult { get; set; }
    public Map<Id, CountryResult> countryResultsById { get; set; }
    public Map<Id, JunctionResult> junctionResultsById { get; set; }

    public EconomyCalculationResult() {
        this.analysisResult = new AnalysisResult();
        this.countryResultsById = new Map<Id, CountryResult>();
        this.junctionResultsById = new Map<Id, JunctionResult>();
    }
}
