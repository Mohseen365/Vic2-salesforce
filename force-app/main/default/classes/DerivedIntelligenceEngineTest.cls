@isTest
private class DerivedIntelligenceEngineTest {

    @testSetup
    static void setupTestData() {
        Economy_Analysis__c baseAnalysis = new Economy_Analysis__c(
            Save_File_Name__c = 'base_1836.v2',
            Ingame_Date__c = '1836.1.1',
            Import_Status__c = 'COMPLETED',
            Total_World_GDP__c = 10000.0,
            Total_World_Population__c = 5000000
        );
        insert baseAnalysis;

        Economy_Analysis__c currAnalysis = new Economy_Analysis__c(
            Save_File_Name__c = 'current_1837.v2',
            Ingame_Date__c = '1837.1.1',
            Import_Status__c = 'COMPLETED',
            Total_World_GDP__c = 6000.0,
            Total_World_Population__c = 5000000
        );
        insert currAnalysis;

        Country__c tur = new Country__c(
            Name = 'Ottoman Empire',
            Country_Tag__c = 'TUR'
        );
        insert tur;

        Country_Economy__c baseCountry = new Country_Economy__c(
            Economy_Analysis__c = baseAnalysis.Id,
            Country__c = tur.Id,
            Country_Tag__c = 'TUR',
            GDP__c = 2000.0,
            GDP_Rank__c = 5,
            GDP_Per_Capita__c = 2.50,
            Factory_GDP__c = 500.0,
            Employment_Factory__c = 1000.0,
            Unemployment_Rate_Factory__c = 10.0,
            Unemployment_Rate__c = 5.0,
            Total_Exports_Value__c = 300.0
        );
        insert baseCountry;

        Country_Economy__c currCountry = new Country_Economy__c(
            Economy_Analysis__c = currAnalysis.Id,
            Country__c = tur.Id,
            Country_Tag__c = 'TUR',
            GDP__c = 1000.0, // 50% crash
            GDP_Rank__c = 8,
            GDP_Per_Capita__c = 1.25,
            Factory_GDP__c = 250.0,
            Employment_Factory__c = 500.0,
            Unemployment_Rate_Factory__c = 25.0,
            Unemployment_Rate__c = 15.0,
            Total_Exports_Value__c = 100.0
        );
        insert currCountry;
    }

    @isTest
    static void testComputeMetrics() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id baseId = analyses[0].Id;
        Id currId = analyses[1].Id;

        Test.startTest();
        List<DerivedMetricDTO> metrics = DerivedIntelligenceEngine.computeMetrics(currId, baseId, 'TUR');
        Test.stopTest();

        System.assertNotEquals(0, metrics.size(), 'Expected derived metrics to be computed');

        DerivedMetricDTO hdi = null;
        for (DerivedMetricDTO m : metrics) {
            if (m.metricId == 'MET-D-001') {
                hdi = m;
                break;
            }
        }
        System.assertNotEquals(null, hdi, 'Expected HDI metric');
        System.assertEquals('TUR', hdi.countryTag, 'Expected TUR tag');
        System.assertNotEquals(0.0, hdi.score, 'Expected non-zero HDI score');
        System.assertEquals('v1.0.0', hdi.formulaVersion, 'Expected version v1.0.0');
    }

    @isTest
    static void testEvaluateAndPublishAnomalies() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id baseId = analyses[0].Id;
        Id currId = analyses[1].Id;

        Test.startTest();
        List<Economy_Anomaly_Event__e> events = DerivedIntelligenceEngine.evaluateAndPublishAnomalies(currId, baseId);
        Test.stopTest();

        System.assertNotEquals(0, events.size(), 'Expected anomaly events due to 50% GDP crash');
        System.assertEquals('GDP_CRASH', events[0].Anomaly_Type__c, 'Expected GDP_CRASH event');
        System.assertEquals('CRITICAL', events[0].Severity__c, 'Expected CRITICAL severity');
    }

    @isTest
    static void testControllerMethods() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id currId = analyses[1].Id;

        Test.startTest();
        List<DerivedMetricDTO> metrics = DerivedIntelligenceController.getDerivedMetrics(currId, null, 'TUR');
        List<Economy_Anomaly_Event__e> events = DerivedIntelligenceController.evaluateAnomalies(currId, null);
        Test.stopTest();

        System.assertNotEquals(0, metrics.size(), 'Controller should return metrics');
        System.assertNotEquals(null, events, 'Controller should return event list');
    }
}
