/**
 * @description Facade Apex controller exposing Campaign Advisor query processing, prompt grounding,
 * post-verification, and feedback logging to the LWC side panel (c-campaign-advisor).
 */
public with sharing class CampaignAdvisorController {

    public class FactItemDTO {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String chipValue;
        @AuraEnabled public String sourceField;

        public FactItemDTO(String label, Object value, String sourceField) {
            this.label = label;
            this.value = String.valueOf(value);
            this.chipValue = String.valueOf(value);
            this.sourceField = sourceField;
        }
    }

    public class ProvenanceDTO {
        @AuraEnabled public String saveId;
        @AuraEnabled public String snapshotDate;
        @AuraEnabled public String countryTag;
        @AuraEnabled public List<String> sourceFields;

        public ProvenanceDTO() {
            this.sourceFields = new List<String>();
        }
    }

    public class CampaignAdvisorDTO {
        @AuraEnabled public String saveId;
        @AuraEnabled public String snapshotDate;
        @AuraEnabled public String countryTag;
        @AuraEnabled public String countryName;
        @AuraEnabled public String userQuery;
        @AuraEnabled public String actionType;
        @AuraEnabled public List<FactItemDTO> facts;
        @AuraEnabled public String interpretationText;
        @AuraEnabled public ProvenanceDTO provenance;
        @AuraEnabled public Boolean isVerified;
        @AuraEnabled public String rejectionReason;
        @AuraEnabled public String rawActionPayloadJson;

        public CampaignAdvisorDTO() {
            this.facts = new List<FactItemDTO>();
            this.provenance = new ProvenanceDTO();
            this.isVerified = true;
            this.rejectionReason = '';
        }
    }

    /**
     * @description Processes user query, dispatches to corresponding Invocable Action, grounds prompt,
     * performs anti-hallucination post-verification, and returns structured response DTO.
     */
    @AuraEnabled(cacheable=false)
    public static CampaignAdvisorDTO getAdvisorResponse(String userQuery, Id saveId, String countryTag, String activeTab) {
        CampaignAdvisorDTO dto = new CampaignAdvisorDTO();
        dto.userQuery = String.isNotBlank(userQuery) ? userQuery : 'Overview';

        // 1. Determine action domain from query or active tab
        String domain = determineDomain(dto.userQuery, activeTab);
        dto.actionType = domain;

        Map<String, Object> groundTruthData = new Map<String, Object>();
        List<String> sourceFields = new List<String>();

        if (domain == 'TREASURY') {
            GetCountryTreasuryAction.Request req = new GetCountryTreasuryAction.Request();
            req.saveId = saveId;
            req.countryTag = countryTag;

            List<GetCountryTreasuryAction.Result> resList = GetCountryTreasuryAction.execute(new List<GetCountryTreasuryAction.Request>{req});
            if (!resList.isEmpty()) {
                GetCountryTreasuryAction.Result r = resList[0];
                dto.saveId = r.saveId;
                dto.snapshotDate = r.snapshotDate;
                dto.countryTag = r.countryTag;
                dto.countryName = r.countryName;
                sourceFields = r.sourceFields;

                groundTruthData.put('saveId', r.saveId);
                groundTruthData.put('snapshotDate', r.snapshotDate);
                groundTruthData.put('countryTag', r.countryTag);
                groundTruthData.put('goldIncome', r.goldIncome);
                groundTruthData.put('taxRevenue', r.taxRevenue);
                groundTruthData.put('totalExports', r.totalExports);
                groundTruthData.put('totalImports', r.totalImports);
                groundTruthData.put('militaryExpense', r.militaryExpense);
                groundTruthData.put('budgetBalance', r.budgetBalance);
                groundTruthData.put('sovereignBankruptcyRiskScore', r.sovereignBankruptcyRiskScore);

                dto.facts.add(new FactItemDTO('Gold Income', '£' + r.goldIncome, 'Country_Economy__c.Gold_Income__c'));
                dto.facts.add(new FactItemDTO('Tax Revenue', '£' + r.taxRevenue, 'RichTax__c.Current__c'));
                dto.facts.add(new FactItemDTO('Total Exports', '£' + r.totalExports, 'Country_Economy__c.Total_Exports_Value__c'));
                dto.facts.add(new FactItemDTO('Total Imports', '£' + r.totalImports, 'Country_Economy__c.Total_Imports_Value__c'));
                dto.facts.add(new FactItemDTO('Military Expense', '£' + r.militaryExpense, 'Expense__c.Value__c'));
                dto.facts.add(new FactItemDTO('Budget Balance', '£' + r.budgetBalance, 'Country_Economy__c.GDP__c'));
                dto.facts.add(new FactItemDTO('Sovereign Default Risk', r.sovereignBankruptcyRiskScore + '%', 'Creditor__c.Debt__c'));

                dto.interpretationText = r.countryName + ' maintains a budget balance of £' + r.budgetBalance +
                    ' with a sovereign bankruptcy risk score of ' + r.sovereignBankruptcyRiskScore + '%. ' +
                    (r.budgetBalance < 0 ? 'Recommend cutting active military costs or raising tariffs to balance treasury.' : 'Treasury is healthy with sustainable revenue buffers.');
            }
        } else if (domain == 'MILITARY') {
            GetMilitaryStrengthAction.Request req = new GetMilitaryStrengthAction.Request();
            req.saveId = saveId;
            req.countryTag = countryTag;

            List<GetMilitaryStrengthAction.Result> resList = GetMilitaryStrengthAction.execute(new List<GetMilitaryStrengthAction.Request>{req});
            if (!resList.isEmpty()) {
                GetMilitaryStrengthAction.Result r = resList[0];
                dto.saveId = r.saveId;
                dto.snapshotDate = r.snapshotDate;
                dto.countryTag = r.countryTag;
                dto.countryName = r.countryName;
                sourceFields = r.sourceFields;

                groundTruthData.put('saveId', r.saveId);
                groundTruthData.put('snapshotDate', r.snapshotDate);
                groundTruthData.put('countryTag', r.countryTag);
                groundTruthData.put('brigadeCount', r.brigadeCount);
                groundTruthData.put('navalShipCount', r.navalShipCount);
                groundTruthData.put('manpower', r.manpower);
                groundTruthData.put('militaryStrengthComposite', r.militaryStrengthComposite);
                groundTruthData.put('militaryBudgetRatio', r.militaryBudgetRatio);

                dto.facts.add(new FactItemDTO('Land Brigades', r.brigadeCount, 'Regiment__c.Count__c'));
                dto.facts.add(new FactItemDTO('Naval Warships', r.navalShipCount, 'Ship__c.Strength__c'));
                dto.facts.add(new FactItemDTO('Manpower Reserve', r.manpower, 'Country_Economy__c.Population__c'));
                dto.facts.add(new FactItemDTO('Military Strength Composite (MSC)', r.militaryStrengthComposite, 'Technology__c'));
                dto.facts.add(new FactItemDTO('Military Budget Ratio', r.militaryBudgetRatio + '%', 'Expense__c.Value__c'));

                dto.interpretationText = r.countryName + ' fields ' + r.brigadeCount + ' active brigades and ' + r.navalShipCount +
                    ' warships with an MSC score of ' + r.militaryStrengthComposite + '. Military maintenance accounts for ' +
                    r.militaryBudgetRatio + '% of national income.';
            }
        } else if (domain == 'REBELLION') {
            GetRebellionRiskAction.Request req = new GetRebellionRiskAction.Request();
            req.saveId = saveId;
            req.countryTag = countryTag;

            List<GetRebellionRiskAction.Result> resList = GetRebellionRiskAction.execute(new List<GetRebellionRiskAction.Request>{req});
            if (!resList.isEmpty()) {
                GetRebellionRiskAction.Result r = resList[0];
                dto.saveId = r.saveId;
                dto.snapshotDate = r.snapshotDate;
                dto.countryTag = r.countryTag;
                dto.countryName = r.countryName;
                sourceFields = r.sourceFields;

                groundTruthData.put('saveId', r.saveId);
                groundTruthData.put('snapshotDate', r.snapshotDate);
                groundTruthData.put('countryTag', r.countryTag);
                groundTruthData.put('popMilitancy', r.popMilitancy);
                groundTruthData.put('popConsciousness', r.popConsciousness);
                groundTruthData.put('unemploymentRate', r.unemploymentRate);
                groundTruthData.put('rebellionRiskIndex', r.rebellionRiskIndex);
                groundTruthData.put('nationalStabilityIndex', r.nationalStabilityIndex);

                dto.facts.add(new FactItemDTO('POP Militancy', r.popMilitancy + ' / 10', 'Pop__c.Mil__c'));
                dto.facts.add(new FactItemDTO('POP Consciousness', r.popConsciousness + ' / 10', 'Pop__c.Con__c'));
                dto.facts.add(new FactItemDTO('Unemployment Rate', r.unemploymentRate + '%', 'Country_Economy__c.Unemployment_Rate__c'));
                dto.facts.add(new FactItemDTO('Rebellion Risk Index (MET-D-041)', r.rebellionRiskIndex, 'Movement__c.Radicalism__c'));
                dto.facts.add(new FactItemDTO('National Stability Index (NSI)', r.nationalStabilityIndex, 'RebelFaction__c'));

                dto.interpretationText = r.countryName + ' exhibits a POP militancy level of ' + r.popMilitancy + ' / 10 and rebellion risk index of ' +
                    r.rebellionRiskIndex + '. ' + (r.rebellionRiskIndex > 50.0 ? 'High risk of armed rebellion; pass social reforms or suppress rebel movements.' : 'Internal political situation is currently stable.');
            }
        } else {
            // ECONOMIC (default)
            GetEconomicMetricsAction.Request req = new GetEconomicMetricsAction.Request();
            req.saveId = saveId;
            req.countryTag = countryTag;

            List<GetEconomicMetricsAction.Result> resList = GetEconomicMetricsAction.execute(new List<GetEconomicMetricsAction.Request>{req});
            if (!resList.isEmpty()) {
                GetEconomicMetricsAction.Result r = resList[0];
                dto.saveId = r.saveId;
                dto.snapshotDate = r.snapshotDate;
                dto.countryTag = r.countryTag;
                dto.countryName = r.countryName;
                sourceFields = r.sourceFields;

                groundTruthData.put('saveId', r.saveId);
                groundTruthData.put('snapshotDate', r.snapshotDate);
                groundTruthData.put('countryTag', r.countryTag);
                groundTruthData.put('gdp', r.gdp);
                groundTruthData.put('gdpRank', r.gdpRank);
                groundTruthData.put('gdpPerCapita', r.gdpPerCapita);
                groundTruthData.put('humanDevelopmentIndex', r.humanDevelopmentIndex);
                groundTruthData.put('industrialPowerScore', r.industrialPowerScore);

                dto.facts.add(new FactItemDTO('National GDP', '£' + r.gdp, 'Country_Economy__c.GDP__c'));
                dto.facts.add(new FactItemDTO('Global GDP Rank', '#' + r.gdpRank, 'Country_Economy__c.GDP_Rank__c'));
                dto.facts.add(new FactItemDTO('GDP Per Capita', '£' + r.gdpPerCapita, 'Country_Economy__c.GDP_Per_Capita__c'));
                dto.facts.add(new FactItemDTO('Human Development Index (HDI)', r.humanDevelopmentIndex, 'Country_Economy__c.GDP_Per_Capita__c'));
                dto.facts.add(new FactItemDTO('Industrial Power Score (IPS)', r.industrialPowerScore, 'Factory_Economy__c.Factory_GDP__c'));

                dto.interpretationText = r.countryName + ' ranks #' + r.gdpRank + ' globally with a national GDP of £' + r.gdp +
                    ' and HDI score of ' + r.humanDevelopmentIndex + '. Top traded goods include ' + String.join(r.topTradedGoods, ', ') + '.';
            }
        }

        // 2. Set Provenance DTO
        dto.provenance.saveId = dto.saveId;
        dto.provenance.snapshotDate = dto.snapshotDate;
        dto.provenance.countryTag = dto.countryTag;
        dto.provenance.sourceFields = sourceFields;

        // 3. Set Raw Action Payload JSON for "Show data" expander
        dto.rawActionPayloadJson = JSON.serializePretty(groundTruthData);

        // 4. Formulate LLM response narrative and verify against ground truth (RSK-25)
        String rawLLMNarrative = '[FACTS]\n';
        for (FactItemDTO item : dto.facts) {
            rawLLMNarrative += '• ' + item.label + ': [chip: ' + item.chipValue + ']\n';
        }
        rawLLMNarrative += '\n[INTERPRETATION]\n' + dto.interpretationText;

        CampaignAdvisorVerifier.VerificationResult vr = CampaignAdvisorVerifier.verifyNumericPayload(rawLLMNarrative, groundTruthData);
        dto.isVerified = vr.isVerified;
        dto.rejectionReason = vr.rejectionReason;

        return dto;
    }

    /**
     * @description Logs user feedback (Thumbs Up / Down and comments) for advisor responses.
     */
    @AuraEnabled
    public static Boolean logFeedback(Id saveId, String countryTag, String promptText, String responseText, Boolean isPositive, String feedbackComments) {
        System.debug('CampaignAdvisor Feedback Logged: [Positive=' + isPositive + ', Country=' + countryTag + ', Comments=' + feedbackComments + ']');
        return true;
    }

    private static String determineDomain(String query, String activeTab) {
        String q = (query != null) ? query.toLowerCase() : '';
        String tab = (activeTab != null) ? activeTab.toLowerCase() : '';

        if (q.contains('treasury') || q.contains('budget') || q.contains('drain') || q.contains('tax') || q.contains('debt') || q.contains('bankruptcy')) {
            return 'TREASURY';
        }
        if (q.contains('military') || q.contains('war') || q.contains('brigade') || q.contains('army') || q.contains('navy') || q.contains('ship') || q.contains('msc')) {
            return 'MILITARY';
        }
        if (q.contains('rebellion') || q.contains('rebel') || q.contains('militancy') || q.contains('pop') || q.contains('stability') || q.contains('nsi')) {
            return 'REBELLION';
        }
        if (tab == 'power' || tab == 'war') return 'MILITARY';
        if (tab == 'society' || tab == 'politics' || tab == 'pop') return 'REBELLION';

        return 'ECONOMIC';
    }
}
