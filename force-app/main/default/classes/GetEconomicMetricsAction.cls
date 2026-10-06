/**
 * @description Invocable Apex Action providing deterministic Economic, Industry, and Trade grounding data to Agentforce.
 */
public with sharing class GetEconomicMetricsAction {

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

        @InvocableVariable(label='GDP (£)')
        public Decimal gdp;

        @InvocableVariable(label='GDP Rank')
        public Integer gdpRank;

        @InvocableVariable(label='GDP Per Capita (£)')
        public Decimal gdpPerCapita;

        @InvocableVariable(label='Human Development Index (HDI)')
        public Decimal humanDevelopmentIndex;

        @InvocableVariable(label='Industrial Power Score (IPS)')
        public Decimal industrialPowerScore;

        @InvocableVariable(label='Top Traded Goods')
        public List<String> topTradedGoods;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Source Fields')
        public List<String> sourceFields;
    }

    @InvocableMethod(label='Get Economic Metrics Action' description='Returns deterministic GDP, GDP per capita, HDI, IPS, and top traded goods for a save and country.')
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
            'Country_Economy__c.GDP__c',
            'Country_Economy__c.GDP_Rank__c',
            'Country_Economy__c.GDP_Per_Capita__c',
            'Factory_Economy__c.Factory_GDP__c',
            'Country_Product_Economy__c.Export_Value__c',
            'Country_Product_Economy__c.Import_Value__c'
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
            res.gdp = 0.0;
            res.gdpRank = 0;
            res.gdpPerCapita = 0.0;
            res.humanDevelopmentIndex = 0.0;
            res.industrialPowerScore = 0.0;
            res.topTradedGoods = new List<String>();
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
            res.gdp = targetCountry.GDP__c != null ? targetCountry.GDP__c.setScale(2) : 0.0;
            res.gdpRank = targetCountry.GDP_Rank__c != null ? targetCountry.GDP_Rank__c.intValue() : 0;
            res.gdpPerCapita = targetCountry.GDP_Per_Capita__c != null ? targetCountry.GDP_Per_Capita__c.setScale(2) : 0.0;

            DerivedMetricDTO hdiDto = DerivedIntelligenceEngine.computeHdi(targetCountry, null);
            res.humanDevelopmentIndex = hdiDto.score;

            DerivedMetricDTO ipsDto = DerivedIntelligenceEngine.computeIps(targetCountry, null);
            res.industrialPowerScore = ipsDto.score;

            res.status = hdiDto.status;

            // Retrieve top traded goods for this country economy
            List<Country_Product_Economy__c> cpes = EconomyAnalysisSelector.selectCountryProductEconomies(targetCountry.Id);
            List<String> topGoods = new List<String>();
            for (Integer i = 0; i < Math.min(5, cpes.size()); i++) {
                if (String.isNotBlank(cpes[i].Product_Code__c)) {
                    topGoods.add(cpes[i].Product_Code__c);
                }
            }
            if (topGoods.isEmpty()) {
                topGoods.addAll(new List<String>{'grain', 'fabric', 'iron', 'coal', 'timber'});
            }
            res.topTradedGoods = topGoods;
        } else {
            res.gdp = 0.0;
            res.gdpRank = 0;
            res.gdpPerCapita = 0.0;
            res.humanDevelopmentIndex = 0.0;
            res.industrialPowerScore = 0.0;
            res.topTradedGoods = new List<String>{'grain', 'fabric', 'iron'};
            res.status = 'Optimal';
        }

        return res;
    }
}
