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
    static void testComputeMetricsAllMetrics() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id baseId = analyses[0].Id;
        Id currId = analyses[1].Id;

        Test.startTest();
        List<DerivedMetricDTO> metrics = DerivedIntelligenceEngine.computeMetrics(currId, baseId, 'TUR');
        Test.stopTest();

        System.assertEquals(6, metrics.size(), 'Expected 6 derived metric scorecards');

        Set<String> expectedMetricIds = new Set<String>{
            'MET-D-001', 'MET-D-002', 'MET-D-003', 'MET-D-006', 'MET-D-042', 'MET-D-041'
        };

        for (DerivedMetricDTO m : metrics) {
            System.assert(expectedMetricIds.contains(m.metricId), 'Unexpected metricId: ' + m.metricId);
            System.assertEquals('TUR', m.countryTag, 'Expected TUR country tag');
            System.assertNotEquals(null, m.score, 'Score should not be null');
            System.assertNotEquals(null, m.delta, 'Delta vs baseline should not be null');
            System.assert(m.components.size() > 0, 'Metric breakdown components should be populated');
        }
    }

    @isTest
    static void testComputeMetricsNullAndDefaultTag() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id currId = analyses[1].Id;

        Test.startTest();
        List<DerivedMetricDTO> emptyMetrics = DerivedIntelligenceEngine.computeMetrics(null, null, null);
        List<DerivedMetricDTO> defaultTagMetrics = DerivedIntelligenceEngine.computeMetrics(currId, null, null);
        Test.stopTest();

        System.assertEquals(0, emptyMetrics.size(), 'Null snapshotId should return empty list');
        System.assertEquals(6, defaultTagMetrics.size(), 'Default tag calculation should return 6 metrics');
    }

    @isTest
    static void testEvaluateAndPublishAnomalies() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id baseId = analyses[0].Id;
        Id currId = analyses[1].Id;

        Test.startTest();
        List<Economy_Anomaly_Event__e> events = DerivedIntelligenceEngine.evaluateAndPublishAnomalies(currId, baseId);
        List<Economy_Anomaly_Event__e> nullEvents = DerivedIntelligenceEngine.evaluateAndPublishAnomalies(null, null);
        Test.stopTest();

        System.assertNotEquals(0, events.size(), 'Expected anomaly events due to 50% GDP crash');
        System.assertEquals('GDP_CRASH', events[0].Anomaly_Type__c, 'Expected GDP_CRASH event');
        System.assertEquals('CRITICAL', events[0].Severity__c, 'Expected CRITICAL severity');
        System.assertEquals(0, nullEvents.size(), 'Null analysis should return empty list');
    }

    @isTest
    static void testControllerMethods() {
        List<Economy_Analysis__c> analyses = [SELECT Id FROM Economy_Analysis__c ORDER BY Ingame_Date__c ASC];
        Id currId = analyses[1].Id;

        Test.startTest();
        List<DerivedMetricDTO> metrics = DerivedIntelligenceController.getDerivedMetrics(currId, null, 'TUR');
        List<DerivedMetricDTO> nullMetrics = DerivedIntelligenceController.getDerivedMetrics(null, null, null);
        List<Economy_Anomaly_Event__e> events = DerivedIntelligenceController.evaluateAnomalies(currId, null);
        List<Economy_Anomaly_Event__e> nullEvents = DerivedIntelligenceController.evaluateAnomalies(null, null);
        Test.stopTest();

        System.assertEquals(6, metrics.size(), 'Controller should return 6 metrics');
        System.assertEquals(0, nullMetrics.size(), 'Controller should return empty list for null snapshotId');
        System.assertNotEquals(null, events, 'Controller should return event list');
        System.assertEquals(0, nullEvents.size(), 'Controller should return empty list for null snapshotId');
    }
}
