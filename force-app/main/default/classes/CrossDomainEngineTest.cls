/**
 * @description Test class for CrossDomainIntelligenceEngine and CrossDomainAnalysisController.
 * Validates cross-domain calculations against the golden dataset egypt.v2 structure.
 */
@isTest
private class CrossDomainEngineTest {

    @TestSetup
    static void setupTestData() {
        // Create test Economy Analysis
        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Name = 'egypt.v2 Analysis',
            Save_File_Name__c = 'egypt.v2',
            Source_Save_File_Name__c = 'egypt.v2',
            Ingame_Date__c = '1864.3.1',
            Analysis_Timestamp__c = System.now(),
            Player_Country_Tag__c = 'TUR',
            Total_World_GDP__c = 100000000.0,
            Import_Status__c = 'COMPLETED'
        );
        insert analysis;

        // Base Economy Analysis for comparison
        Economy_Analysis__c baseAnalysis = new Economy_Analysis__c(
            Name = 'egypt.v2 Base Analysis',
            Save_File_Name__c = 'egypt_base.v2',
            Source_Save_File_Name__c = 'egypt_base.v2',
            Ingame_Date__c = '1861.1.1',
            Analysis_Timestamp__c = System.now().addDays(-365),
            Player_Country_Tag__c = 'TUR',
            Total_World_GDP__c = 95000000.0,
            Import_Status__c = 'COMPLETED'
        );
        insert baseAnalysis;

        // Master Country records
        Country__c tur = new Country__c(Tag__c = 'TUR', Name = 'Ottoman Empire');
        Country__c eng = new Country__c(Tag__c = 'ENG', Name = 'United Kingdom');
        insert new List<Country__c>{ tur, eng };

        // Country Economies for current snapshot
        Country_Economy__c turEco = new Country_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country__c = tur.Id,
            Country_Tag__c = 'TUR',
            Population__c = 13252500,
            GDP__c = 7010392.13,
            GDP_Rank__c = 1,
            Total_Exports_Value__c = 500000.0,
            Gold_Income__c = 10000.0,
            Factory_GDP__c = 280400.13,
            Employment_Factory__c = 50000,
            Province_GDP__c = 6726168.00,
            Unique_Snapshot_Key__c = 'egypt.v2_TUR'
        );

        Country_Economy__c engEco = new Country_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country__c = eng.Id,
            Country_Tag__c = 'ENG',
            Population__c = 15000000,
            GDP__c = 3866996.44,
            GDP_Rank__c = 2,
            Total_Exports_Value__c = 800000.0,
            Gold_Income__c = 0.0,
            Factory_GDP__c = 917799.44,
            Employment_Factory__c = 120000,
            Province_GDP__c = 2946944.00,
            Unique_Snapshot_Key__c = 'egypt.v2_ENG'
        );
        insert new List<Country_Economy__c>{ turEco, engEco };

        // Country Economies for base snapshot
        Country_Economy__c turBaseEco = new Country_Economy__c(
            Economy_Analysis__c = baseAnalysis.Id,
            Country__c = tur.Id,
            Country_Tag__c = 'TUR',
            GDP__c = 6500000.00,
            Unique_Snapshot_Key__c = 'egypt_base.v2_TUR'
        );
        insert turBaseEco;
    }

    @isTest
    static void testComputeAllLenses() {
        Economy_Analysis__c current = [SELECT Id FROM Economy_Analysis__c WHERE Save_File_Name__c = 'egypt.v2' LIMIT 1];
        Economy_Analysis__c base = [SELECT Id FROM Economy_Analysis__c WHERE Save_File_Name__c = 'egypt_base.v2' LIMIT 1];

        Test.startTest();
        List<CrossDomainLensDTO> lenses = CrossDomainIntelligenceEngine.computeAllLenses(current.Id, base.Id, 'TUR');
        Test.stopTest();

        System.assertEquals(5, lenses.size(), 'Should return exactly 5 cross-domain lenses');

        // Assert CAP-D-001 (Tax vs GDP Growth)
        CrossDomainLensDTO cap1 = lenses[0];
        System.assertEquals('CAP-D-001', cap1.capabilityId);
        System.assertEquals('TUR', cap1.countryTag);
        System.assert(cap1.headline.contains('Ottoman Empire'), 'Headline should reference country name');

        // Assert CAP-D-006 (Military Budget Ratio)
        CrossDomainLensDTO cap6 = lenses[1];
        System.assertEquals('CAP-D-006', cap6.capabilityId);
        System.assertNotEquals(null, cap6.primaryMetricValue);

        // Assert CAP-D-011 (Literacy vs Productivity)
        CrossDomainLensDTO cap11 = lenses[2];
        System.assertEquals('CAP-D-011', cap11.capabilityId);

        // Assert CAP-D-016 (War GDP Decline)
        CrossDomainLensDTO cap16 = lenses[3];
        System.assertEquals('CAP-D-016', cap16.capabilityId);

        // Assert CAP-D-021 (Sphere Market Capture)
        CrossDomainLensDTO cap21 = lenses[4];
        System.assertEquals('CAP-D-021', cap21.capabilityId);
    }

    @isTest
    static void testAnalysisControllerGalleryData() {
        Economy_Analysis__c current = [SELECT Id FROM Economy_Analysis__c WHERE Save_File_Name__c = 'egypt.v2' LIMIT 1];
        Economy_Analysis__c base = [SELECT Id FROM Economy_Analysis__c WHERE Save_File_Name__c = 'egypt_base.v2' LIMIT 1];

        Test.startTest();
        List<CrossDomainLensDTO> gallery = CrossDomainAnalysisController.getLensGalleryData(current.Id, base.Id, 'TUR');
        Test.stopTest();

        System.assertEquals(5, gallery.size(), 'Controller should return 5 lens DTOs');
    }

    @isTest
    static void testAnalysisControllerSingleLens() {
        Economy_Analysis__c current = [SELECT Id FROM Economy_Analysis__c WHERE Save_File_Name__c = 'egypt.v2' LIMIT 1];

        Test.startTest();
        CrossDomainLensDTO dto1 = CrossDomainAnalysisController.getLensData('CAP-D-001', current.Id, null, 'TUR');
        CrossDomainLensDTO dto6 = CrossDomainAnalysisController.getLensData('CAP-D-006', current.Id, null, 'TUR');
        CrossDomainLensDTO dto11 = CrossDomainAnalysisController.getLensData('CAP-D-011', current.Id, null, 'TUR');
        CrossDomainLensDTO dto16 = CrossDomainAnalysisController.getLensData('CAP-D-016', current.Id, null, 'TUR');
        CrossDomainLensDTO dto21 = CrossDomainAnalysisController.getLensData('CAP-D-021', current.Id, null, 'TUR');
        CrossDomainLensDTO unknown = CrossDomainAnalysisController.getLensData('INVALID', current.Id, null, 'TUR');
        Test.stopTest();

        System.assertEquals('CAP-D-001', dto1.capabilityId);
        System.assertEquals('CAP-D-006', dto6.capabilityId);
        System.assertEquals('CAP-D-011', dto11.capabilityId);
        System.assertEquals('CAP-D-016', dto16.capabilityId);
        System.assertEquals('CAP-D-021', dto21.capabilityId);
        System.assertEquals(null, unknown.capabilityId);
    }

    @isTest
    static void testNullAndEdgeCases() {
        Test.startTest();
        List<CrossDomainLensDTO> emptyList = CrossDomainIntelligenceEngine.computeAllLenses(null, null, null);
        List<CrossDomainLensDTO> controllerNull = CrossDomainAnalysisController.getLensGalleryData(null, null, null);
        CrossDomainLensDTO singleNull = CrossDomainAnalysisController.getLensData('CAP-D-001', null, null, null);
        Test.stopTest();

        System.assertEquals(0, emptyList.size());
        System.assertEquals(5, controllerNull.size()); // Controller defaults to most recent snapshot
    }
}
