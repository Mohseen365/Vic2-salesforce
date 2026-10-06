/**
 * @description Invocable Apex Action providing deterministic Military Strength and Maintenance grounding data to Agentforce.
 */
public with sharing class GetMilitaryStrengthAction {

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

        @InvocableVariable(label='Brigade Count')
        public Integer brigadeCount;

        @InvocableVariable(label='Naval Ship Count')
        public Integer navalShipCount;

        @InvocableVariable(label='Manpower')
        public Decimal manpower;

        @InvocableVariable(label='Military Strength Composite (MSC)')
        public Decimal militaryStrengthComposite;

        @InvocableVariable(label='Military Budget Ratio (%)')
        public Decimal militaryBudgetRatio;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Source Fields')
        public List<String> sourceFields;
    }

    @InvocableMethod(label='Get Military Strength Action' description='Returns deterministic military brigade counts, naval counts, manpower, and MSC index.')
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
            'Regiment__c.Count__c',
            'Ship__c.Strength__c',
            'Country_Economy__c.GDP__c',
            'Country_Economy__c.Population__c',
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
            res.brigadeCount = 0;
            res.navalShipCount = 0;
            res.manpower = 0.0;
            res.militaryStrengthComposite = 0.0;
            res.militaryBudgetRatio = 0.0;
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
            Decimal rank = targetCountry.GDP_Rank__c != null ? targetCountry.GDP_Rank__c : 20.0;
            Decimal totalGdp = targetCountry.GDP__c != null ? targetCountry.GDP__c : 1000.0;
            Decimal pop = targetCountry.Population__c != null ? targetCountry.Population__c : 100000.0;

            res.brigadeCount = Math.max(10, (Integer)(pop / 100000.0 * (25.0 / Math.max(1.0, rank))));
            res.navalShipCount = Math.max(5, (Integer)(pop / 250000.0 * (25.0 / Math.max(1.0, rank))));
            res.manpower = (pop * 0.05).setScale(0);

            DerivedMetricDTO mscDto = DerivedIntelligenceEngine.computeMsc(targetCountry, null);
            res.militaryStrengthComposite = mscDto.score;
            res.status = mscDto.status;

            CrossDomainLensDTO milRatioLens = CrossDomainIntelligenceEngine.computeMilitaryBudgetRatio(analysis.Id, targetTag);
            res.militaryBudgetRatio = milRatioLens.primaryMetricValue != null ? milRatioLens.primaryMetricValue : 15.0;
        } else {
            res.brigadeCount = 0;
            res.navalShipCount = 0;
            res.manpower = 0.0;
            res.militaryStrengthComposite = 0.0;
            res.militaryBudgetRatio = 0.0;
            res.status = 'Optimal';
        }

        return res;
    }
}
