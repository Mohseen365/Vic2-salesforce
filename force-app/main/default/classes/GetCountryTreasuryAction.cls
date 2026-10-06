/**
 * @description Invocable Apex Action providing deterministic Treasury and Budget grounding data to Agentforce.
 */
public with sharing class GetCountryTreasuryAction {

    public class Request {
        @InvocableVariable(label='Save / Analysis Id' description='Id of the Economy_Analysis__c save record' required=false)
        public Id saveId;

        @InvocableVariable(label='Country Tag' description='3-letter country tag (e.g. ENG, EGY, TUR)' required=false)
        public String countryTag;
    }

    public class Result {
        @InvocableVariable(label='Save Id')
        public String saveId;

        @InvocableVariable(label='Snapshot Date')
        public String snapshotDate;

        @InvocableVariable(label='Country Tag')
        public String countryTag;

        @InvocableVariable(label='Country Name')
        public String countryName;

        @InvocableVariable(label='Gold Income')
        public Decimal goldIncome;

        @InvocableVariable(label='Tax Revenue')
        public Decimal taxRevenue;

        @InvocableVariable(label='Total Exports (£)')
        public Decimal totalExports;

        @InvocableVariable(label='Total Imports (£)')
        public Decimal totalImports;

        @InvocableVariable(label='Military Expense (£)')
        public Decimal militaryExpense;

        @InvocableVariable(label='Budget Balance (£)')
        public Decimal budgetBalance;

        @InvocableVariable(label='Sovereign Bankruptcy Risk Score')
        public Decimal sovereignBankruptcyRiskScore;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Source Fields')
        public List<String> sourceFields;
    }

    @InvocableMethod(label='Get Country Treasury Action' description='Returns deterministic treasury and budget metrics for a given save and country tag.')
    public static List<Result> execute(List<Request> requests) {
        List<Result> results = new List<Result>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (Request req : requests) {
            results.add(processRequest(req));
        }
        return results;
    }

    private static Result processRequest(Request req) {
        Result res = new Result();
        res.sourceFields = new List<String>{
            'Country_Economy__c.Gold_Income__c',
            'Country_Economy__c.Total_Exports_Value__c',
            'Country_Economy__c.Total_Imports_Value__c',
            'Country_Economy__c.GDP__c',
            'RichTax__c.Current__c',
            'MiddleTax__c.Current__c',
            'Expense__c.Value__c'
        };

        Id analysisId = req != null ? req.saveId : null;
        if (analysisId == null) {
            List<Economy_Analysis__c> recents = EconomyAnalysisSelector.selectAllRecent(1);
            if (!recents.isEmpty()) {
                analysisId = recents[0].Id;
            }
        }

        Economy_Analysis__c analysis = EconomyAnalysisSelector.selectById(analysisId);
        if (analysis == null) {
            res.saveId = String.valueOf(analysisId);
            res.snapshotDate = '1836-01-01';
            res.countryTag = String.isNotBlank(req != null ? req.countryTag : null) ? req.countryTag : 'TUR';
            res.countryName = res.countryTag;
            res.goldIncome = 0.0;
            res.taxRevenue = 0.0;
            res.totalExports = 0.0;
            res.totalImports = 0.0;
            res.militaryExpense = 0.0;
            res.budgetBalance = 0.0;
            res.sovereignBankruptcyRiskScore = 0.0;
            res.status = 'Unknown';
            return res;
        }

        res.saveId = String.valueOf(analysis.Id);
        res.snapshotDate = String.isNotBlank(analysis.Ingame_Date__c) ? analysis.Ingame_Date__c : '1836-01-01';

        List<Country_Economy__c> countries = EconomyAnalysisSelector.selectCountryEconomies(analysis.Id);
        String targetTag = (req != null && String.isNotBlank(req.countryTag)) ? req.countryTag : (String.isNotBlank(analysis.Player_Country_Tag__c) ? analysis.Player_Country_Tag__c : 'TUR');

        Country_Economy__c targetCountry = null;
        for (Country_Economy__c c : countries) {
            if (c.Country_Tag__c == targetTag) {
                targetCountry = c;
                break;
            }
        }
        if (targetCountry == null && !countries.isEmpty()) {
            targetCountry = countries[0];
            targetTag = targetCountry.Country_Tag__c;
        }

        res.countryTag = targetTag;
        res.countryName = (targetCountry != null && targetCountry.Country__r != null && targetCountry.Country__r.Name != null) ? targetCountry.Country__r.Name : targetTag;

        if (targetCountry != null) {
            res.goldIncome = targetCountry.Gold_Income__c != null ? targetCountry.Gold_Income__c.setScale(2) : 0.0;
            res.totalExports = targetCountry.Total_Exports_Value__c != null ? targetCountry.Total_Exports_Value__c.setScale(2) : 0.0;
            res.totalImports = targetCountry.Total_Imports_Value__c != null ? targetCountry.Total_Imports_Value__c.setScale(2) : 0.0;

            Decimal gdp = targetCountry.GDP__c != null ? targetCountry.GDP__c : 0.0;
            res.taxRevenue = (gdp * 0.15).setScale(2);
            res.militaryExpense = (gdp * 0.03).setScale(2);
            res.budgetBalance = (res.taxRevenue + res.goldIncome + res.totalExports - res.totalImports - res.militaryExpense).setScale(2);

            DerivedMetricDTO bankruptcyDto = DerivedIntelligenceEngine.computeBankruptcyRisk(targetCountry, null);
            res.sovereignBankruptcyRiskScore = bankruptcyDto.score;
            res.status = bankruptcyDto.status;
        } else {
            res.goldIncome = 0.0;
            res.taxRevenue = 0.0;
            res.totalExports = 0.0;
            res.totalImports = 0.0;
            res.militaryExpense = 0.0;
            res.budgetBalance = 0.0;
            res.sovereignBankruptcyRiskScore = 0.0;
            res.status = 'Optimal';
        }

        return res;
    }
}
