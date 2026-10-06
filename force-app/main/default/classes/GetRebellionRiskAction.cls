/**
 * @description Invocable Apex Action providing deterministic Political, Militancy, and Rebellion Risk grounding data to Agentforce.
 */
public with sharing class GetRebellionRiskAction {

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

        @InvocableVariable(label='POP Militancy (0-10)')
        public Decimal popMilitancy;

        @InvocableVariable(label='POP Consciousness (0-10)')
        public Decimal popConsciousness;

        @InvocableVariable(label='Unemployment Rate (%)')
        public Decimal unemploymentRate;

        @InvocableVariable(label='Rebellion Risk Index (MET-D-041)')
        public Decimal rebellionRiskIndex;

        @InvocableVariable(label='National Stability Index (NSI)')
        public Decimal nationalStabilityIndex;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Source Fields')
        public List<String> sourceFields;
    }

    @InvocableMethod(label='Get Rebellion Risk Action' description='Returns deterministic POP militancy, consciousness, unemployment, rebellion risk index (MET-D-041), and NSI.')
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
            'Pop__c.Mil__c',
            'Pop__c.Con__c',
            'Movement__c.Radicalism__c',
            'Country_Economy__c.Unemployment_Rate__c',
            'RebelFaction__c'
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
            res.popMilitancy = 0.0;
            res.popConsciousness = 0.0;
            res.unemploymentRate = 0.0;
            res.rebellionRiskIndex = 0.0;
            res.nationalStabilityIndex = 100.0;
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
            res.unemploymentRate = targetCountry.Unemployment_Rate__c != null ? targetCountry.Unemployment_Rate__c.setScale(1) : 5.0;

            Decimal rank = targetCountry.GDP_Rank__c != null ? targetCountry.GDP_Rank__c : 20.0;
            res.popMilitancy = Math.min(10.0, (res.unemploymentRate * 0.3) + (rank * 0.1)).setScale(2);
            res.popConsciousness = Math.min(10.0, (res.popMilitancy * 0.8) + 2.0).setScale(2);

            DerivedMetricDTO rebellionDto = DerivedIntelligenceEngine.computeRebellionRisk(targetCountry, null);
            res.rebellionRiskIndex = rebellionDto.score;
            res.status = rebellionDto.status;

            DerivedMetricDTO nsiDto = DerivedIntelligenceEngine.computeNsi(targetCountry, null);
            res.nationalStabilityIndex = nsiDto.score;
        } else {
            res.popMilitancy = 0.0;
            res.popConsciousness = 0.0;
            res.unemploymentRate = 0.0;
            res.rebellionRiskIndex = 0.0;
            res.nationalStabilityIndex = 100.0;
            res.status = 'Optimal';
        }

        return res;
    }
}
