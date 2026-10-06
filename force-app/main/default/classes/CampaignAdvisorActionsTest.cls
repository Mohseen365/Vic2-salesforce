/**
 * @description Comprehensive unit tests for Invocable Apex Actions:
 * GetCountryTreasuryAction, GetMilitaryStrengthAction, GetEconomicMetricsAction, and GetRebellionRiskAction.
 */
@isTest
private class CampaignAdvisorActionsTest {

    @testSetup
    static void setupTestData() {
        Country__c country = new Country__c(
            Tag__c = 'TUR',
            Name = 'Ottoman Empire',
            Flag_URL__c = 'https://example.com/tur.png'
        );
        insert country;

        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Name = 'Test Save 1836',
            Save_File_Name__c = 'tur_1836.v2',
            Ingame_Date__c = '1836-01-01',
            Player_Country_Tag__c = 'TUR',
            Total_World_GDP__c = 100000.0,
            Total_World_Population__c = 5000000.0,
            Import_Status__c = 'PUBLISHED'
        );
        insert analysis;

        Country_Economy__c countryEconomy = new Country_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country__c = country.Id,
            Country_Tag__c = 'TUR',
            Population__c = 12000000.0,
            GDP__c = 25000.0,
            GDP_Rank__c = 6,
            GDP_Per_Capita__c = 2.08,
            Gold_Income__c = 150.0,
            Total_Exports_Value__c = 4500.0,
            Total_Imports_Value__c = 3800.0,
            Factory_GDP__c = 8500.0,
            Unemployment_Rate__c = 4.2,
            Unique_Snapshot_Key__c = '18360101_TUR'
        );
        insert countryEconomy;
    }

    @isTest
    static void testGetCountryTreasuryAction() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        GetCountryTreasuryAction.Request req = new GetCountryTreasuryAction.Request();
        req.saveId = analysis.Id;
        req.countryTag = 'TUR';

        Test.startTest();
        List<GetCountryTreasuryAction.Result> results = GetCountryTreasuryAction.execute(new List<GetCountryTreasuryAction.Request>{req});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected 1 treasury action result');
        GetCountryTreasuryAction.Result res = results[0];
        System.assertEquals('TUR', res.countryTag, 'Country tag should match');
        System.assertEquals('1836-01-01', res.snapshotDate, 'Snapshot date should match');
        System.assertEquals(150.0, res.goldIncome, 'Gold income should match');
        System.assertNotEquals(0, res.sourceFields.size(), 'Source fields metadata should be attached');
    }

    @isTest
    static void testGetMilitaryStrengthAction() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        GetMilitaryStrengthAction.Request req = new GetMilitaryStrengthAction.Request();
        req.saveId = analysis.Id;
        req.countryTag = 'TUR';

        Test.startTest();
        List<GetMilitaryStrengthAction.Result> results = GetMilitaryStrengthAction.execute(new List<GetMilitaryStrengthAction.Request>{req});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected 1 military action result');
        GetMilitaryStrengthAction.Result res = results[0];
        System.assertEquals('TUR', res.countryTag, 'Country tag should match');
        System.assert(res.brigadeCount > 0, 'Brigade count should be greater than zero');
        System.assert(res.militaryStrengthComposite >= 0, 'MSC score should be non-negative');
    }

    @isTest
    static void testGetEconomicMetricsAction() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        GetEconomicMetricsAction.Request req = new GetEconomicMetricsAction.Request();
        req.saveId = analysis.Id;
        req.countryTag = 'TUR';

        Test.startTest();
        List<GetEconomicMetricsAction.Result> results = GetEconomicMetricsAction.execute(new List<GetEconomicMetricsAction.Request>{req});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected 1 economic action result');
        GetEconomicMetricsAction.Result res = results[0];
        System.assertEquals('TUR', res.countryTag, 'Country tag should match');
        System.assertEquals(25000.0, res.gdp, 'GDP should match setup value');
        System.assertEquals(6, res.gdpRank, 'GDP Rank should match setup value');
    }

    @isTest
    static void testGetRebellionRiskAction() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        GetRebellionRiskAction.Request req = new GetRebellionRiskAction.Request();
        req.saveId = analysis.Id;
        req.countryTag = 'TUR';

        Test.startTest();
        List<GetRebellionRiskAction.Result> results = GetRebellionRiskAction.execute(new List<GetRebellionRiskAction.Request>{req});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected 1 rebellion action result');
        GetRebellionRiskAction.Result res = results[0];
        System.assertEquals('TUR', res.countryTag, 'Country tag should match');
        System.assertEquals(4.2, res.unemploymentRate, 'Unemployment rate should match setup value');
        System.assert(res.rebellionRiskIndex >= 0, 'Rebellion risk index should be non-negative');
    }

    @isTest
    static void testNullInputsHandling() {
        Test.startTest();
        List<GetCountryTreasuryAction.Result> tRes = GetCountryTreasuryAction.execute(new List<GetCountryTreasuryAction.Request>{new GetCountryTreasuryAction.Request()});
        List<GetMilitaryStrengthAction.Result> mRes = GetMilitaryStrengthAction.execute(new List<GetMilitaryStrengthAction.Request>{new GetMilitaryStrengthAction.Request()});
        List<GetEconomicMetricsAction.Result> eRes = GetEconomicMetricsAction.execute(new List<GetEconomicMetricsAction.Request>{new GetEconomicMetricsAction.Request()});
        List<GetRebellionRiskAction.Result> rRes = GetRebellionRiskAction.execute(new List<GetRebellionRiskAction.Request>{new GetRebellionRiskAction.Request()});
        Test.stopTest();

        System.assertEquals(1, tRes.size(), 'Treasury action should handle null inputs gracefully');
        System.assertEquals(1, mRes.size(), 'Military action should handle null inputs gracefully');
        System.assertEquals(1, eRes.size(), 'Economic action should handle null inputs gracefully');
        System.assertEquals(1, rRes.size(), 'Rebellion action should handle null inputs gracefully');
    }
}
