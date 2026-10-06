/**
 * @description Comprehensive unit tests for CampaignAdvisorController and CampaignAdvisorPromptTemplate.
 */
@isTest
private class CampaignAdvisorControllerTest {

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
            Unemployment_Rate__c = 4.2,
            Unique_Snapshot_Key__c = '18360101_TUR'
        );
        insert countryEconomy;
    }

    @isTest
    static void testGetAdvisorResponseEconomicDomain() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        CampaignAdvisorController.CampaignAdvisorDTO dto = CampaignAdvisorController.getAdvisorResponse(
            'What is my GDP and rank?',
            analysis.Id,
            'TUR',
            'economy'
        );
        Test.stopTest();

        System.assertNotEquals(null, dto, 'Response DTO should not be null');
        System.assertEquals('TUR', dto.countryTag, 'Country tag should be TUR');
        System.assert(!dto.facts.isEmpty(), 'Facts list should contain grounded items');
        System.assertNotEquals('', dto.interpretationText, 'Interpretation text should be populated');
        System.assert(dto.isVerified, 'Response should pass verification');
    }

    @isTest
    static void testGetAdvisorResponseTreasuryDomain() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        CampaignAdvisorController.CampaignAdvisorDTO dto = CampaignAdvisorController.getAdvisorResponse(
            'What is draining my treasury and budget balance?',
            analysis.Id,
            'TUR',
            'economy'
        );
        Test.stopTest();

        System.assertNotEquals(null, dto, 'Response DTO should not be null');
        System.assertEquals('TREASURY', dto.actionType, 'Action type should be TREASURY');
        System.assert(!dto.facts.isEmpty(), 'Facts list should contain treasury items');
    }

    @isTest
    static void testGetAdvisorResponseMilitaryDomain() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        CampaignAdvisorController.CampaignAdvisorDTO dto = CampaignAdvisorController.getAdvisorResponse(
            'How strong is my military OOB and army?',
            analysis.Id,
            'TUR',
            'power'
        );
        Test.stopTest();

        System.assertNotEquals(null, dto, 'Response DTO should not be null');
        System.assertEquals('MILITARY', dto.actionType, 'Action type should be MILITARY');
    }

    @isTest
    static void testGetAdvisorResponseRebellionDomain() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        CampaignAdvisorController.CampaignAdvisorDTO dto = CampaignAdvisorController.getAdvisorResponse(
            'Why is my rebellion risk spiking?',
            analysis.Id,
            'TUR',
            'society'
        );
        Test.stopTest();

        System.assertNotEquals(null, dto, 'Response DTO should not be null');
        System.assertEquals('REBELLION', dto.actionType, 'Action type should be REBELLION');
    }

    @isTest
    static void testLogFeedback() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        Boolean success = CampaignAdvisorController.logFeedback(
            analysis.Id,
            'TUR',
            'Why is rebellion risk rising?',
            'Rebellion risk is rising due to unemployment.',
            true,
            'Great advice!'
        );
        Test.stopTest();

        System.assert(success, 'logFeedback should return true');
    }

    @isTest
    static void testCampaignAdvisorPromptTemplate() {
        Map<String, Object> groundTruth = new Map<String, Object>{ 'gdp' => 25000.0 };

        Test.startTest();
        String prompt = CampaignAdvisorPromptTemplate.buildGroundedPrompt('What is GDP?', groundTruth, 'TUR', '1836-01-01');
        Test.stopTest();

        System.assert(prompt.contains('ANTI-HALLUCINATION RULES'), 'Prompt should contain anti-hallucination rules');
        System.assert(prompt.contains('TUR'), 'Prompt should include country tag TUR');
    }
}
