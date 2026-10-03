@isTest
private class EconomyAnalysisControllerTest {

    @testSetup
    static void setupTestData() {
        // Master Data
        Country__c country = new Country__c(
            Name = 'Prussia',
            Tag__c = 'PRU',
            Flag_URL__c = 'https://example.com/pru.png'
        );
        insert country;

        Product__c product = new Product__c(
            Name = 'Small Arms',
            Code__c = 'small_arms',
            Base_Price__c = 10.0
        );
        insert product;

        // Analysis Header
        Economy_Analysis__c analysis = new Economy_Analysis__c(
            Save_File_Name__c = 'prussia_1848.v2',
            Source_Save_File_Name__c = 'prussia_1848.v2',
            Ingame_Date__c = Date.newInstance(1848, 3, 12),
            Analysis_Timestamp__c = Datetime.now(),
            Player_Country_Tag__c = 'PRU',
            Total_World_Imports__c = 1000.0,
            Total_World_Exports__c = 1200.0,
            Import_Status__c = 'COMPLETED',
            Unique_Snapshot_Key__c = 'prussia_1848.v2'
        );
        insert analysis;

        // Country Snapshot
        Country_Economy__c countryEco = new Country_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Country__c = country.Id,
            Country_Tag__c = 'PRU',
            Population__c = 1000000,
            Workforce__c = 250000,
            Employment__c = 240000,
            GDP__c = 500000.0,
            GDP_Rank__c = 1,
            Gold_Income__c = 50.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_PRU'
        );
        insert countryEco;

        // Product Snapshot
        Product_Economy__c prodEco = new Product_Economy__c(
            Economy_Analysis__c = analysis.Id,
            Product__c = product.Id,
            Product_Code__c = 'small_arms',
            Price__c = 12.0,
            Base_Price__c = 10.0,
            Total_World_Supply__c = 100.0,
            Real_Demand__c = 80.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_small_arms'
        );
        insert prodEco;

        // Junction Snapshot
        Country_Product_Economy__c cpe = new Country_Product_Economy__c(
            Country_Economy__c = countryEco.Id,
            Product_Economy__c = prodEco.Id,
            Product__c = product.Id,
            Product_Code__c = 'small_arms',
            Sold_Domestic__c = 50.0,
            Import_Value__c = 100.0,
            Export_Value__c = 200.0,
            GDP_Contribution__c = 600.0,
            Unique_Snapshot_Key__c = 'prussia_1848.v2_PRU_small_arms'
        );
        insert cpe;
    }

    @isTest
    static void testGetRecentAnalyses() {
        Test.startTest();
        List<Economy_Analysis__c> analyses = EconomyAnalysisController.getRecentAnalyses(10);
        List<Economy_Analysis__c> defaultAnalyses = EconomyAnalysisController.getRecentAnalyses(null);
        Test.stopTest();

        System.assertEquals(1, analyses.size(), 'Should return 1 recent analysis');
        System.assertEquals('prussia_1848.v2', analyses[0].Save_File_Name__c, 'Save file name should match');
        System.assertEquals(1, defaultAnalyses.size(), 'Default limit should return 1 analysis');
    }

    @isTest
    static void testGetAnalysisSummary() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        AnalysisSummaryDTO dto = EconomyAnalysisController.getAnalysisSummary(analysis.Id);
        AnalysisSummaryDTO nullDto = EconomyAnalysisController.getAnalysisSummary(null);
        Test.stopTest();

        System.assertNotEquals(null, dto, 'AnalysisSummaryDTO should not be null');
        System.assertEquals(analysis.Id, dto.analysisId, 'Analysis Id should match');
        System.assertEquals('prussia_1848.v2', dto.saveFileName, 'Save file name should match');
        System.assertEquals('PRU', dto.playerCountryTag, 'Player country tag should match');
        System.assertEquals('COMPLETED', dto.importStatus, 'Import status should match');
        System.assertEquals(null, nullDto, 'Null analysis Id should return null DTO');
    }

    @isTest
    static void testGetCountrySummaries() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        List<CountrySummaryDTO> countryDtos = EconomyAnalysisController.getCountrySummaries(analysis.Id);
        List<CountrySummaryDTO> nullList = EconomyAnalysisController.getCountrySummaries(null);
        Test.stopTest();

        System.assertEquals(1, countryDtos.size(), 'Should return 1 country summary DTO');
        System.assertEquals('PRU', countryDtos[0].countryTag, 'Country tag should be PRU');
        System.assertEquals(500000.0, countryDtos[0].gdp, 'GDP should match');
        System.assertEquals(0, nullList.size(), 'Null analysis Id should return empty list');
    }

    @isTest
    static void testGetCountrySummary() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Country_Economy__c countryEco = [SELECT Id FROM Country_Economy__c LIMIT 1];

        Test.startTest();
        CountrySummaryDTO dto = EconomyAnalysisController.getCountrySummary(analysis.Id, countryEco.Id);
        CountrySummaryDTO nullDto = EconomyAnalysisController.getCountrySummary(analysis.Id, null);
        CountrySummaryDTO nullAnalysisDto = EconomyAnalysisController.getCountrySummary(null, countryEco.Id);
        Test.stopTest();

        System.assertNotEquals(null, dto, 'CountrySummaryDTO should not be null');
        System.assertEquals(countryEco.Id, dto.countryEconomyId, 'CountryEconomyId should match');
        System.assertEquals('PRU', dto.countryTag, 'Country tag should match');
        System.assertEquals(null, nullDto, 'Null country ID should return null');
        System.assertEquals(null, nullAnalysisDto, 'Null analysis ID should return null');
    }

    @isTest
    static void testGetCountryProductSummaries() {
        Country_Economy__c countryEco = [SELECT Id FROM Country_Economy__c LIMIT 1];

        Test.startTest();
        List<CountryProductSummaryDTO> productDtos = EconomyAnalysisController.getCountryProductSummaries(countryEco.Id);
        List<CountryProductSummaryDTO> nullList = EconomyAnalysisController.getCountryProductSummaries(null);
        Test.stopTest();

        System.assertEquals(1, productDtos.size(), 'Should return 1 country-product DTO');
        System.assertEquals('small_arms', productDtos[0].productCode, 'Product code should match');
        System.assertEquals(600.0, productDtos[0].gdpContribution, 'GDP contribution should match');
        System.assertEquals(0, nullList.size(), 'Null country ID should return empty list');
    }

    @isTest
    static void testGetProductSummaries() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        List<ProductSummaryDTO> productDtos = EconomyAnalysisController.getProductSummaries(analysis.Id);
        List<ProductSummaryDTO> nullList = EconomyAnalysisController.getProductSummaries(null);
        Test.stopTest();

        System.assertEquals(1, productDtos.size(), 'Should return 1 product summary DTO');
        System.assertEquals('small_arms', productDtos[0].productCode, 'Product code should match');
        System.assertEquals(12.0, productDtos[0].price, 'Price should match');
        System.assertEquals(0, nullList.size(), 'Null analysis Id should return empty list');
    }

    @isTest
    static void testGetProductSummary() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];
        Product_Economy__c prodEco = [SELECT Id FROM Product_Economy__c LIMIT 1];

        Test.startTest();
        ProductSummaryDTO dto = EconomyAnalysisController.getProductSummary(analysis.Id, prodEco.Id);
        ProductSummaryDTO nullDto = EconomyAnalysisController.getProductSummary(analysis.Id, null);
        ProductSummaryDTO nullAnalysisDto = EconomyAnalysisController.getProductSummary(null, prodEco.Id);
        Test.stopTest();

        System.assertNotEquals(null, dto, 'ProductSummaryDTO should not be null');
        System.assertEquals(prodEco.Id, dto.productEconomyId, 'ProductEconomyId should match');
        System.assertEquals('small_arms', dto.productCode, 'Product code should match');
        System.assertEquals(null, nullDto, 'Null product ID should return null');
        System.assertEquals(null, nullAnalysisDto, 'Null analysis ID should return null');
    }

    @isTest
    static void testGetCountryProductSummariesByProduct() {
        Product_Economy__c prodEco = [SELECT Id FROM Product_Economy__c LIMIT 1];

        Test.startTest();
        List<CountryProductSummaryDTO> productDtos = EconomyAnalysisController.getCountryProductSummariesByProduct(prodEco.Id);
        List<CountryProductSummaryDTO> nullList = EconomyAnalysisController.getCountryProductSummariesByProduct(null);
        Test.stopTest();

        System.assertEquals(1, productDtos.size(), 'Should return 1 country-product DTO for product');
        System.assertEquals('PRU', productDtos[0].countryTag, 'Country tag should be PRU');
        System.assertEquals(600.0, productDtos[0].gdpContribution, 'GDP contribution should match');
        System.assertEquals(0, nullList.size(), 'Null product ID should return empty list');
    }

    @isTest
    static void testExportCsvScopes() {
        Economy_Analysis__c analysis = [SELECT Id FROM Economy_Analysis__c LIMIT 1];

        Test.startTest();
        String summaryCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Summary');
        String countriesCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Countries');
        String productsCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Products');
        String cpCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'CountryProducts');
        String provincesCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'Provinces');
        String nullCsv = EconomyAnalysisController.exportCsv(null, 'Summary');
        String invalidScopeCsv = EconomyAnalysisController.exportCsv(analysis.Id, 'InvalidScope');
        Test.stopTest();

        System.assert(summaryCsv.contains('Analysis ID,Save File Name'), 'Summary CSV should contain headers');
        System.assert(summaryCsv.contains('prussia_1848.v2'), 'Summary CSV should contain save file name');

        System.assert(countriesCsv.contains('Tag,Official Name'), 'Countries CSV should contain headers');
        System.assert(countriesCsv.contains('PRU'), 'Countries CSV should contain country tag');

        System.assert(productsCsv.contains('Product Code,Product Name'), 'Products CSV should contain headers');
        System.assert(productsCsv.contains('small_arms'), 'Products CSV should contain product code');

        System.assert(cpCsv.contains('Country Tag,Product Code'), 'CountryProducts CSV should contain headers');

        System.assert(provincesCsv.contains('Province ID,Country Tag'), 'Provinces CSV should contain headers');

        System.assertEquals('', nullCsv, 'Null analysis ID should return empty CSV string');
        System.assertEquals('', invalidScopeCsv, 'Invalid scope should return empty CSV string');
    }

    @isTest
    static void testRestrictedUserAccess() {
        User minUser = createMinimumAccessUser();
        System.runAs(minUser) {
            Test.startTest();
            List<Economy_Analysis__c> analyses = EconomyAnalysisController.getRecentAnalyses(10);
            Test.stopTest();
            System.assertNotEquals(null, analyses, 'Method should handle restricted access without throwing unhandled exceptions');
        }
    }

    private static User createMinimumAccessUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' OR Name = 'Standard User' LIMIT 1];
        String uniqueName = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueName
        );
        insert u;
        return u;
    }
}
